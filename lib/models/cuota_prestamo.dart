class CuotaPrestamo {
  final int prdeId;
  final int numeromes;
  final DateTime fechapago;
  final DateTime? fechapagorealizado;
  final double capital;
  final double interes;
  final double montoCuota;
  final double capitalpagado;
  final double interespagado;
  final double capitalrestante;
  final double interesrestante;
  final bool estado;

  CuotaPrestamo({
    required this.prdeId,
    required this.numeromes,
    required this.fechapago,
    this.fechapagorealizado,
    required this.capital,
    required this.interes,
    required this.montoCuota,
    required this.capitalpagado,
    required this.interespagado,
    required this.capitalrestante,
    required this.interesrestante,
    required this.estado,
  });

  factory CuotaPrestamo.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    int toInt(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    // Helper para buscar llave ignorando case si falla la exacta (robustez)
    dynamic getField(String key) {
      if (json.containsKey(key)) return json[key];
      // Intento fallback lowercase
      final lowerKey = key.toLowerCase();
      if (json.containsKey(lowerKey)) return json[lowerKey];
      return null;
    }

    return CuotaPrestamo(
      prdeId: toInt(getField('prde_id')),
      numeromes: toInt(getField('prde_numeroMes')),
      fechapago: getField('prde_fechaPago') != null 
          ? DateTime.parse(getField('prde_fechaPago').toString())
          : DateTime.now(),
      fechapagorealizado: getField('prde_fechaPagorealizado') != null
          ? DateTime.tryParse(getField('prde_fechaPagorealizado').toString())
          : null,
      capital: toDouble(getField('prde_capital')),
      interes: toDouble(getField('prde_interes')),
      montoCuota: toDouble(getField('monto_cuota')),
      capitalpagado: toDouble(getField('prde_capitalPagado')),
      interespagado: toDouble(getField('prde_interesPagado')),
      capitalrestante: toDouble(getField('prde_capitalRestante')),
      interesrestante: toDouble(getField('prde_interesRestante')),
      estado: getField('prde_estado') == true,
    );
  }
}
