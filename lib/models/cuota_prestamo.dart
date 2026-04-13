class CuotaPrestamo {
  final int prdeId;
  final DateTime fechapago;
  final double capital;
  final double interes;
  final double montoCuota;
  final double capitalrestante;
  final double interesrestante;
  final bool estado;

  CuotaPrestamo({
    required this.prdeId,
    required this.fechapago,
    required this.capital,
    required this.interes,
    required this.montoCuota,
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
      fechapago: getField('prde_fechaPago') != null 
          ? DateTime.parse(getField('prde_fechaPago').toString())
          : DateTime.now(),
      capital: toDouble(getField('prde_abonoCapital')),
      interes: toDouble(getField('prde_abonoInteres')),
      montoCuota: toDouble(getField('monto_cuota')),
      capitalrestante: toDouble(getField('prde_capitalRestante')),
      interesrestante: toDouble(getField('prde_interesRestante')),
      estado: getField('prde_estado') == true,
    );
  }
}
