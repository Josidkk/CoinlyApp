class Usuario {
  final int usuaId;
  final String usuaUsuario;
  final String usuaNombres;
  final String usuaApellidos;
  final int? esciId;
  final String? muniCodigo;
  final int? roleId;
  final bool usuaEstado;
  final DateTime? usuaFechaCreacion;

  Usuario({
    required this.usuaId,
    required this.usuaUsuario,
    required this.usuaNombres,
    required this.usuaApellidos,
    this.esciId,
    this.muniCodigo,
    this.roleId,
    this.usuaEstado = true,
    this.usuaFechaCreacion,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      usuaId: json['usua_id'] as int,
      usuaUsuario: json['usua_usuario'] as String,
      usuaNombres: json['usua_nombres'] as String,
      usuaApellidos: json['usua_apellidos'] as String,
      esciId: json['esci_id'] as int?,
      muniCodigo: json['muni_codigo'] as String?,
      roleId:
          (json['Role_Id'] ?? json['role_id'])
              as int?, // Soportar ambas variantes
      usuaEstado: json['usua_estado'] as bool? ?? true,
      usuaFechaCreacion: json['usua_fechacreacion'] != null
          ? DateTime.parse(json['usua_fechacreacion'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usua_id': usuaId,
      'usua_usuario': usuaUsuario,
      'usua_nombres': usuaNombres,
      'usua_apellidos': usuaApellidos,
      'esci_id': esciId,
      'muni_codigo': muniCodigo,
      'role_id': roleId,
      'usua_estado': usuaEstado,
      'usua_fechacreacion': usuaFechaCreacion?.toIso8601String(),
    };
  }

  String get nombreCompleto => '$usuaNombres $usuaApellidos';
}
