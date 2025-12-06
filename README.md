# Conly - Sistema de Préstamos

Aplicación móvil para gestión de préstamos desarrollada en Flutter con Supabase como backend.

## 🚀 Características

- ✅ Autenticación de usuarios
- ✅ Dashboard con estadísticas en tiempo real
- ✅ Gestión de préstamos
- ✅ Soporte para Android 7.0 (API 24) hasta Android 14 (API 34)
- ✅ Diseño moderno y responsivo
- ✅ Manejo de permisos por versión de Android

## 📋 Requisitos Previos

- Flutter SDK (3.10.1 o superior)
- Dart SDK
- Android Studio / VS Code
- Cuenta de Supabase

## 🔧 Configuración

### 1. Configurar Supabase

1. Crea un proyecto en [Supabase](https://supabase.com)
2. Copia tu URL y Anon Key del proyecto
3. Abre el archivo `lib/config/supabase_config.dart`
4. Reemplaza las siguientes líneas con tus credenciales:

```dart
static const String supabaseUrl = 'TU_SUPABASE_URL_AQUI';
static const String supabaseAnonKey = 'TU_SUPABASE_ANON_KEY_AQUI';
```

### 2. Configurar Base de Datos

Ejecuta el siguiente esquema SQL en tu proyecto de Supabase (ya proporcionado en tu esquema):

- `tbusuarios`
- `tbclientes`
- `tbprestamos`
- `tbprestamosdetalles`
- `tbfacturas`
- Y demás tablas del esquema

### 3. Crear Usuario de Prueba

Inserta un usuario de prueba en la tabla `tbusuarios`:

```sql
INSERT INTO tbusuarios (
  usua_usuario,
  usua_contrasena,
  usua_nombres,
  usua_apellidos,
  usua_estado
) VALUES (
  'admin',
  'admin123',  -- IMPORTANTE: En producción usar hash
  'Administrador',
  'Sistema',
  true
);
```

**NOTA IMPORTANTE**: Este ejemplo usa contraseñas en texto plano solo para desarrollo. En producción, debes implementar hash de contraseñas (bcrypt, argon2, etc.).

### 4. Instalar Dependencias

```bash
flutter pub get
```

## 🏃‍♂️ Ejecutar la Aplicación

### Modo Debug
```bash
flutter run
```

### Modo Release
```bash
flutter run --release
```

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

## 🎨 Características de UI

- **Gradientes modernos**: Diseño atractivo con degradados
- **Animaciones suaves**: Transiciones y efectos visuales
- **Google Fonts**: Tipografía Poppins para mejor legibilidad
- **Tarjetas informativas**: Visualización clara de estadísticas
- **Pull to refresh**: Actualización de datos deslizando hacia abajo
- **Splash screen**: Pantalla de carga inicial

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

## 🔄 Próximas Características

- [ ] Gestión completa de clientes
- [ ] Creación de nuevos préstamos
- [ ] Calendario de pagos
- [ ] Generación de facturas
- [ ] Reportes y gráficos
- [ ] Notificaciones push
- [ ] Exportación de datos (PDF, Excel)
- [ ] Modo oscuro

## 🐛 Solución de Problemas

### Error de conexión a Supabase
- Verifica que las credenciales en `supabase_config.dart` sean correctas
- Asegúrate de tener conexión a internet
- Verifica que las tablas existan en tu base de datos

### Error de permisos en Android
- Asegúrate de que `AndroidManifest.xml` tenga los permisos necesarios
- Para Android 13+, los permisos se solicitan en tiempo de ejecución

### Error al compilar
```bash
flutter clean
flutter pub get
flutter run
```

## 📝 Notas de Desarrollo

- **minSdkVersion**: 24 (Android 7.0)
- **targetSdkVersion**: 34 (Android 14)
- **Flutter Version**: 3.10.1+
- **Dart Version**: 3.10.1+

## 👨‍💻 Créditos

Desarrollado con Flutter y Supabase.

## 📄 Licencia

Este proyecto es de uso privado.
