import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);

    try {
      // Cargar usuario básico
      _usuario = await _authService.obtenerUsuarioActual();
      
      // Cargar datos detallados
      final usuarioDetallado = await _authService.obtenerUsuarioDetallado();

      if (usuarioDetallado != null) {
        _rolDescripcion = usuarioDetallado['rol_descripcion'] as String?;
        _estadoCivilDescripcion = usuarioDetallado['estado_civil_descripcion'] as String?;
        _municipioDescripcion = usuarioDetallado['municipio_descripcion'] as String?;
        _departamentoDescripcion = usuarioDetallado['departamento_descripcion'] as String?;
      }
    } catch (e) {
      print('Error cargando datos de configuración: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono de Cabecera
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFF59E0B),
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              // Título
              Text(
                '¿Cerrar Sesión?',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              // Descripción
              Text(
                '¿Estás seguro que deseas salir? Tendrás que ingresar tus credenciales nuevamente.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              // Botones
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.4),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Confirmar',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFF59E0B))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Perfil Hero Header - Diseño Minimalista
          SliverAppBar(
            expandedHeight: 240,
            collapsedHeight: kToolbarHeight + 20,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF0F172A),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                ),
                child: Stack(
                  children: [
                    // Círculo decorativo de fondo (Glow sutil)
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFF59E0B).withOpacity(0.15),
                              const Color(0xFFF59E0B).withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                        const SizedBox(height: 40),
                        // Avatar con Anillo de Luz
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFF59E0B).withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFF59E0B),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF59E0B).withOpacity(0.15),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _usuario?.usuaNombres.isNotEmpty == true 
                                  ? _usuario!.usuaNombres.substring(0, 1).toUpperCase() 
                                  : 'U',
                              style: GoogleFonts.poppins(
                                fontSize: 40, 
                                fontWeight: FontWeight.bold, 
                                color: const Color(0xFFF59E0B)
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _usuario?.nombreCompleto ?? 'Usuario',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '@${_usuario?.usuaUsuario ?? 'usuario'}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 13, 
                              color: const Color(0xFFF59E0B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                ),
              ),
            ),
          ),

          // Contenido de Configuración
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader('INFORMACIÓN PERSONAL'),
                const SizedBox(height: 16),
                _buildInfoCard(),
                
                const SizedBox(height: 40),
                
                _buildSectionHeader('HERRAMIENTAS'),
                const SizedBox(height: 16),
                _buildActionCard(
                  icon: Icons.logout_rounded,
                  title: 'Cerrar Sesión',
                  subtitle: 'Salir de la aplicación de forma segura',
                  color: const Color(0xFFF59E0B),
                  onTap: _handleLogout,
                ),

                const SizedBox(height: 60),
                
                Center(
                  child: Column(
                    children: [
                      Text(
                        'CoinlyApp',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      Text(
                        'Versión 1.2.0 - Build Estable',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: Colors.white.withOpacity(0.3),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.badge_outlined, 'Identificador', '#${_usuario?.usuaId ?? '---'}'),
          _buildInfoRow(Icons.admin_panel_settings_outlined, 'Rol del Sistema', _rolDescripcion ?? '---'),
          _buildInfoRow(Icons.favorite_outline_rounded, 'Estado Civil', _estadoCivilDescripcion ?? '---'),
          _buildInfoRow(Icons.location_on_outlined, 'Municipio', _municipioDescripcion ?? '---'),
          _buildInfoRow(Icons.map_outlined, 'Departamento', _departamentoDescripcion ?? '---'),
          _buildInfoRow(
            Icons.calendar_month_rounded, 
            'Registro', 
            _usuario?.usuaFechaCreacion != null ? DateFormat('dd MMM yyyy').format(_usuario!.usuaFechaCreacion!) : '---',
            isLast: true
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.white.withOpacity(0.03))),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFF59E0B).withOpacity(0.5), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white.withOpacity(0.3))),
                Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9))),
              ],
            ),
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.4))),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white.withOpacity(0.2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
