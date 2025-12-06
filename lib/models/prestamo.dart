class Prestamo {
  final int presId;
  final int clieId;
  final int presTiempo;
  final double presTasaInteres;
  final int presNumeroCuotas;
  final double presCapitalInicial;
  final String presTipoInteres;
  final DateTime presFechaInicioPago;
  final DateTime presFechaFinPago;
  final bool presEstado;
  final DateTime? presFechaCreacion;

  // Campos adicionales para joins
  final String? clienteNombre;

  Prestamo({
    required this.presId,
    required this.clieId,
    required this.presTiempo,
    required this.presTasaInteres,
    required this.presNumeroCuotas,
    required this.presCapitalInicial,
    required this.presTipoInteres,
    required this.presFechaInicioPago,
    required this.presFechaFinPago,
    this.presEstado = true,
    this.presFechaCreacion,
    this.clienteNombre,
  });

  factory Prestamo.fromJson(Map<String, dynamic> json) {
    return Prestamo(
      presId: json['pres_id'] as int,
      clieId: json['clie_id'] as int,
      presTiempo: json['pres_tiempo'] as int,
      presTasaInteres: (json['pres_tasainteres'] as num).toDouble(),
      presNumeroCuotas: json['pres_numerocuotas'] as int,
      presCapitalInicial: (json['pres_capitalinicial'] as num).toDouble(),
      presTipoInteres: json['pres_tipointeres'] as String,
      presFechaInicioPago: DateTime.parse(
        json['pres_fechainiciopago'] as String,
      ),
      presFechaFinPago: DateTime.parse(json['pres_fechafinpago'] as String),
      presEstado: json['pres_estado'] as bool? ?? true,
      presFechaCreacion: json['pres_fechacreacion'] != null
          ? DateTime.parse(json['pres_fechacreacion'] as String)
          : null,
      clienteNombre: json['cliente_nombre'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pres_id': presId,
      'clie_id': clieId,
      'pres_tiempo': presTiempo,
      'pres_tasainteres': presTasaInteres,
      'pres_numerocuotas': presNumeroCuotas,
      'pres_capitalinicial': presCapitalInicial,
      'pres_tipointeres': presTipoInteres,
      'pres_fechainiciopago': presFechaInicioPago.toIso8601String(),
      'pres_fechafinpago': presFechaFinPago.toIso8601String(),
      'pres_estado': presEstado,
      'pres_fechacreacion': presFechaCreacion?.toIso8601String(),
    };
  }
}
