# 📱 Conly - Resumen del Proyecto

## ✨ Lo que se ha creado

### 🎯 Pantallas Implementadas

#### 1. **Splash Screen** (Pantalla de Carga)
- Muestra el logo de la aplicación
- Verifica si hay sesión activa
- Redirige automáticamente a Login o Home

#### 2. **Login Screen** (Pantalla de Inicio de Sesión)
- ✅ Diseño moderno con gradientes
- ✅ Validación de formulario
- ✅ Animaciones suaves
- ✅ Manejo de errores
- ✅ Indicador de carga
- ✅ Campo de contraseña con mostrar/ocultar

#### 3. **Home Screen** (Pantalla Principal)
- ✅ Header con información del usuario
- ✅ 4 tarjetas de estadísticas:
  - Préstamos Activos
  - Total Clientes
  - Capital Prestado
  - Por Cobrar
- ✅ Lista de préstamos recientes
- ✅ Pull to refresh (deslizar para actualizar)
- ✅ Botón de cerrar sesión

### 🏗️ Arquitectura

```
┌─────────────────────────────────────────┐
│           PRESENTATION LAYER            │
│  ┌─────────────────────────────────┐   │
│  │  Screens                        │   │
│  │  - SplashScreen                 │   │
│  │  - LoginScreen                  │   │
│  │  - HomeScreen                   │   │
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│           BUSINESS LOGIC LAYER          │
│  ┌─────────────────────────────────┐   │
│  │  Services                       │   │
│  │  - AuthService                  │   │
│  │  - PrestamoService              │   │
│  │  - StorageService               │   │
│  │  - PermissionService            │   │
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│              DATA LAYER                 │
│  ┌─────────────────────────────────┐   │
│  │  Models                         │   │
│  │  - Usuario                      │   │
│  │  - Prestamo                     │   │
│  │  - EstadisticasHome             │   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │  Data Sources                   │   │
│  │  - Supabase (Remote)            │   │
│  │  - SharedPreferences (Local)    │   │
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

### 📦 Dependencias Instaladas

| Paquete | Versión | Propósito |
|---------|---------|-----------|
| `supabase_flutter` | ^2.5.0 | Backend y base de datos |
| `provider` | ^6.1.1 | Gestión de estado |
| `shared_preferences` | ^2.2.2 | Almacenamiento local |
| `permission_handler` | ^11.3.0 | Permisos de Android |
| `google_fonts` | ^6.1.0 | Tipografía Poppins |
| `intl` | ^0.19.0 | Formateo de fechas y moneda |

### 🎨 Paleta de Colores

```dart
Primary Gradient:
- Color(0xFF667eea) // Azul violeta
- Color(0xFF764ba2) // Púrpura
- Color(0xFFf093fb) // Rosa claro

Estadísticas:
- Préstamos: Color(0xFF667eea) // Azul
- Clientes: Color(0xFF48bb78) // Verde
- Capital: Color(0xFFed8936) // Naranja
- Por Cobrar: Color(0xFFe53e3e) // Rojo

Background: Color(0xFFF7FAFC) // Gris muy claro
Text: Color(0xFF2d3748) // Gris oscuro
```

### 🔐 Seguridad Implementada

✅ **Almacenamiento Local Seguro**
- Sesión persistente con SharedPreferences
- Token de autenticación guardado localmente

⚠️ **IMPORTANTE - Para Producción:**
- [ ] Implementar hash de contraseñas (bcrypt/argon2)
- [ ] Usar Supabase Auth en lugar de autenticación manual
- [ ] Configurar Row Level Security (RLS) en Supabase
- [ ] Implementar refresh tokens
- [ ] Agregar rate limiting

### 📱 Compatibilidad Android

| Versión | API Level | Estado |
|---------|-----------|--------|
| Android 7.0 (Nougat) | 24 | ✅ Soportado |
| Android 8.0 (Oreo) | 26 | ✅ Soportado |
| Android 9.0 (Pie) | 28 | ✅ Soportado |
| Android 10 | 29 | ✅ Soportado |
| Android 11 | 30 | ✅ Soportado |
| Android 12 | 31 | ✅ Soportado |
| Android 13 | 33 | ✅ Soportado |
| Android 14 | 34 | ✅ Soportado (Target) |

### 🗂️ Estructura de Archivos

```
conly/
├── lib/
│   ├── config/
│   │   ├── supabase_config.dart          # ⚙️ Configuración de Supabase
│   │   └── supabase_config.example.dart  # 📄 Ejemplo de configuración
│   │
│   ├── models/
│   │   ├── usuario.dart                  # 👤 Modelo de Usuario
│   │   ├── prestamo.dart                 # 💰 Modelo de Préstamo
│   │   └── estadisticas_home.dart        # 📊 Modelo de Estadísticas
│   │
│   ├── services/
│   │   ├── auth_service.dart             # 🔐 Autenticación
│   │   ├── prestamo_service.dart         # 💳 Gestión de préstamos
│   │   ├── storage_service.dart          # 💾 Almacenamiento local
│   │   └── permission_service.dart       # 🔒 Permisos
│   │
│   ├── screens/
│   │   ├── login_screen.dart             # 🔑 Pantalla de login
│   │   └── home_screen.dart              # 🏠 Pantalla principal
│   │
│   └── main.dart                         # 🚀 Punto de entrada
│
├── android/
│   └── app/
│       ├── build.gradle.kts              # ⚙️ Configuración de build
│       └── src/main/
│           └── AndroidManifest.xml       # 📋 Permisos y configuración
│
├── README.md                             # 📖 Documentación principal
├── SETUP_GUIDE.md                        # 📝 Guía de configuración
└── pubspec.yaml                          # 📦 Dependencias
```

### 🔄 Flujo de la Aplicación

```
┌─────────────┐
│   Inicio    │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Splash    │ ← Verifica sesión
└──────┬──────┘
       │
       ├─── Sesión Activa ───────┐
       │                         │
       ▼                         ▼
┌─────────────┐           ┌─────────────┐
│    Login    │           │    Home     │
└──────┬──────┘           └──────┬──────┘
       │                         │
       │ Login exitoso           │
       └────────────►────────────┘
                                 │
                                 │ Logout
                                 ▼
                          ┌─────────────┐
                          │    Login    │
                          └─────────────┘
```

### 📊 Funcionalidades del Home

#### Estadísticas Calculadas:

1. **Préstamos Activos**
   - Cuenta: `SELECT COUNT(*) FROM tbprestamos WHERE pres_estado = true`

2. **Total Clientes**
   - Cuenta: `SELECT COUNT(*) FROM tbclientes WHERE clie_estado = true`

3. **Capital Prestado**
   - Suma: `SELECT SUM(pres_capitalinicial) FROM tbprestamos WHERE pres_estado = true`

4. **Por Cobrar**
   - Suma: `SELECT SUM(prde_capitalrestante + prde_interesrestante) FROM tbprestamosdetalles WHERE prde_estado = true`

#### Préstamos Recientes:
- Muestra los últimos 5 préstamos
- Incluye nombre del cliente (JOIN con tbclientes)
- Ordenados por fecha de creación (más reciente primero)


