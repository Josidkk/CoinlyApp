import 'usuario.dart';

class UsuarioDetallado {
  final Usuario usuario;
  final String? rolDescripcion;
  final String? estadoCivilDescripcion;
  final String? municipioDescripcion;
  final String? departamentoDescripcion;

  UsuarioDetallado({
    required this.usuario,
    this.rolDescripcion,
    this.estadoCivilDescripcion,
    this.municipioDescripcion,
    this.departamentoDescripcion,
  });

  factory UsuarioDetallado.fromJson(Map<String, dynamic> json) {
    return UsuarioDetallado(
      usuario: Usuario.fromJson(json),
      rolDescripcion: json['rol_descripcion'] as String?,
      estadoCivilDescripcion: json['estado_civil_descripcion'] as String?,
      municipioDescripcion: json['municipio_descripcion'] as String?,
      departamentoDescripcion: json['departamento_descripcion'] as String?,
    );
  }
}
