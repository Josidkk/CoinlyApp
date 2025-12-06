import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class PermissionService {
  // Solicitar permisos necesarios según la versión de Android
  Future<bool> solicitarPermisosNecesarios() async {
    if (!Platform.isAndroid) {
      return true; // En iOS u otras plataformas, retornar true
    }

    // Para Android, verificar permisos básicos
    Map<Permission, PermissionStatus> statuses = await [
      Permission.notification,
    ].request();

    // Verificar si todos los permisos fueron concedidos
    bool todosOtorgados = statuses.values.every(
      (status) => status.isGranted || status.isLimited,
    );

    return todosOtorgados;
  }

  // Verificar estado de un permiso específico
  Future<bool> verificarPermiso(Permission permission) async {
    final status = await permission.status;
    return status.isGranted || status.isLimited;
  }

  // Solicitar permiso específico
  Future<bool> solicitarPermiso(Permission permission) async {
    final status = await permission.request();
    return status.isGranted || status.isLimited;
  }

  // Abrir configuración de la app si el permiso fue denegado permanentemente
  Future<void> abrirConfiguracion() async {
    await openAppSettings();
  }

  // Verificar si un permiso fue denegado permanentemente
  Future<bool> fuePermisoDenegadoPermanentemente(Permission permission) async {
    final status = await permission.status;
    return status.isPermanentlyDenied;
  }
}
