# Guía de Configuración Inicial - Conly

## Paso 1: Configurar Supabase

### 1.1 Crear Proyecto en Supabase

1. Ve a [https://supabase.com](https://supabase.com)
2. Crea una cuenta o inicia sesión
3. Haz clic en "New Project"
4. Completa los datos:
   - **Name**: Conly
   - **Database Password**: Guarda esta contraseña en un lugar seguro
   - **Region**: Selecciona la más cercana a tu ubicación
5. Espera a que el proyecto se cree (puede tomar 1-2 minutos)

### 1.2 Obtener Credenciales

1. En tu proyecto de Supabase, ve a **Settings** (⚙️) → **API**
2. Copia los siguientes valores:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public key**: Una clave larga que empieza con `eyJ...`

### 1.3 Configurar en la App

1. Abre el archivo `lib/config/supabase_config.dart`
2. Reemplaza:
   ```dart
   static const String supabaseUrl = 'TU_SUPABASE_URL_AQUI';
   static const String supabaseAnonKey = 'TU_SUPABASE_ANON_KEY_AQUI';
   ```
   
   Por tus valores:
   ```dart
   static const String supabaseUrl = 'https://xxxxx.supabase.co';
   static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
   ```

## Paso 2: Crear Tablas en Supabase

### 2.1 Acceder al SQL Editor

1. En tu proyecto de Supabase, ve a **SQL Editor** (icono de base de datos)
2. Haz clic en **New Query**

### 2.2 Ejecutar el Esquema

Copia y pega el esquema SQL que ya tienes (el que proporcionaste) en el editor y haz clic en **Run**.

**IMPORTANTE**: El esquema tiene dependencias circulares. Ejecuta las tablas en este orden:

1. Primero, crea `tbusuarios` SIN las foreign keys
2. Luego crea las demás tablas
3. Finalmente, agrega las foreign keys a `tbusuarios`

O usa este script simplificado para empezar:

```sql
-- 1. Crear tabla de usuarios (sin FK primero)
CREATE TABLE public.tbusuarios (
  usua_id SERIAL PRIMARY KEY,
  usua_usuario VARCHAR NOT NULL UNIQUE,
  usua_contrasena VARCHAR NOT NULL,
  usua_nombres VARCHAR NOT NULL,
  usua_apellidos VARCHAR NOT NULL,
  usua_estado BOOLEAN DEFAULT true,
  usua_fechacreacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Crear tabla de clientes
CREATE TABLE public.tbclientes (
  clie_id SERIAL PRIMARY KEY,
  clie_nombres VARCHAR NOT NULL,
  clie_apellidos VARCHAR NOT NULL,
  clie_estado BOOLEAN DEFAULT true,
  clie_fechacreacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Crear tabla de préstamos
CREATE TABLE public.tbprestamos (
  pres_id SERIAL PRIMARY KEY,
  clie_id INTEGER REFERENCES tbclientes(clie_id),
  pres_tiempo INTEGER NOT NULL,
  pres_tasainteres NUMERIC NOT NULL,
  pres_numerocuotas INTEGER NOT NULL,
  pres_capitalinicial NUMERIC NOT NULL,
  pres_tipointeres VARCHAR NOT NULL,
  pres_fechainiciopago DATE NOT NULL,
  pres_fechafinpago DATE NOT NULL,
  pres_estado BOOLEAN DEFAULT true,
  pres_fechacreacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Crear tabla de detalles de préstamos
CREATE TABLE public.tbprestamosdetalles (
  prde_id SERIAL PRIMARY KEY,
  pres_id INTEGER REFERENCES tbprestamos(pres_id),
  prde_numeromes INTEGER NOT NULL,
  prde_capital NUMERIC NOT NULL,
  prde_capitalpagado NUMERIC DEFAULT 0,
  prde_interes NUMERIC NOT NULL,
  prde_interespagado NUMERIC DEFAULT 0,
  prde_interesmora NUMERIC DEFAULT 0,
  prde_capitalrestante NUMERIC NOT NULL,
  prde_interesrestante NUMERIC NOT NULL,
  prde_fechapago DATE NOT NULL,
  prde_fechapagorealizado DATE,
  prde_estado BOOLEAN DEFAULT true,
  prde_fechacreacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Paso 3: Insertar Datos de Prueba

### 3.1 Crear Usuario de Prueba

```sql
INSERT INTO tbusuarios (
  usua_usuario,
  usua_contrasena,
  usua_nombres,
  usua_apellidos
) VALUES (
  'admin',
  'admin123',
  'Administrador',
  'Sistema'
);
```

### 3.2 Crear Cliente de Prueba

```sql
INSERT INTO tbclientes (
  clie_nombres,
  clie_apellidos
) VALUES (
  'Juan',
  'Pérez'
);
```

### 3.3 Crear Préstamo de Prueba

```sql
INSERT INTO tbprestamos (
  clie_id,
  pres_tiempo,
  pres_tasainteres,
  pres_numerocuotas,
  pres_capitalinicial,
  pres_tipointeres,
  pres_fechainiciopago,
  pres_fechafinpago
) VALUES (
  1,  -- ID del cliente creado
  12, -- 12 meses
  15.5, -- 15.5% de interés
  12, -- 12 cuotas
  10000.00, -- L 10,000
  'Simple',
  '2024-01-01',
  '2024-12-31'
);
```

### 3.4 Crear Detalle de Préstamo

```sql
INSERT INTO tbprestamosdetalles (
  pres_id,
  prde_numeromes,
  prde_capital,
  prde_interes,
  prde_capitalrestante,
  prde_interesrestante,
  prde_fechapago
) VALUES (
  1,  -- ID del préstamo
  1,  -- Mes 1
  833.33,  -- Capital mensual
  129.17,  -- Interés mensual
  9166.67, -- Capital restante
  1550.00, -- Interés restante
  '2024-01-31'
);
```

## Paso 4: Configurar Políticas de Seguridad (Opcional pero Recomendado)

### 4.1 Habilitar RLS

```sql
-- Habilitar Row Level Security
ALTER TABLE tbusuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE tbclientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE tbprestamos ENABLE ROW LEVEL SECURITY;
ALTER TABLE tbprestamosdetalles ENABLE ROW LEVEL SECURITY;
```

### 4.2 Crear Políticas Básicas

```sql
-- Permitir lectura a usuarios autenticados
CREATE POLICY "Permitir lectura" ON tbusuarios
  FOR SELECT USING (true);

CREATE POLICY "Permitir lectura" ON tbclientes
  FOR SELECT USING (true);

CREATE POLICY "Permitir lectura" ON tbprestamos
  FOR SELECT USING (true);

CREATE POLICY "Permitir lectura" ON tbprestamosdetalles
  FOR SELECT USING (true);
```

## Paso 5: Ejecutar la Aplicación

### 5.1 Instalar Dependencias

```bash
cd c:/Users/Usuario/Desktop/Programacion/Coinly/Conly_Flutter/conly
flutter pub get
```

### 5.2 Conectar Dispositivo/Emulador

- **Dispositivo físico**: Conecta tu teléfono Android con USB debugging habilitado
- **Emulador**: Abre un emulador de Android desde Android Studio

Verifica que esté conectado:
```bash
flutter devices
```

### 5.3 Ejecutar

```bash
flutter run
```

### 5.4 Iniciar Sesión

Usa las credenciales del usuario de prueba:
- **Usuario**: `admin`
- **Contraseña**: `admin123`

## Paso 6: Verificar Funcionamiento

Después de iniciar sesión, deberías ver:

1. ✅ Pantalla de Home con estadísticas
2. ✅ Nombre del usuario en el header
3. ✅ Tarjetas con información:
   - Préstamos Activos: 1
   - Total Clientes: 1
   - Capital Prestado: L 10,000.00
   - Por Cobrar: (calculado)
4. ✅ Lista de préstamos recientes

## Solución de Problemas Comunes

### Error: "Invalid API key"
- Verifica que copiaste correctamente el `anon key` de Supabase
- Asegúrate de no tener espacios extra

### Error: "relation does not exist"
- Las tablas no se crearon correctamente
- Ve a Supabase → Table Editor y verifica que existan las tablas

### Error: "No rows returned"
- No hay datos de prueba
- Ejecuta los INSERT statements del Paso 3

### La app no compila
```bash
flutter clean
flutter pub get
flutter run
```

### Permisos de Android
- Si la app no se conecta a internet, verifica que `AndroidManifest.xml` tenga el permiso de INTERNET

## Próximos Pasos

Una vez que todo funcione:

1. **Seguridad**: Implementar hash de contraseñas
2. **Funcionalidades**: Agregar CRUD completo de clientes y préstamos
3. **UI**: Personalizar colores y diseño según tu marca
4. **Testing**: Probar en diferentes dispositivos Android

## Recursos Útiles

- [Documentación de Supabase](https://supabase.com/docs)
- [Documentación de Flutter](https://docs.flutter.dev)
- [Supabase Flutter Package](https://pub.dev/packages/supabase_flutter)

---

¿Necesitas ayuda? Revisa los logs de error en la consola de Flutter o en Supabase → Logs.
