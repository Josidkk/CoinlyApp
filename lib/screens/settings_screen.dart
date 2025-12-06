import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();
  Usuario? _usuario;
  String? _rolDescripcion;
  String? _estadoCivilDescripcion;
  String? _municipioDescripcion;
  String? _departamentoDescripcion;
  bool _isLoading = true;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);

    print('=== INICIO CARGA DE DATOS ===');

    // Cargar usuario básico
    _usuario = await _authService.obtenerUsuarioActual();
    print('Usuario básico cargado: ${_usuario?.usuaId}');
    print('Role ID del usuario: ${_usuario?.roleId}');
    print('Municipio código: ${_usuario?.muniCodigo}');
    print('Estado civil ID: ${_usuario?.esciId}');

    // Cargar datos detallados
    print('Llamando a obtenerUsuarioDetallado...');
    final usuarioDetallado = await _authService.obtenerUsuarioDetallado();
    print('Usuario detallado recibido: $usuarioDetallado');

    if (usuarioDetallado != null) {
      print('Procesando datos detallados...');
      _rolDescripcion = usuarioDetallado['rol_descripcion'] as String?;
      _estadoCivilDescripcion =
          usuarioDetallado['estado_civil_descripcion'] as String?;
      _municipioDescripcion =
          usuarioDetallado['municipio_descripcion'] as String?;
      _departamentoDescripcion =
          usuarioDetallado['departamento_descripcion'] as String?;

      print('Rol: $_rolDescripcion');
      print('Estado Civil: $_estadoCivilDescripcion');
      print('Municipio: $_municipioDescripcion');
      print('Departamento: $_departamentoDescripcion');
    } else {
      print('ERROR: usuarioDetallado es null');
    }

    print('=== FIN CARGA DE DATOS ===');

    // TODO: Cargar preferencia de tema desde storage
    setState(() => _isLoading = false);
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '¿Cerrar Sesión?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          '¿Estás seguro que deseas cerrar sesión?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Cerrar Sesión',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '⚠️ Eliminar Cuenta',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.red.shade700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Esta acción es irreversible. Se eliminarán:',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            _buildWarningItem('• Toda tu información personal'),
            _buildWarningItem('• Historial de préstamos'),
            _buildWarningItem('• Configuraciones'),
            const SizedBox(height: 12),
            Text(
              '¿Estás completamente seguro?',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Eliminar',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // TODO: Implementar eliminación de cuenta en el servicio
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Funcionalidad de eliminación de cuenta en desarrollo',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.orange.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7FAFC),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF667eea),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.white,
                              child: Text(
                                _usuario?.usuaNombres
                                        .substring(0, 1)
                                        .toUpperCase() ??
                                    'U',
                                style: GoogleFonts.poppins(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF667eea),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _usuario?.nombreCompleto ?? 'Usuario',
                                    style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '@${_usuario?.usuaUsuario ?? 'usuario'}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Contenido
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información de la Cuenta
                  Text(
                    'Información de la Cuenta',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2d3748),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildInfoCard(),

                  const SizedBox(height: 32),

                  // Apariencia
                  Text(
                    'Apariencia',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2d3748),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildThemeCard(),

                  const SizedBox(height: 32),

                  // Acciones
                  Text(
                    'Acciones',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2d3748),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildActionCard(
                    icon: Icons.logout,
                    title: 'Cerrar Sesión',
                    subtitle: 'Salir de tu cuenta',
                    color: const Color(0xFF667eea),
                    onTap: _handleLogout,
                  ),

                  const SizedBox(height: 12),

                  _buildActionCard(
                    icon: Icons.delete_forever,
                    title: 'Eliminar Cuenta',
                    subtitle: 'Eliminar permanentemente tu cuenta',
                    color: Colors.red.shade600,
                    onTap: _handleDeleteAccount,
                  ),

                  const SizedBox(height: 32),

                  // Versión
                  Center(
                    child: Text(
                      'Versión 1.0.0',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 100), // Espacio para el navbar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'Nombre Completo',
            value: _usuario?.nombreCompleto ?? 'N/A',
          ),
          const Divider(height: 32),
          _buildInfoRow(
            icon: Icons.account_circle_outlined,
            label: 'Usuario',
            value: _usuario?.usuaUsuario ?? 'N/A',
          ),
          const Divider(height: 32),
          _buildInfoRow(
            icon: Icons.badge_outlined,
            label: 'ID de Usuario',
            value: '#${_usuario?.usuaId ?? 'N/A'}',
          ),
          const Divider(height: 32),
          _buildInfoRow(
            icon: Icons.admin_panel_settings_outlined,
            label: 'Rol',
            value: _rolDescripcion ?? 'N/A',
          ),
          const Divider(height: 32),
          _buildInfoRow(
            icon: Icons.favorite_outline,
            label: 'Estado Civil',
            value: _estadoCivilDescripcion ?? 'N/A',
          ),
          const Divider(height: 32),
          _buildInfoRow(
            icon: Icons.location_city_outlined,
            label: 'Municipio',
            value: _municipioDescripcion ?? 'N/A',
          ),
          const Divider(height: 32),
          _buildInfoRow(
            icon: Icons.map_outlined,
            label: 'Departamento',
            value: _departamentoDescripcion ?? 'N/A',
          ),
          const Divider(height: 32),
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Fecha de Registro',
            value: _usuario?.usuaFechaCreacion != null
                ? '${_usuario!.usuaFechaCreacion!.day}/${_usuario!.usuaFechaCreacion!.month}/${_usuario!.usuaFechaCreacion!.year}'
                : 'N/A',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF667eea).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF667eea), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2d3748),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: const Color(0xFF667eea),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tema Oscuro',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2d3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isDarkMode ? 'Activado' : 'Desactivado',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isDarkMode,
            onChanged: (value) {
              setState(() => _isDarkMode = value);
              // TODO: Guardar preferencia y aplicar tema
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Tema oscuro ${value ? 'activado' : 'desactivado'} (próximamente)',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: const Color(0xFF667eea),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            activeColor: const Color(0xFF667eea),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2d3748),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
