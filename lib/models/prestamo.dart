class Prestamo {
  final int id;
  final int clienteId;
  final double tasaInteres;
  final double capitalInicial;
  final DateTime fechaInicioPago;
  final bool estado;
  final double capitalPagado;
  final double interesPagado;
  final double interesPendiente;

  Prestamo({
    required this.id,
    required this.clienteId,
    required this.tasaInteres,
    required this.capitalInicial,
    required this.fechaInicioPago,
    required this.estado,
    required this.capitalPagado,
    required this.interesPagado,
    required this.interesPendiente,
  });

  // Transforma el mapa de la base de datos en un objeto firme
  factory Prestamo.fromMap(Map<String, dynamic> map) {
    return Prestamo(
      id: map['pres_id'],
      clienteId: map['clie_id'],
      // Conversión de String/Decimal a double para cálculos precisos
      tasaInteres: double.parse(map['pres_tasaInteres'].toString()),
      capitalInicial: double.parse(map['pres_capitalInicial'].toString()),
      fechaInicioPago: DateTime.parse(map['pres_fechaInicioPago']),
      estado: map['pres_estado'] ?? false,
      capitalPagado: double.parse(map['pres_capitalPagado'].toString()),
      interesPagado: double.parse(map['pres_interesPagado'].toString()),
      interesPendiente: map['pres_interesPendiente'] != null ? double.parse(map['pres_interesPendiente'].toString()) : 0.0,
    );
  }

  /// Alias de [fromMap] para compatibilidad con respuestas JSON de Supabase.
  factory Prestamo.fromJson(Map<String, dynamic> json) => Prestamo.fromMap(json);

  // Prepara los datos para ser guardados (Base de Datos)
  Map<String, dynamic> toMap() {
    return {
      'pres_id': id,
      'clie_id': clienteId,
      'pres_tasaInteres': tasaInteres.toString(),
      'pres_capitalInicial': capitalInicial.toString(),
      'pres_fechaInicioPago': fechaInicioPago.toIso8601String(),
      'pres_estado': estado,
      'pres_capitalPagado': capitalPagado.toString(),
      'pres_interesPagado': interesPagado.toString(),
      'pres_interesPendiente': interesPendiente.toString(),
    };
  }
}