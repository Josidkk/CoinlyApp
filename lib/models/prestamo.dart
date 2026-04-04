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
  
  // Campos calculados por RPC
  final int diasAtraso;
  final bool estaEnMora;
  
  // Nuevos campos financieros del RPC
  final double capitalPagado;
  final double interesPagado;
  final double moraPagada;
  final double moraPendiente;
  final double interesPlanificado;

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
    this.diasAtraso = 0,
    this.estaEnMora = false,
    this.capitalPagado = 0.0,
    this.interesPagado = 0.0,
    this.moraPagada = 0.0,
    this.moraPendiente = 0.0,
    this.interesPlanificado = 0.0,
  });

  factory Prestamo.fromJson(Map<String, dynamic> json) {
    // Supabase devuelve los nombres de columna exactamente como los tienes en 
    // Postgres (con comillas), por eso usamos camelCase igual que en la tabla.
    // Además, las columnas 'numeric' suelen llegar como String ("5000.00").
    
    double parseDoubleSafely(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseIntSafely(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return Prestamo(
      presId: parseIntSafely(json['pres_id']),
      clieId: parseIntSafely(json['clie_id']),
      presTiempo: parseIntSafely(json['pres_tiempo']),
      presTasaInteres: parseDoubleSafely(json['pres_tasaInteres'] ?? json['pres_tasainteres']),
      presNumeroCuotas: parseIntSafely(json['pres_numeroCuotas'] ?? json['pres_numerocuotas']),
      presCapitalInicial: parseDoubleSafely(json['pres_capitalInicial'] ?? json['pres_capitalinicial']),
      presTipoInteres: (json['pres_tipoInteres'] ?? json['pres_tipointeres'] ?? '') as String,
      presFechaInicioPago: DateTime.parse(
        (json['pres_fechaInicioPago'] ?? json['pres_fechainiciopago']) as String,
      ),
      presFechaFinPago: DateTime.parse(
        (json['pres_fechaFinPago'] ?? json['pres_fechafinpago']) as String,
      ),
      presEstado: json['pres_estado'] as bool? ?? true,
      presFechaCreacion: (json['pres_fechaCreacion'] ?? json['pres_fechacreacion']) != null
          ? DateTime.parse((json['pres_fechaCreacion'] ?? json['pres_fechacreacion']) as String)
          : null,
      clienteNombre: json['cliente_nombre'] as String?,
      diasAtraso: parseIntSafely(json['dias_atraso']),
      estaEnMora: json['esta_en_mora'] as bool? ?? false,
      capitalPagado: parseDoubleSafely(json['capital_pagado']),
      interesPagado: parseDoubleSafely(json['interes_pagado']),
      moraPagada: parseDoubleSafely(json['mora_pagada']),
      moraPendiente: parseDoubleSafely(json['mora_pendiente']),
      interesPlanificado: parseDoubleSafely(json['interes_planificado']),
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
