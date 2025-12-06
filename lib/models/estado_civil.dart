class EstadoCivil {
  final int esciId;
  final String esciDescripcion;
  final bool esciEstado;

  EstadoCivil({
    required this.esciId,
    required this.esciDescripcion,
    this.esciEstado = true,
  });

  factory EstadoCivil.fromJson(Map<String, dynamic> json) {
    return EstadoCivil(
      esciId: json['esci_id'] as int,
      esciDescripcion: json['esci_descripcion'] as String,
      esciEstado: json['esci_estado'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'esci_id': esciId,
      'esci_descripcion': esciDescripcion,
      'esci_estado': esciEstado,
    };
  }
}
