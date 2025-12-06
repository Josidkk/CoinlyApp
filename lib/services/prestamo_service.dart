import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/prestamo.dart';
import '../models/estadisticas_home.dart';

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
          .select('pres_capitalinicial')
          .eq('pres_estado', true);

      double totalCapital = 0;
      for (var item in capitalResponse) {
        totalCapital += (item['pres_capitalinicial'] as num).toDouble();
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
          .order('pres_fechacreacion', ascending: false)
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

  // Obtener todos los préstamos
  Future<List<Prestamo>> obtenerTodosPrestamos() async {
    try {
      final response = await _supabase
          .from('tbprestamos')
          .select('''
            *,
            tbclientes!inner(clie_nombres, clie_apellidos)
          ''')
          .eq('pres_estado', true)
          .order('pres_fechacreacion', ascending: false);

      return response.map<Prestamo>((json) {
        final clienteData = json['tbclientes'];
        json['cliente_nombre'] =
            '${clienteData['clie_nombres']} ${clienteData['clie_apellidos']}';
        return Prestamo.fromJson(json);
      }).toList();
    } catch (e) {
      print('Error al obtener préstamos: $e');
      return [];
    }
  }
}
