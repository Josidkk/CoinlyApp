import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/prestamo.dart';
import '../services/prestamo_service.dart';
import 'detalle_prestamo_screen.dart';

class PrestamosScreen extends StatefulWidget {
  const PrestamosScreen({super.key});

  @override
  State<PrestamosScreen> createState() => _PrestamosScreenState();
}

class _PrestamosScreenState extends State<PrestamosScreen> with SingleTickerProviderStateMixin {
  final _prestamoService = PrestamoService();
  List<Prestamo> _prestamos = [];
  List<Prestamo> _filteredPrestamos = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  String _currentFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _cargarPrestamos();
    _searchController.addListener(_filtrarPrestamos);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    String filter = 'Todos';
    if (_tabController.index == 1) filter = 'En Mora';
    if (_tabController.index == 2) filter = 'Al Día';
    
    setState(() {
      _currentFilter = filter;
      _filtrarPrestamos();
    });
  }

  Future<void> _cargarPrestamos() async {
    setState(() => _isLoading = true);
    final prestamos = await _prestamoService.obtenerTodosPrestamos();
   
    setState(() {
       print('=== PRESTAMOS CARGADOS: ${prestamos} ===');
      _prestamos = prestamos;
      _filtrarPrestamos();
      _isLoading = false;
    });
  }

  void _filtrarPrestamos() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredPrestamos = _prestamos.where((p) {
        final nombreMatches = (p.clienteNombre ?? '').toLowerCase().contains(query);
        final idMatches = p.presId.toString().contains(query);
        
        // Filtro por estado real desde RPC
        bool isMora = p.estaEnMora; 
        
        bool statusMatches = true;
        if (_currentFilter == 'En Mora') statusMatches = isMora;
        if (_currentFilter == 'Al Día') statusMatches = !isMora;

        return (nombreMatches || idMatches) && statusMatches;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFF59E0B);
    const darkBg = Color(0xFF0F172A);
    const surfaceColor = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: darkBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchAndTabs(primaryOrange, surfaceColor),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: primaryOrange))
                  : _filteredPrestamos.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _cargarPrestamos,
                          color: primaryOrange,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _filteredPrestamos.length,
                            itemBuilder: (context, index) {
                              final prestamo = _filteredPrestamos[index];
                              return _buildAdvancedLoanCard(prestamo, primaryOrange, surfaceColor);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    const primaryOrange = Color(0xFFF59E0B);
    return Padding(
      // Aumentamos el padding superior (de 10 a 24) y a los lados para que respire más y no esté pegado al techo
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Asegura que el texto y el botón estén alineados verticalmente en el centro
        children: [
          Expanded(
            child: Text(
              'Cartera de Préstamos',
              style: GoogleFonts.poppins(
                fontSize: 22, // Un poco más grande para mejor jerarquía
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ),
          // Botón de nuevo préstamo mejorado
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // TODO: Navigator.push(context, MaterialPageRoute(builder: (context) => NuevoPrestamoScreen()));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Crear nuevo préstamo (Próximamente)')),
                );
              },
              borderRadius: BorderRadius.circular(14), // Bordes más modernos
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Más gordito para que sea fácil de tocar
                decoration: BoxDecoration(
                  color: primaryOrange,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: primaryOrange.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded, color: Colors.white, size: 18), // Icono un poco más grueso/definido
                    const SizedBox(width: 6),
                    Text(
                      'Nuevo',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14, // Fuente sutilmente más grande
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndTabs(Color primaryOrange, Color surfaceColor) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar cliente...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                prefixIcon: Icon(Icons.search, color: primaryOrange),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),
        ),
        TabBar(
          controller: _tabController,
          indicatorColor: primaryOrange,
          indicatorWeight: 3,
          labelColor: primaryOrange,
          unselectedLabelColor: Colors.white.withOpacity(0.4),
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Todos'),
            Tab(text: 'En Mora'),
            Tab(text: 'Al Día'),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildAdvancedLoanCard(Prestamo prestamo, Color primaryOrange, Color surfaceColor) {
    bool isMora = prestamo.estaEnMora;
    // Cálculo real del progreso basado en capital pagado vs capital inicial
    double progress = prestamo.presCapitalInicial > 0 
        ? (prestamo.capitalPagado / prestamo.presCapitalInicial).clamp(0.0, 1.0)
        : 0.0;
    
    // Cálculo del saldo pendiente total (Capital Restante + Mora Pendiente)
    // Nota: El RPC devuelve acumulados, así que calculamos el pendiente
    double capitalPendiente = prestamo.presCapitalInicial - prestamo.capitalPagado;
    double totalPendiente = capitalPendiente + prestamo.moraPendiente;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isMora ? Colors.red.withOpacity(0.3) : Colors.white.withOpacity(0.05),
          width: isMora ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetallePrestamoScreen(prestamo: prestamo),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila Superior: Nombre y Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prestamo.clienteNombre ?? 'Sin Nombre',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 17,
                            ),
                          ),
                          Text(
                            'Préstamo #${prestamo.presId}',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(isMora),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Métricas principales
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetric('Monto Total', prestamo.presCapitalInicial, isCurrency: true),
                    _buildMetric('Pendiente', totalPendiente, isCurrency: true, highlight: isMora),
                    _buildMetric('Mora', prestamo.moraPendiente, isCurrency: true, highlight: prestamo.moraPendiente > 0),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Barra de Progreso
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progreso de Pago',
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.white.withOpacity(0.4)),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: GoogleFonts.poppins(
                            fontSize: 11, 
                            fontWeight: FontWeight.bold,
                            color: primaryOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.05),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isMora ? Colors.redAccent : primaryOrange
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Footer con fecha
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_month_outlined, size: 14, color: Colors.white.withOpacity(0.4)),
                        const SizedBox(width: 4),
                        Text(
                          'Inició: ${DateFormat('dd/MM/yy').format(prestamo.presFechaInicioPago)}',
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.white.withOpacity(0.4)),
                        ),
                      ],
                    ),
                    Text(
                      isMora ? '¡${prestamo.diasAtraso} días de atraso!' : 'Al día',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isMora ? Colors.redAccent : Colors.greenAccent.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isMora) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isMora ? Colors.red.withOpacity(0.15) : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMora ? Colors.red.withOpacity(0.3) : Colors.green.withOpacity(0.2),
        ),
      ),
      child: Text(
        isMora ? 'EN MORA' : 'AL DÍA',
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isMora ? Colors.redAccent : Colors.greenAccent,
        ),
      ),
    );
  }

  Widget _buildMetric(String label, dynamic value, {required bool isCurrency, bool highlight = false}) {
    String displayValue = isCurrency 
      ? NumberFormat.compactCurrency(symbol: 'L ', decimalDigits: 1).format(value)
      : value.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.white.withOpacity(0.3)),
        ),
        const SizedBox(height: 2),
        Text(
          displayValue,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: highlight ? Colors.redAccent : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 16),
          Text(
            'No hay préstamos en esta categoría',
            style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.3)),
          ),
        ],
      ),
    );
  }
}
