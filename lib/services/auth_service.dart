import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/usuario.dart';
import 'storage_service.dart';

class AuthService {
  final SupabaseClient _supabase = SupabaseConfig.client;
  final StorageService _storageService = StorageService();

  // Login con usuario y contraseña
  Future<Map<String, dynamic>> login(String usuario, String contrasena) async {
    try {
      // Buscar usuario en la base de datos
      final response = await _supabase
          .from('tbusuarios')
          .select()
          .eq('usua_usuario', usuario)
          .eq('usua_contrasena', contrasena) // NOTA: En producción, usar hash
          .eq('usua_estado', true)
          .single();

      // Crear objeto Usuario
      final usuarioObj = Usuario.fromJson(response);

      // Guardar en storage local
      await _storageService.guardarUsuario(usuarioObj);
      await _storageService.guardarToken('token_${usuarioObj.usuaId}');

      return {
        'success': true,
        'message': 'Login exitoso',
        'usuario': usuarioObj,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al iniciar sesión: ${e.toString()}',
      };
    }
  }

  // Logout
  Future<void> logout() async {
    await _storageService.limpiarDatos();
  }

  // Verificar sesión activa
  Future<bool> verificarSesion() async {
    return await _storageService.tieneSesionActiva();
  }

  // Obtener usuario actual
  Future<Usuario?> obtenerUsuarioActual() async {
    return await _storageService.obtenerUsuario();
  }

  // Obtener usuario actual con detalles (rol, estado civil, municipio, departamento)
  Future<Map<String, dynamic>?> obtenerUsuarioDetallado() async {
    try {
      print('[AuthService] Iniciando obtenerUsuarioDetallado');
      final usuario = await _storageService.obtenerUsuario();
      if (usuario == null) {
        print('[AuthService] ERROR: Usuario en storage es null');
        return null;
      }

      print('[AuthService] Usuario ID: ${usuario.usuaId}');
      print('[AuthService] Role ID: ${usuario.roleId}');

      // Obtener usuario con joins (especificando las FKs exactas para evitar ambigüedad)
      print('[AuthService] Ejecutando query a Supabase...');
      final response = await _supabase
          .from('tbusuarios')
          .select('''
            *,
            tbroles!tbusuarios_Role_Id_fkey(role_descripcion),
            tbestadosciviles!tbusuarios_esci_id_fkey(esci_descripcion),
            tbmunicipios!tbusuarios_muni_codigo_fkey(
              muni_descripcion,
              tbdepartamentos(depa_descripcion)
            )
          ''')
          .eq('usua_id', usuario.usuaId)
          .single();

      print('[AuthService] Response completo de Supabase:');
      print(response);

      print('[AuthService] tbroles: ${response['tbroles']}');
      print('[AuthService] tbestadosciviles: ${response['tbestadosciviles']}');
      print('[AuthService] tbmunicipios: ${response['tbmunicipios']}');

      // Construir objeto con datos relacionados
      final resultado = {
        ...response,
        'rol_descripcion': response['tbroles']?['role_descripcion'],
        'estado_civil_descripcion':
            response['tbestadosciviles']?['esci_descripcion'],
        'municipio_descripcion': response['tbmunicipios']?['muni_descripcion'],
        'departamento_descripcion':
            response['tbmunicipios']?['tbdepartamentos']?['depa_descripcion'],
      };

      print('[AuthService] Resultado procesado:');
      print('  - rol_descripcion: ${resultado['rol_descripcion']}');
      print(
        '  - estado_civil_descripcion: ${resultado['estado_civil_descripcion']}',
      );
      print('  - municipio_descripcion: ${resultado['municipio_descripcion']}');
      print(
        '  - departamento_descripcion: ${resultado['departamento_descripcion']}',
      );

      return resultado;
    } catch (e, stackTrace) {
      print('[AuthService] ERROR al obtener usuario detallado:');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      return null;
    }
  }

  // Cambiar contraseña
  Future<Map<String, dynamic>> cambiarContrasena(
    int usuaId,
    String contrasenaActual,
    String contrasenaNueva,
  ) async {
    try {
      // Verificar contraseña actual
      await _supabase
          .from('tbusuarios')
          .select()
          .eq('usua_id', usuaId)
          .eq('usua_contrasena', contrasenaActual)
          .single();

      // Actualizar contraseña
      await _supabase
          .from('tbusuarios')
          .update({
            'usua_contrasena': contrasenaNueva,
            'usua_modificacion': usuaId,
            'usua_fechamodificacion': DateTime.now().toIso8601String(),
          })
          .eq('usua_id', usuaId);

      return {
        'success': true,
        'message': 'Contraseña actualizada exitosamente',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al cambiar contraseña: ${e.toString()}',
      };
    }
  }
}
