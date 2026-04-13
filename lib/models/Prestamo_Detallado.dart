import 'prestamo.dart';

class Prestamo_Detallado_DTO {
  final Prestamo base; // La estructura fundamental del préstamo (campos reales de la tabla)
  final String clienteNombre; // Nombre completo forjado desde el JOIN con tbclientes

  Prestamo_Detallado_DTO({
    required this.base,
    required this.clienteNombre,
  });

  factory Prestamo_Detallado_DTO.fromMap(Map<String, dynamic> map) {
    // 1. Extraemos los datos del cliente que vienen del join 'tbclientes'
    final clienteData = map['tbclientes'] ?? {};
    final nombreCompleto =
        '${clienteData['clie_nombres'] ?? ''} ${clienteData['clie_apellidos'] ?? ''}'
            .trim();

    return Prestamo_Detallado_DTO(
      // 2. Delegamos la creación de la base al modelo original
      base: Prestamo.fromMap(map),
      // 3. Asignamos el nombre con fallback si el join falla
      clienteNombre: nombreCompleto.isNotEmpty
          ? nombreCompleto
          : (map['cliente_nombre'] ?? 'Cliente Desconocido'),
    );
  }
}