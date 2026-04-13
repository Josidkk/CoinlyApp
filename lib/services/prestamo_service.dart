import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/prestamo.dart';
import '../models/prestamo_Detallado.dart';
import '../models/estadisticas_home.dart';
import '../models/cuota_prestamo.dart';
import 'auth_service.dart';

class PrestamoService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // Obtener estadísticas para el home
  Future<EstadisticasHome> obtenerEstadisticas() async {
    try {
      // 1. Obtener todos los préstamos activos para calcular capital y saldos
      final prestamosResponse = await _supabase
          .from('tbprestamos')
          .select('pres_id, pres_capitalInicial, pres_capitalPagado, pres_interesPendiente')
          .eq('pres_estado', true);

      double totalCapital = 0;
      double totalPorCobrar = 0;
      int totalActivos = prestamosResponse.length;

      for (var item in prestamosResponse) {
        final capInicial = (item['pres_capitalInicial'] as num?)?.toDouble() ?? 0.0;
        final capPagado = (item['pres_capitalPagado'] as num?)?.toDouble() ?? 0.0;
        final intPendiente = (item['pres_interesPendiente'] as num?)?.toDouble() ?? 0.0;

        totalCapital += capInicial;
        // Saldo = lo que falta de capital + lo acumulado de interés
        totalPorCobrar += (capInicial - capPagado) + intPendiente;
      }

      // 2. Total clientes activos
      final clientesResponse = await _supabase
          .from('tbclientes')
          .select('clie_id')
          .eq('clie_estado', true);
      
      final totalClientes = clientesResponse.length;

      return EstadisticasHome(
        totalPrestamosActivos: totalActivos,
        totalCapitalPrestado: totalCapital,
        totalPorCobrar: totalPorCobrar,
        totalClientes: totalClientes,
        totalInteresesGenerados: 0.0, // Campo no prioritario por ahora
      );
    } catch (e, stack) {
      print('=== ERROR EN ESTADÍSTICAS HOME ===');
      print('Mensaje: $e');
      print('Stack: $stack');
      return EstadisticasHome.empty();
    }
  }

  // Obtener préstamos recientes con datos del cliente (JOIN incluido)
  Future<List<Prestamo_Detallado_DTO>> obtenerPrestamosRecientes({int limit = 5}) async {
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

      return response
          .map<Prestamo_Detallado_DTO>(
            (json) => Prestamo_Detallado_DTO.fromMap(json),
          )
          .toList();
    } catch (e) {
      print('Error al obtener préstamos recientes: $e');
      return [];
    }
  }

  // Obtener todos los préstamos con datos del cliente (JOIN incluido)
  Future<List<Prestamo_Detallado_DTO>> obtenerTodosPrestamos() async {
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

      final lista = <Prestamo_Detallado_DTO>[];

      for (int i = 0; i < response.length; i++) {
        try {
          final json = Map<String, dynamic>.from(response[i]);
          print('=== [STEP 4] Parseando registro $i: pres_id=${json['pres_id']} ===');
          lista.add(Prestamo_Detallado_DTO.fromMap(json));
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

  // Obtener detalle del préstamo consultando directamente la tabla
  Future<List<CuotaPrestamo>> obtenerDetallePrestamo(int presId) async {
    try {
      print('=== CONSULTANDO tbPrestamosDetalles con presId: $presId ===');
      final List<dynamic> response = await _supabase
          .from('tbPrestamosDetalles')
          .select()
          .eq('pres_id', presId)
          .eq('prde_estado', true)
          .order('prde_fechaPago', ascending: true);

      print('=== RESPUESTA RECIBIDA: ${response.length} registros ===');
      if (response.isNotEmpty) {
        print('=== PRIMER REGISTRO RAW: ${response.first} ===');
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

  // Obtener clientes activos para la creación de préstamos
  Future<List<Map<String, dynamic>>> obtenerClientesActivos() async {
    try {
      final response = await _supabase
          .from('tbclientes')
          .select('id:clie_id, nombres:clie_nombres, apellidos:clie_apellidos')
          .eq('clie_estado', true)
          .order('clie_nombres', ascending: true);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error al obtener clientes: $e');
      return [];
    }
  }

  // Crear nuevo préstamo
  Future<bool> crearPrestamo({
    required int clienteId,
    required double capitalInicial,
    required double tasaInteres,
    required DateTime fechaInicio,
    required String frecuenciaPago, // TODO: El backend necesitará una columna para guardar la frecuencia (Semanal/Quincenal/Mensual)
  }) async {
    try {
      await _supabase.from('tbprestamos').insert({
        'clie_id': clienteId,
        'pres_capitalInicial': capitalInicial,
        'pres_tasaInteres': tasaInteres,
        'pres_fechaInicioPago': fechaInicio.toIso8601String(),
        'pres_estado': true,
        'pres_capitalPagado': 0.0,
        'pres_interesPagado': 0.0,
      });

      return true;
    } catch (e) {
      print('Error al crear préstamo: $e');
      return false;
    }
  }

  // Registrar un abono (pago libre de capital o interés)
  Future<bool> registrarAbono({
    required int prestamoId,
    required double abonoCapital,
    required double abonoInteres,
    required double capitalRestanteActual,
  }) async {
    try {
      // 1. Obtener los totales actuales de tbprestamos
      final presRes = await _supabase
          .from('tbprestamos')
          .select('pres_capitalPagado, pres_interesPagado')
          .eq('pres_id', prestamoId)
          .single();
      
      double capitalPagadoActual = (presRes['pres_capitalPagado'] as num).toDouble();
      double interesPagadoActual = (presRes['pres_interesPagado'] as num).toDouble();

      // 2. Insertar el abono en el historial (tbPrestamosDetalles)
      final usuarioAct = await AuthService().obtenerUsuarioActual();
      final usuaCreacionId = usuarioAct?.usuaId ?? 2;

      await _supabase.from('tbPrestamosDetalles').insert({
        'pres_id': prestamoId, // 0 para identificar que es un abono libre en el nuevo modelo
        'prde_fechaPago': DateTime.now().toIso8601String(),
        'prde_fechaCreacion': DateTime.now().toIso8601String(),
        'prde_abonoCapital': abonoCapital,
        'prde_abonoInteres': abonoInteres,
        'prde_capitalRestante': capitalRestanteActual - abonoCapital,
        'prde_interesRestante': 0,
        'usua_creacion': usuaCreacionId, // Obtenido dinámicamente del AuthService
        'prde_estado': true,
      });

      // 3. Actualizar los totales del préstamo en tbprestamos
      await _supabase.from('tbprestamos').update({
        'pres_capitalPagado': capitalPagadoActual + abonoCapital,
        'pres_interesPagado': interesPagadoActual + abonoInteres,
        'pres_fechaModificacion': DateTime.now().toIso8601String(),
        'usua_modificacion': usuaCreacionId,
      }).eq('pres_id', prestamoId);

      return true;
    } catch (e) {
      print('Error al registrar abono: $e');
      return false;
    }
  }
}
