class Departamento {
  final String depaCodigo;
  final String depaDescripcion;
  final bool depaEstado;

  Departamento({
    required this.depaCodigo,
    required this.depaDescripcion,
    this.depaEstado = true,
  });

  factory Departamento.fromJson(Map<String, dynamic> json) {
    return Departamento(
      depaCodigo: json['depa_codigo'] as String,
      depaDescripcion: json['depa_descripcion'] as String,
      depaEstado: json['depa_estado'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'depa_codigo': depaCodigo,
      'depa_descripcion': depaDescripcion,
      'depa_estado': depaEstado,
    };
  }
}
