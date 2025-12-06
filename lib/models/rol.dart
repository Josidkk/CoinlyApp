class Rol {
  final int roleId;
  final String roleDescripcion;
  final bool roleEstado;

  Rol({
    required this.roleId,
    required this.roleDescripcion,
    this.roleEstado = true,
  });

  factory Rol.fromJson(Map<String, dynamic> json) {
    return Rol(
      roleId: json['role_id'] as int,
      roleDescripcion: json['role_descripcion'] as String,
      roleEstado: json['role_estado'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role_id': roleId,
      'role_descripcion': roleDescripcion,
      'role_estado': roleEstado,
    };
  }
}
