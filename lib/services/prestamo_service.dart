import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/prestamo.dart';
import '../models/estadisticas_home.dart';
import '../models/cuota_prestamo.dart';

class PrestamoService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // Obtener estadísticas para el home
  Future<EstadisticasHome> obtenerEstadisticas() async {
    try {
      // Total de préstamos activos
      final prestamosActivos = await _supabase
          .from('tbprestamos')
          .select('pres_id')
          .eq('pres_estado', true);

      // Total capital prestado
      final capitalResponse = await _supabase
          .from('tbprestamos')
          .select('pres_capitalInicial')
          .eq('pres_estado', true);

      double totalCapital = 0;
      for (var item in capitalResponse) {
        totalCapital += (item['pres_capitalInicial'] as num).toDouble();
      }

      // Total clientes
      final clientesResponse = await _supabase
          .from('tbclientes')
          .select('clie_id')
          .eq('clie_estado', true);

      // Calcular total por cobrar (suma de capital e intereses restantes)
      final detallesResponse = await _supabase
          .from('tbprestamosdetalles')
          .select('prde_capitalrestante, prde_interesrestante')
          .eq('prde_estado', true);

      double totalPorCobrar = 0;
      double totalIntereses = 0;
      for (var item in detallesResponse) {
        totalPorCobrar += (item['prde_capitalrestante'] as num).toDouble();
        totalPorCobrar += (item['prde_interesrestante'] as num).toDouble();
        totalIntereses += (item['prde_interesrestante'] as num).toDouble();
      }

      return EstadisticasHome(
        totalPrestamosActivos: prestamosActivos.length,
        totalCapitalPrestado: totalCapital,
        totalPorCobrar: totalPorCobrar,
        totalClientes: clientesResponse.length,
        totalInteresesGenerados: totalIntereses,
      );
    } catch (e) {
      print('Error al obtener estadísticas: $e');
      return EstadisticasHome.empty();
    }
  }

  // Obtener préstamos recientes
  Future<List<Prestamo>> obtenerPrestamosRecientes({int limit = 5}) async {
    try {
      final response = await _supabase
          .from('tbprestamos')
          .select('''
            *,
            tbclientes!inner(clie_nombres, clie_apellidos)
          ''')
          .eq('pres_estado', true)
          .order('pres_fechaCreacion', ascending: false)
          .limit(limit);

      return response.map<Prestamo>((json) {
        // Agregar nombre del cliente al JSON
        final clienteData = json['tbclientes'];
        json['cliente_nombre'] =
            '${clienteData['clie_nombres']} ${clienteData['clie_apellidos']}';
        return Prestamo.fromJson(json);
      }).toList();
    } catch (e) {
      print('Error al obtener préstamos recientes: $e');
      return [];
    }
  }

  // Obtener todos los préstamos usando ORM (reemplaza al RPC sp_listar_prestamos_todos)
  Future<List<Prestamo>> obtenerTodosPrestamos() async {
    try {
      print('=== [STEP 1] Iniciando consulta ORM a tbprestamos ===');

      final response = await _supabase
          .from('tbprestamos')
          .select('''
            *,
            tbclientes!inner(clie_nombres, clie_apellidos)
          ''')
          .order('pres_fechaCreacion', ascending: false);

      print('=== [STEP 2] Respuesta recibida: ${response.length} registros ===');
      if (response.isNotEmpty) {
        print('=== [STEP 3] Primer registro RAW: ${response.first} ===');
      }

      final lista = <Prestamo>[];

      for (int i = 0; i < response.length; i++) {
        try {
          final json = Map<String, dynamic>.from(response[i]);

          // Mapear nombre del cliente desde el join
          final clienteData = json['tbclientes'];
          json['cliente_nombre'] =
              '${clienteData['clie_nombres']} ${clienteData['clie_apellidos']}';

          // Mapear campos financieros con fallback camelCase/lowercase
          json['capital_pagado'] = json['pres_capitalPagado'] ?? json['pres_capitalpagado'];
          json['interes_pagado'] = json['pres_interesPagado'] ?? json['pres_interespagado'];
          json['mora_pagada'] = json['pres_interesMoraPagado'] ?? json['pres_interesmorapagado'];
          json['mora_pendiente'] = json['pres_interesMora'] ?? json['pres_interesmora'];
          json['interes_planificado'] = json['Pres_Interes'] ?? json['pres_interes'];

          // Calcular si está en mora
          final rawMora = json['mora_pendiente'];
          double mora = 0.0;
          if (rawMora != null) {
            if (rawMora is num) mora = rawMora.toDouble();
            else if (rawMora is String) mora = double.tryParse(rawMora) ?? 0.0;
          }
          json['esta_en_mora'] = mora > 0;
          json['dias_atraso'] = 0;

          print('=== [STEP 4] Parseando registro $i: pres_id=${json['pres_id']} ===');
          lista.add(Prestamo.fromJson(json));
          print('=== [STEP 5] Registro $i parseado OK ===');
        } catch (innerError, innerStack) {
          print('=== [ERROR] Falló el registro $i: $innerError ===');
          print('=== [STACK] $innerStack ===');
        }
      }

      print('=== [DONE] Total prestamos parseados: ${lista.length} ===');
      return lista;
    } catch (e, stack) {
      print('=== [ERROR FATAL] obtenerTodosPrestamos: $e ===');
      print('=== [STACK TRACE] $stack ===');
      return [];
    }
  }

  // Obtener detalle del préstamo usando RPC sp_obtener_detalle_prestamo
  Future<List<CuotaPrestamo>> obtenerDetallePrestamo(int presId) async {
    try {
      print('=== LLAMANDO SP con presId: $presId ===');
      final List<dynamic> response = await _supabase.rpc(
        'sp_obtener_detalle_prestamo',
        params: {'p_pres_id': presId},
      );

      print('=== RESPUESTA RECIBIDA: ${response.length} registros ===');
      if (response.isNotEmpty) {
        print('=== PRIMER REGISTRO: ${response.first} ===');
      }

      final cuotas = response
          .map<CuotaPrestamo>((json) {
            try {
              return CuotaPrestamo.fromJson(json);
            } catch (e) {
              print('ERROR AL PARSEAR CUOTA: $e');
              print('JSON PROBLEMÁTICO: $json');
              rethrow;
            }
          })
          .toList();
      
      print('=== CUOTAS PARSEADAS: ${cuotas.length} ===');
      return cuotas;
    } catch (e, stackTrace) {
      print('ERROR COMPLETO al obtener detalle del préstamo: $e');
      print('STACK TRACE: $stackTrace');
      return [];
    }
  }
}
