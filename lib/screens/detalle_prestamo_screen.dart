import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/prestamo_Detallado.dart';
import '../models/cuota_prestamo.dart';
import '../services/prestamo_service.dart';

class DetallePrestamoScreen extends StatefulWidget {
  final Prestamo_Detallado_DTO prestamo;

  const DetallePrestamoScreen({super.key, required this.prestamo});

  @override
  State<DetallePrestamoScreen> createState() => _DetallePrestamoScreenState();
}

class _DetallePrestamoScreenState extends State<DetallePrestamoScreen> {
  
  final _prestamoService = PrestamoService();
  List<CuotaPrestamo> _cuotas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    setState(() => _isLoading = true);
    final cuotas = await _prestamoService.obtenerDetallePrestamo(widget.prestamo.base.id);
    setState(() {
      _cuotas = cuotas;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFF59E0B);
    const darkBg = Color(0xFF0F172A);
    const surfaceColor = Color(0xFF1E293B);

    final double capitalPagado = widget.prestamo.base.capitalPagado;
    final double capitalInicial = widget.prestamo.base.capitalInicial;
    final double interesPendiente = widget.prestamo.base.interesPendiente;
    final bool isFullyPaid = (capitalInicial - capitalPagado <= 0.01) && (interesPendiente <= 0.01);

    return Scaffold(
      backgroundColor: darkBg,
      floatingActionButton: isFullyPaid ? null : FloatingActionButton.extended(
        onPressed: () => _mostrarBottomSheetAbono(context),
        backgroundColor: primaryOrange,
        icon: const Icon(Icons.payments_rounded, color: Colors.white),
        label: Text('Abonar', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      bottomNavigationBar: isFullyPaid 
          ? SafeArea(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.withOpacity(0.3), width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Préstamo Finalizado', style: GoogleFonts.poppins(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Este préstamo ya fue saldado completamente en capital e interés.', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: CustomScrollView(
        slivers: [
          // Header persistente
          SliverAppBar(
            backgroundColor: surfaceColor,
            expandedHeight: 180,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.only(top: 80, left: 24, right: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.prestamo.clienteNombre,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'PRÉSTAMO #${widget.prestamo.base.id}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primaryOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Resumen de cabecera
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildSummaryItem('Capital', widget.prestamo.base.capitalInicial),
                      const SizedBox(width: 16),
                      _buildSummaryItem('Tasa', '${widget.prestamo.base.tasaInteres}%', isCurrency: false),
                      const SizedBox(width: 16),
                      _buildSummaryItem('Inició', DateFormat('dd MMM').format(widget.prestamo.base.fechaInicioPago), isCurrency: false),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildSummaryItem('Interés Pagado', widget.prestamo.base.interesPagado),
                      const SizedBox(width: 16),
                      _buildSummaryItem('Abonos Hechos', _cuotas.isNotEmpty ? _cuotas.length.toString() : '0', isCurrency: false),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Progreso del Préstamo
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: _buildLoanProgress(primaryOrange, surfaceColor),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Título de la sección
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                'PLAN DE PAGO',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ),
          ),

          // Listado de cuotas
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: primaryOrange)),
            )
          else if (_cuotas.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  'No hay detalles disponibles',
                  style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.3)),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final cuota = _cuotas[index];
                    return _buildCuotaRow(cuota, index, primaryOrange, surfaceColor);
                  },
                  childCount: _cuotas.length,
                ),
              ),
            ),
            
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _mostrarBottomSheetAbono(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AbonoBottomSheet(
        prestamo: widget.prestamo,
        onAbonoRegistrado: () {
          _cargarDetalle();
        },
      ),
    );
  }

  Widget _buildLoanProgress(Color primaryOrange, Color surfaceColor) {
    final double capitalInicial = widget.prestamo.base.capitalInicial;
    final double capitalPagado = widget.prestamo.base.capitalPagado;
    final double interesPagado = widget.prestamo.base.interesPagado;
    final double interesPendiente = widget.prestamo.base.interesPendiente;

    // Total a Pagar original + acumulado
    final double totalAPagar = capitalInicial + interesPagado + interesPendiente;
    // Total ya pagado
    final double totalPagado = capitalPagado + interesPagado;

    double progress = totalAPagar > 0
        ? (totalPagado / totalAPagar).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso de Pago (Total)',
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.9)),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.poppins(
                  fontSize: 15, 
                  fontWeight: FontWeight.bold,
                  color: primaryOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.05),
              valueColor: AlwaysStoppedAnimation<Color>(primaryOrange),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pagado: L ${totalPagado.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.5), fontSize: 11),
              ),
              Text(
                'Deuda Restante: L ${(totalAPagar - totalPagado).toStringAsFixed(2)}',
                style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.5), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, dynamic value, {bool isCurrency = true}) {
    final displayValue = isCurrency 
      ? NumberFormat.currency(symbol: 'L ', decimalDigits: 2).format(value)
      : value.toString();

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.white.withOpacity(0.4))),
            const SizedBox(height: 4),
            Text(
              displayValue,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCuotaRow(CuotaPrestamo cuota, int index, Color primaryOrange, Color surfaceColor) {
    double totalAbono = cuota.capital + cuota.interes;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          // Badge del correlativo
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              '#${index + 1}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.greenAccent,
              ),
            ),
          ),
          const SizedBox(width: 14),
          
          // Información principal del abono
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Abono: ${NumberFormat.currency(symbol: 'L ', decimalDigits: 2).format(totalAbono)}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 12, color: Colors.white.withOpacity(0.4)),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd MMM yyyy').format(cuota.fechapago),
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Detalles a la derecha
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (cuota.capital > 0)
                Text(
                  'Cap: L ${cuota.capital.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(color: Colors.blueAccent.shade100, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              if (cuota.interes > 0)
                Text(
                  'Int: L ${cuota.interes.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(color: Colors.purpleAccent.shade100, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              const SizedBox(height: 4),
              Text(
                'Saldo: L ${cuota.capitalrestante.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(color: primaryOrange.withOpacity(0.9), fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Bottom Sheet para registrar abonos
// ──────────────────────────────────────────────────────────────────────────────
class _AbonoBottomSheet extends StatefulWidget {
  final Prestamo_Detallado_DTO prestamo;
  final VoidCallback onAbonoRegistrado;

  const _AbonoBottomSheet({
    required this.prestamo,
    required this.onAbonoRegistrado,
  });

  @override
  State<_AbonoBottomSheet> createState() => _AbonoBottomSheetState();
}

class _AbonoBottomSheetState extends State<_AbonoBottomSheet> {
  final _capitalCtrl = TextEditingController();
  final _interesCtrl = TextEditingController();
  bool _isLoading = false;
  String _tipoAbono = 'ambos'; // 'capital', 'interes', 'ambos'

  void _registrar() async {
    final cap = _tipoAbono == 'interes' ? 0.0 : (double.tryParse(_capitalCtrl.text) ?? 0);
    final inte = _tipoAbono == 'capital' ? 0.0 : (double.tryParse(_interesCtrl.text) ?? 0);

    if (cap <= 0 && inte <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Ingresa un monto válido mayor a 0', style: GoogleFonts.poppins()),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    setState(() => _isLoading = true);

    // Capital original prestado - capital pagado
    double capitalRestanteActual = widget.prestamo.base.capitalInicial - widget.prestamo.base.capitalPagado;

    final success = await PrestamoService().registrarAbono(
      prestamoId: widget.prestamo.base.id,
      abonoCapital: cap,
      abonoInteres: inte,
      capitalRestanteActual: capitalRestanteActual,
    );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) Navigator.pop(context);
      widget.onAbonoRegistrado();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Abono registrado correctamente', style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.green,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al registrar abono', style: GoogleFonts.poppins()),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    const _orange = Color(0xFFF59E0B);
    final insets = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: insets),
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.payments_rounded, color: _orange),
                ),
                const SizedBox(width: 12),
                Text(
                  'Registrar Abono',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Selector de tipo de abono
            _buildSelectorTipo(),
            const SizedBox(height: 24),

            if (_tipoAbono == 'capital' || _tipoAbono == 'ambos') ...[
              Text(
                'Abono a Capital',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              _buildAmountField(_capitalCtrl, '0.00', Icons.account_balance_wallet_rounded, const Color(0xFF3B82F6)),
              const SizedBox(height: 20),
            ],

            if (_tipoAbono == 'interes' || _tipoAbono == 'ambos') ...[
              Text(
                'Abono a Intereses',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              _buildAmountField(_interesCtrl, '0.00', Icons.trending_up_rounded, Colors.purpleAccent),
              const SizedBox(height: 32),
            ],
            
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: _isLoading ? null : _registrar,
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Confirmar Pago', style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountField(TextEditingController ctrl, String hint, IconData icon, Color iconColor) {
    return TextFormField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
      style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.white24, fontSize: 20),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 12),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        prefixText: 'L. ',
        prefixStyle: GoogleFonts.poppins(color: iconColor, fontSize: 18, fontWeight: FontWeight.bold),
        filled: true,
        fillColor: const Color(0xFF0F172A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: iconColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildSelectorTipo() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          _tipoOption('capital', 'Solo Capital'),
          _tipoOption('interes', 'Solo Interés'),
          _tipoOption('ambos', 'Ambos'),
        ],
      ),
    );
  }

  Widget _tipoOption(String type, String label) {
    final isSelected = _tipoAbono == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tipoAbono = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF59E0B) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [BoxShadow(color: const Color(0xFFF59E0B).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : Colors.white54,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
