# 🛠️ Snippets Útiles para Desarrollo

## 📝 Consultas SQL Comunes

### Obtener préstamos con información del cliente
```sql
SELECT 
  p.*,
  c.clie_nombres,
  c.clie_apellidos,
  c.clie_nombres || ' ' || c.clie_apellidos as cliente_nombre
FROM tbprestamos p
INNER JOIN tbclientes c ON p.clie_id = c.clie_id
WHERE p.pres_estado = true
ORDER BY p.pres_fechacreacion DESC;
```

### Calcular total por cobrar de un préstamo
```sql
SELECT 
  pres_id,
  SUM(prde_capitalrestante + prde_interesrestante) as total_por_cobrar,
  SUM(prde_capitalpagado + prde_interespagado) as total_pagado
FROM tbprestamosdetalles
WHERE pres_id = 1 AND prde_estado = true
GROUP BY pres_id;
```

### Préstamos vencidos (cuotas atrasadas)
```sql
SELECT 
  p.*,
  c.clie_nombres || ' ' || c.clie_apellidos as cliente,
  pd.prde_fechapago,
  pd.prde_capitalrestante + pd.prde_interesrestante as monto_vencido
FROM tbprestamos p
INNER JOIN tbclientes c ON p.clie_id = c.clie_id
INNER JOIN tbprestamosdetalles pd ON p.pres_id = pd.pres_id
WHERE pd.prde_fechapago < CURRENT_DATE
  AND pd.prde_capitalrestante > 0
  AND p.pres_estado = true
  AND pd.prde_estado = true
ORDER BY pd.prde_fechapago ASC;
```

### Estadísticas por cliente
```sql
SELECT 
  c.clie_id,
  c.clie_nombres || ' ' || c.clie_apellidos as cliente,
  COUNT(p.pres_id) as total_prestamos,
  SUM(p.pres_capitalinicial) as total_prestado,
  SUM(pd.prde_capitalrestante + pd.prde_interesrestante) as total_pendiente
FROM tbclientes c
LEFT JOIN tbprestamos p ON c.clie_id = p.clie_id AND p.pres_estado = true
LEFT JOIN tbprestamosdetalles pd ON p.pres_id = pd.pres_id AND pd.prde_estado = true
WHERE c.clie_estado = true
GROUP BY c.clie_id, c.clie_nombres, c.clie_apellidos
ORDER BY total_prestado DESC;
```

## 🎨 Widgets Reutilizables

### Card con Sombra
```dart
Widget buildCard({
  required Widget child,
  EdgeInsets? padding,
  Color? color,
}) {
  return Container(
    padding: padding ?? const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
}
```

### Botón Primario
```dart
Widget buildPrimaryButton({
  required String text,
  required VoidCallback onPressed,
  bool isLoading = false,
}) {
  return SizedBox(
    height: 56,
    width: double.infinity,
    child: ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    ),
  );
}
```

### Input Field Personalizado
```dart
Widget buildTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  bool obscureText = false,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    obscureText: obscureText,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
        color: const Color(0xFF718096),
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF667eea),
      ),
      filled: true,
      fillColor: const Color(0xFFF7FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF667eea),
          width: 2,
        ),
      ),
    ),
    validator: validator,
  );
}
```

### Diálogo de Confirmación
```dart
Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Confirmar',
  String cancelText = 'Cancelar',
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      content: Text(
        message,
        style: GoogleFonts.poppins(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            cancelText,
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667eea),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            confirmText,
            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
```

## 🔧 Funciones Útiles

### Formatear Moneda
```dart
String formatCurrency(double amount) {
  final formatter = NumberFormat.currency(
    symbol: 'L ',
    decimalDigits: 2,
  );
  return formatter.format(amount);
}
```

### Formatear Fecha
```dart
String formatDate(DateTime date) {
  return DateFormat('dd/MM/yyyy').format(date);
}

String formatDateTime(DateTime date) {
  return DateFormat('dd/MM/yyyy HH:mm').format(date);
}
```

### Validadores de Formulario
```dart
String? validateRequired(String? value) {
  if (value == null || value.isEmpty) {
    return 'Este campo es requerido';
  }
  return null;
}

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'El email es requerido';
  }
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Email inválido';
  }
  return null;
}

String? validatePhone(String? value) {
  if (value == null || value.isEmpty) {
    return 'El teléfono es requerido';
  }
  if (value.length < 8) {
    return 'El teléfono debe tener al menos 8 dígitos';
  }
  return null;
}

String? validateNumber(String? value) {
  if (value == null || value.isEmpty) {
    return 'Este campo es requerido';
  }
  if (double.tryParse(value) == null) {
    return 'Debe ser un número válido';
  }
  return null;
}
```

### Mostrar SnackBar
```dart
void showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green.shade400,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}

void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red.shade400,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}
```

## 📱 Navegación

### Navegar a Nueva Pantalla
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const NuevaPantalla(),
  ),
);
```

### Navegar y Reemplazar
```dart
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => const NuevaPantalla(),
  ),
);
```

### Navegar y Limpiar Stack
```dart
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(
    builder: (context) => const NuevaPantalla(),
  ),
  (route) => false,
);
```

### Volver con Datos
```dart
// En la pantalla de destino
Navigator.pop(context, resultado);

// En la pantalla origen
final resultado = await Navigator.push(...);
if (resultado != null) {
  // Usar resultado
}
```

## 🗄️ Consultas Supabase

### Select Simple
```dart
final response = await _supabase
    .from('tbprestamos')
    .select()
    .eq('pres_estado', true);
```

### Select con Join
```dart
final response = await _supabase
    .from('tbprestamos')
    .select('''
      *,
      tbclientes!inner(clie_nombres, clie_apellidos)
    ''')
    .eq('pres_estado', true);
```

### Insert
```dart
await _supabase
    .from('tbclientes')
    .insert({
      'clie_nombres': 'Juan',
      'clie_apellidos': 'Pérez',
      'usua_creacion': usuarioId,
    });
```

### Update
```dart
await _supabase
    .from('tbclientes')
    .update({
      'clie_nombres': 'Juan Carlos',
      'usua_modificacion': usuarioId,
      'clie_fechamodificacion': DateTime.now().toIso8601String(),
    })
    .eq('clie_id', clienteId);
```

### Delete (Soft Delete)
```dart
await _supabase
    .from('tbclientes')
    .update({
      'clie_estado': false,
      'usua_modificacion': usuarioId,
      'clie_fechamodificacion': DateTime.now().toIso8601String(),
    })
    .eq('clie_id', clienteId);
```

### Búsqueda
```dart
final response = await _supabase
    .from('tbclientes')
    .select()
    .ilike('clie_nombres', '%$busqueda%')
    .eq('clie_estado', true);
```

### Ordenar y Limitar
```dart
final response = await _supabase
    .from('tbprestamos')
    .select()
    .eq('pres_estado', true)
    .order('pres_fechacreacion', ascending: false)
    .limit(10);
```

## 🎯 Manejo de Estados

### Loading State
```dart
class MiPantalla extends StatefulWidget {
  @override
  State<MiPantalla> createState() => _MiPantallaState();
}

class _MiPantallaState extends State<MiPantalla> {
  bool _isLoading = false;

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    
    try {
      // Cargar datos
    } catch (e) {
      // Manejar error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return // Tu UI
  }
}
```

## 🔒 Políticas RLS Recomendadas

### Permitir lectura solo a usuarios autenticados
```sql
CREATE POLICY "Usuarios autenticados pueden leer"
ON tbprestamos FOR SELECT
USING (auth.role() = 'authenticated');
```

### Permitir inserción solo con usuario válido
```sql
CREATE POLICY "Usuarios pueden insertar"
ON tbprestamos FOR INSERT
WITH CHECK (
  auth.role() = 'authenticated' AND
  usua_creacion IN (
    SELECT usua_id FROM tbusuarios WHERE usua_estado = true
  )
);
```

## 📊 Cálculos Comunes

### Calcular Cuota Mensual (Interés Simple)
```dart
double calcularCuotaMensual({
  required double capital,
  required double tasaInteres,
  required int numeroCuotas,
}) {
  final interesTotal = capital * (tasaInteres / 100);
  final totalAPagar = capital + interesTotal;
  return totalAPagar / numeroCuotas;
}
```

### Calcular Cuota Mensual (Interés Compuesto)
```dart
double calcularCuotaMensualCompuesto({
  required double capital,
  required double tasaInteresAnual,
  required int numeroCuotas,
}) {
  final tasaMensual = tasaInteresAnual / 12 / 100;
  final cuota = capital * 
    (tasaMensual * pow(1 + tasaMensual, numeroCuotas)) /
    (pow(1 + tasaMensual, numeroCuotas) - 1);
  return cuota;
}
```

---

**Tip**: Guarda estos snippets en tu IDE para acceso rápido!
