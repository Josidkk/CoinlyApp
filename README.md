# Conly - Sistema de Préstamos

Aplicación móvil para gestión de préstamos desarrollada en Flutter con Supabase como backend.

## 🚀 Características

- Autenticación de usuarios
- Dashboard con estadísticas en tiempo real
- Gestión de préstamos
- Soporte para Android 7.0 (API 24) hasta Android 14 (API 34)
- Manejo de permisos por versión de Android

## 📋 Requisitos Previos

- Flutter SDK (3.10.1 o superior)
- Dart SDK
- Android Studio / VS Code
- Cuenta de Supabase
- 
## 📱 Estructura del Proyecto

```
lib/
├── config/
│   └── supabase_config.dart      # Configuración de Supabase
├── models/
│   ├── usuario.dart               # Modelo de Usuario
│   ├── prestamo.dart              # Modelo de Préstamo
│   └── estadisticas_home.dart     # Modelo de Estadísticas
├── services/
│   ├── auth_service.dart          # Servicio de autenticación
│   ├── prestamo_service.dart      # Servicio de préstamos
│   ├── storage_service.dart       # Almacenamiento local
│   └── permission_service.dart    # Manejo de permisos
├── screens/
│   ├── login_screen.dart          # Pantalla de login
│   └── home_screen.dart           # Pantalla principal
└── main.dart                      # Punto de entrada
```

## 🔐 Seguridad

### Consideraciones Importantes:

1. **Contraseñas**: Actualmente se almacenan en texto plano. Para producción:
   - Implementar hash de contraseñas (bcrypt, argon2)
   - Usar Supabase Auth en lugar de autenticación manual
   
2. **RLS (Row Level Security)**: Configurar políticas en Supabase:
   ```sql
   -- Ejemplo: Solo usuarios autenticados pueden ver préstamos
   ALTER TABLE tbprestamos ENABLE ROW LEVEL SECURITY;
   
   CREATE POLICY "Usuarios pueden ver préstamos"
   ON tbprestamos FOR SELECT
   USING (auth.role() = 'authenticated');
   ```

3. **Validación**: Implementar validación en el backend (Supabase Functions)

## 📊 Funcionalidades del Home

La pantalla principal muestra:

- **Préstamos Activos**: Cantidad total de préstamos vigentes
- **Total Clientes**: Número de clientes registrados
- **Capital Prestado**: Suma total del capital prestado
- **Por Cobrar**: Total pendiente de cobro (capital + intereses)
- **Préstamos Recientes**: Lista de los últimos 5 préstamos

## 📝 Notas de Desarrollo

- **minSdkVersion**: 24 (Android 7.0)
- **targetSdkVersion**: 34 (Android 14)
- **Flutter Version**: 3.10.1+
- **Dart Version**: 3.10.1+
