import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/usuario.dart';

class StorageService {
  static const String _keyUsuario = 'usuario_actual';
  static const String _keyToken = 'auth_token';

  // Guardar usuario
  Future<void> guardarUsuario(Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsuario, jsonEncode(usuario.toJson()));
  }

  // Obtener usuario
  Future<Usuario?> obtenerUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioJson = prefs.getString(_keyUsuario);
    if (usuarioJson != null) {
      return Usuario.fromJson(jsonDecode(usuarioJson));
    }
    return null;
  }

  // Guardar token
  Future<void> guardarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  // Obtener token
  Future<String?> obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // Limpiar datos (logout)
  Future<void> limpiarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsuario);
    await prefs.remove(_keyToken);
  }

  // Verificar si hay sesión activa
  Future<bool> tieneSesionActiva() async {
    final usuario = await obtenerUsuario();
    final token = await obtenerToken();
    return usuario != null && token != null;
  }
}
