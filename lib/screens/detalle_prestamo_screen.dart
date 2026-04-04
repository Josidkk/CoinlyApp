import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/prestamo.dart';
import '../models/cuota_prestamo.dart';
import '../services/prestamo_service.dart';

class DetallePrestamoScreen extends StatefulWidget {
  final Prestamo prestamo;

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
    final cuotas = await _prestamoService.obtenerDetallePrestamo(widget.prestamo.presId);
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

    return Scaffold(
      backgroundColor: darkBg,
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
                      widget.prestamo.clienteNombre ?? 'Detalle del Préstamo',
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
                        'PRÉSTAMO #${widget.prestamo.presId}',
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
              child: Row(
                children: [
                  _buildSummaryItem('Capital', widget.prestamo.presCapitalInicial),
                  const SizedBox(width: 16),
                  _buildSummaryItem('Interés', '${widget.prestamo.presTasaInteres}%', isCurrency: false),
                  const SizedBox(width: 16),
                  _buildSummaryItem('Cuotas', widget.prestamo.presNumeroCuotas.toString(), isCurrency: false),
                ],
              ),
            ),
          ),

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
                    return _buildCuotaRow(cuota, primaryOrange, surfaceColor);
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

  Widget _buildCuotaRow(CuotaPrestamo cuota, Color primaryOrange, Color surfaceColor) {
    // Calculamos totales y estados
    double totalPagado = cuota.capitalpagado + cuota.interespagado;
    double totalPendiente = cuota.capitalrestante + cuota.interesrestante;
    bool isPagada = totalPendiente <= 0.01; // Tolerancia por redondeo
    bool isParcial = totalPagado > 0 && !isPagada;
    
    // Determinamos si la cuota está vencida (mora simple basada en fecha, ya que el SP detalle no trae "mora" explícita per se, pero podemos inferir por fecha y saldo)
    bool isVencida = !isPagada && cuota.fechapago.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPagada 
              ? Colors.green.withOpacity(0.2) 
              : isVencida ? Colors.red.withOpacity(0.3) : Colors.white.withOpacity(0.05),
          width: isVencida ? 1.5 : 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Row(
            children: [
              // Badge de Número de Mes
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isPagada ? Colors.green.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  cuota.numeromes.toString(),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: isPagada ? Colors.green : Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Info Principal (Fecha y Monto)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cuota: ${NumberFormat.currency(symbol: 'L ', decimalDigits: 2).format(cuota.montoCuota)}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined, 
                          size: 12, 
                          color: isVencida ? Colors.redAccent : Colors.white.withOpacity(0.4)
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd MMM yyyy').format(cuota.fechapago),
                          style: GoogleFonts.poppins(
                            color: isVencida ? Colors.redAccent : Colors.white.withOpacity(0.4),
                            fontSize: 12,
                            fontWeight: isVencida ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                _buildMiniStatusBadge(isPagada, isParcial, isVencida),
                const Spacer(),
                if (!isPagada)
                  Text(
                    'Restante: ${NumberFormat.currency(symbol: 'L ', decimalDigits: 2).format(totalPendiente)}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: primaryOrange.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          
          // DETALLE EXPANDIBLE
          children: [
            Divider(color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 8),
            _buildDetailRow('Capital', cuota.capitalpagado, cuota.capital, Colors.blueAccent),
            const SizedBox(height: 8),
            _buildDetailRow('Interés', cuota.interespagado, cuota.interes, Colors.purpleAccent),
            // Aquí se podría agregar Mora si el modelo detallado la tuviera individualizada
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStatusBadge(bool isPagada, bool isParcial, bool isVencida) {
    Color color;
    String text;
    
    if (isPagada) {
      color = Colors.green;
      text = 'PAGADA';
    } else if (isVencida) {
      color = Colors.redAccent;
      text = 'MORA';
    } else if (isParcial) {
      color = Colors.orange;
      text = 'PARCIAL';
    } else {
      color = Colors.grey;
      text = 'PENDIENTE';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10, 
          fontWeight: FontWeight.bold, 
          color: color
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, double pagado, double total, Color color) {
    double pendiente = total - pagado;
    double progress = total > 0 ? (pagado / total).clamp(0.0, 1.0) : 0.0;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.6), fontSize: 12)),
            Text(
              '${NumberFormat.currency(symbol: 'L ', decimalDigits: 2).format(pagado)} / ${NumberFormat.currency(symbol: 'L ', decimalDigits: 2).format(total)}',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.05),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 4,
          ),
        ),
        if (pendiente > 0.01)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Falta: ${NumberFormat.currency(symbol: 'L ', decimalDigits: 2).format(pendiente)}',
                style: GoogleFonts.poppins(color: color.withOpacity(0.8), fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }
}
