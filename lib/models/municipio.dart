class Municipio {
  final String muniCodigo;
  final String muniDescripcion;
  final String depaCodigo;
  final bool muniEstado;

  Municipio({
    required this.muniCodigo,
    required this.muniDescripcion,
    required this.depaCodigo,
    this.muniEstado = true,
  });

  factory Municipio.fromJson(Map<String, dynamic> json) {
    return Municipio(
      muniCodigo: json['muni_codigo'] as String,
      muniDescripcion: json['muni_descripcion'] as String,
      depaCodigo: json['depa_codigo'] as String,
      muniEstado: json['muni_estado'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'muni_codigo': muniCodigo,
      'muni_descripcion': muniDescripcion,
      'depa_codigo': depaCodigo,
      'muni_estado': muniEstado,
    };
  }
}
