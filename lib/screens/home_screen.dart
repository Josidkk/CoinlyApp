import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/usuario.dart';
import '../models/estadisticas_home.dart';
import '../models/prestamo_Detallado.dart';
import '../services/auth_service.dart';
import '../services/prestamo_service.dart';
import 'prestamos_screen.dart';
import 'detalle_prestamo_screen.dart';

import 'package:flutter/cupertino.dart'; // Para el pull-to-refresh
import 'package:flutter/services.dart';  // Para la vibración (HapticFeedback)


class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToPrestamos;
  
  const HomeScreen({super.key, this.onNavigateToPrestamos});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _prestamoService = PrestamoService();

  Usuario? _usuario;
  EstadisticasHome _estadisticas = EstadisticasHome.empty();
  List<Prestamo_Detallado_DTO> _prestamosRecientes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);

    try {
      // Cargar usuario actual
      _usuario = await _authService.obtenerUsuarioActual();

      // Cargar estadísticas
      _estadisticas = await _prestamoService.obtenerEstadisticas();

      // Cargar préstamos recientes
      _prestamosRecientes = await _prestamoService.obtenerPrestamosRecientes();
    } catch (e) {
      print('Error al cargar datos: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.6),
            radius: 1.2,
            colors: [
              const Color(0xFF1E293B).withOpacity(0.6),
              const Color(0xFF0F172A),
            ],
          ),
        ),
        child: _isLoading
    ? const Center(child: CircularProgressIndicator(color: Color(0xFFF59E0B)))
    // QUITAMOS EL RefreshIndicator AQUÍ
    : CustomScrollView(
        // ESTO ES CLAVE: Permite el rebote y estiramiento incluso en Android
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()), 
        slivers: [
          // AGREGAMOS EL REFRESH DE TIPO OVERSCROLL COMO EL PRIMER SLIVER
          CupertinoSliverRefreshControl(
            onRefresh: () async {
              // 1. Hacemos que el celular vibre ligeramente
              HapticFeedback.mediumImpact(); 
              
              // 2. Ejecutamos tu función de carga de datos
              await _cargarDatos();
            },
          ),
          
          // AppBar (Tu AppBar actual se queda igual)
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,

                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '¡Hola, ${(_usuario?.usuaNombres.split(' ')[0]) ?? 'Usuario'}!',
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Gestión Inteligente de Préstamos',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFF59E0B).withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFF59E0B).withOpacity(0.2),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _usuario?.usuaNombres.substring(0, 1).toUpperCase() ?? 'U',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFF59E0B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Contenido
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Estadísticas
                            Text(
                              'Resumen General',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          const SizedBox(height: 16),

                          // Tarjeta Principal: Capital y Por Cobrar
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF59E0B), Color(0xFFE35D5B)], // Naranja a Rojo vibrante
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF59E0B).withOpacity(0.3),
                                  blurRadius: 24,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  right: -20,
                                  top: -10,
                                  child: Icon(Icons.account_balance_wallet_rounded, size: 120, color: Colors.white.withOpacity(0.15)),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Capital Prestado Global', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatCurrency(_estadisticas.totalCapitalPrestado), 
                                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold, height: 1.1),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 28),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Total Por Cobrar', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 11)),
                                            Text(
                                              _formatCurrency(_estadisticas.totalPorCobrar), 
                                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.25),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.trending_up_rounded, color: Colors.white, size: 16),
                                              const SizedBox(width: 4),
                                              Text('Activo', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Cards Secundarios
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Préstamos Activos',
                                  _estadisticas.totalPrestamosActivos.toString(),
                                  Icons.receipt_long_rounded,
                                  const Color(0xFF3B82F6),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  'Gestión Clientes',
                                  _estadisticas.totalClientes.toString(),
                                  Icons.people_alt_rounded,
                                  const Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Préstamos Recientes
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Préstamos Recientes',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (widget.onNavigateToPrestamos != null) {
                                    widget.onNavigateToPrestamos!();
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const PrestamosScreen()),
                                    );
                                  }
                                },
                                child: Text(
                                  'Ver todos',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFFF59E0B),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Lista de préstamos recientes
                          if (_prestamosRecientes.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.inbox_outlined,
                                      size: 64,
                                      color: Colors.grey.shade300,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No hay préstamos registrados',
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey.shade500,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ...(_prestamosRecientes
                                .map((prestamo) => _buildPrestamoCard(prestamo))
                                .toList()),
                          const SizedBox(
                            height: 100,
                          ), // Espacio para navbar flotante
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(icon, color: const Color(0xFFF59E0B), size: 22),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrestamoCard(Prestamo_Detallado_DTO prestamo) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetallePrestamoScreen(prestamo: prestamo),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prestamo.clienteNombre,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Préstamo #${prestamo.base.id}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatCurrency(prestamo.base.capitalInicial),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(
                  Icons.calendar_today,
                  DateFormat('dd/MM/yyyy').format(prestamo.base.fechaInicioPago),
                ),
                const SizedBox(width: 8),
                _buildInfoChip(Icons.percent, '${prestamo.base.tasaInteres}%'),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.check_circle_outline,
                  prestamo.base.estado ? 'Activo' : 'Inactivo',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF718096)),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: 'L ', decimalDigits: 2);
    return formatter.format(amount);
  }
}
