import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/prestamo_service.dart';

// ──────────────────────────────────────────────────────────────────────────────
// NuevoPrestamoScreen — Creación de préstamo en 3 pasos
//
// Modelo de negocio (interés sobre saldo):
//   • Se presta un capital al cliente.
//   • Cada período (semanal / quincenal / mensual), mientras quede capital
//     pendiente, se genera un cargo de interés sobre el saldo restante.
//   • El cliente paga cuotas libremente; cada pago reduce el capital.
//   • No hay número fijo de cuotas ni fecha límite.
// ──────────────────────────────────────────────────────────────────────────────
class NuevoPrestamoScreen extends StatefulWidget {
  const NuevoPrestamoScreen({super.key});

  @override
  State<NuevoPrestamoScreen> createState() => _NuevoPrestamoScreenState();
}

class _NuevoPrestamoScreenState extends State<NuevoPrestamoScreen>
    with TickerProviderStateMixin {
  // ── Design tokens ──────────────────────────────────────────────────────────
  static const Color _orange = Color(0xFFF59E0B);
  static const Color _darkBg = Color(0xFF0F172A);
  static const Color _surface = Color(0xFF1E293B);
  static const Color _card = Color(0xFF243047);

  // ── Stepper ────────────────────────────────────────────────────────────────
  int _step = 0;

  // ── Paso 1: cliente ────────────────────────────────────────────────────────
  final _prestamoService = PrestamoService();
  bool _isLoadingClientes = true;
  List<Map<String, dynamic>> _clientesList = [];
  
  Map<String, dynamic>? _clienteSeleccionado;
  final _searchCtrl = TextEditingController();
  String _busqueda = '';

  // ── Paso 2: condiciones ────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _capitalCtrl = TextEditingController();
  final _tasaCtrl = TextEditingController();

  /// Frecuencia con la que se acumulan los intereses
  String _frecuencia = 'Semanal';

  /// Fecha desde la que empiezan a correr los intereses
  DateTime _fechaInicio = DateTime.now();

  // Frecuencias disponibles con su ícono y descripción corta
  static const List<_FrecuenciaOption> _frecuencias = [
    _FrecuenciaOption('Semanal', Icons.view_week_rounded, '× 52 /año'),
    _FrecuenciaOption('Quincenal', Icons.date_range_rounded, '× 24 /año'),
    _FrecuenciaOption('Mensual', Icons.calendar_month_rounded, '× 12 /año'),
  ];

  // ── Animación entre pasos ──────────────────────────────────────────────────
  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slide;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 340));
    _slide = Tween<Offset>(begin: const Offset(0.07, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);

    _slideCtrl.forward();
    _fadeCtrl.forward();
    
    _cargarClientes();
  }

  Future<void> _cargarClientes() async {
    final clientes = await _prestamoService.obtenerClientesActivos();
    if (mounted) {
      setState(() {
        _clientesList = clientes;
        _isLoadingClientes = false;
      });
    }
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    _capitalCtrl.dispose();
    _tasaCtrl.dispose();
    super.dispose();
  }

  // ── Navegación ─────────────────────────────────────────────────────────────
  void _next() {
    if (_step == 0 && _clienteSeleccionado == null) {
      _snack('Selecciona un cliente para continuar');
      return;
    }
    if (_step == 1 && !_formKey.currentState!.validate()) return;
    setState(() => _step++);
    _animateStep();
  }

  void _prev() {
    if (_step == 0) return;
    setState(() => _step--);
    _animateStep();
  }

  void _animateStep() {
    _slideCtrl.reset();
    _fadeCtrl.reset();
    _slideCtrl.forward();
    _fadeCtrl.forward();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins()),
      backgroundColor: const Color(0xFF374151),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ── Cálculos de interés sobre saldo ───────────────────────────────────────

  double get _capital => double.tryParse(_capitalCtrl.text) ?? 0;
  double get _tasa => double.tryParse(_tasaCtrl.text) ?? 0;

  /// Interés generado por período = capital × tasa%
  double get _interesPorPeriodo => _capital * (_tasa / 100);

  /// Cuántos períodos tiene un año según la frecuencia
  int get _periodosPorAnio =>
      _frecuencia == 'Semanal' ? 52 : _frecuencia == 'Quincenal' ? 24 : 12;

  /// Interés total acumulado si el cliente NO paga capital en N períodos
  double _interesAcumulado(int periodos) => _interesPorPeriodo * periodos;

  /// Etiqueta corta del período
  String get _labelPeriodo =>
      _frecuencia == 'Semanal' ? 'sem' : _frecuencia == 'Quincenal' ? 'qna' : 'mes';

  // ── Lista de clientes filtrada ─────────────────────────────────────────────
  List<Map<String, dynamic>> get _clientesFiltrados => _clientesList
      .where((c) =>
          '${c['nombres']} ${c['apellidos']}'
              .toLowerCase()
              .contains(_busqueda.toLowerCase()) ||
          c['id'].toString().contains(_busqueda))
      .toList();

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            _stepIndicator(),
            Expanded(
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: _currentStepWidget(),
                ),
              ),
            ),
            _bottomActions(),
          ],
        ),
      ),
    );
  }

  // ── Top bar ────────────────────────────────────────────────────────────────
  Widget _topBar() {
    final subtitles = [
      'Selecciona el beneficiario',
      'Define las condiciones',
      'Revisa y confirma',
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          _iconBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => _step > 0 ? _prev() : Navigator.pop(context),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Nuevo Préstamo',
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text(subtitles[_step],
                  style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12)),
            ]),
          ),
          _stepBadge(),
        ],
      ),
    );
  }

  Widget _stepBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _orange.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _orange.withOpacity(0.3)),
        ),
        child: Text('Paso ${_step + 1} de 3',
            style: GoogleFonts.poppins(
                color: _orange, fontSize: 11, fontWeight: FontWeight.w600)),
      );

  Widget _iconBtn({required IconData icon, required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),
          child: Icon(icon, color: Colors.white70, size: 18),
        ),
      );

  // ── Step indicator ─────────────────────────────────────────────────────────
  Widget _stepIndicator() {
    final labels = ['Cliente', 'Condiciones', 'Resumen'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 6),
      child: Row(
        children: List.generate(labels.length * 2 - 1, (i) {
          if (i.isOdd) {
            final completed = _step > i ~/ 2;
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: completed ? _orange : Colors.white12,
                ),
              ),
            );
          }
          final idx = i ~/ 2;
          return _stepDot(labels[idx], idx + 1, _step == idx, _step > idx);
        }),
      ),
    );
  }

  Widget _stepDot(String label, int num, bool active, bool done) => Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
            width: active ? 38 : 32,
            height: active ? 38 : 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? _orange : active ? _orange.withOpacity(0.18) : _surface,
              border: Border.all(
                  color: done || active ? _orange : Colors.white12,
                  width: active ? 2 : 1),
              boxShadow: active
                  ? [BoxShadow(color: _orange.withOpacity(0.3), blurRadius: 12, spreadRadius: 1)]
                  : [],
            ),
            child: Center(
              child: done
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                  : Text('$num',
                      style: GoogleFonts.poppins(
                          color: active ? _orange : Colors.white38,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
            ),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                  color: active ? _orange : Colors.white30)),
        ],
      );

  // ── Router de pasos ────────────────────────────────────────────────────────
  Widget _currentStepWidget() {
    switch (_step) {
      case 0:
        return _step1Cliente();
      case 1:
        return _step2Condiciones();
      default:
        return _step3Resumen();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PASO 1 – Selección de cliente
  // ══════════════════════════════════════════════════════════════════════════
  Widget _step1Cliente() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _searchField(),
        const SizedBox(height: 18),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Clientes disponibles',
              style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w500)),
          Text('${_clientesFiltrados.length} resultado(s)',
              style: GoogleFonts.poppins(color: Colors.white30, fontSize: 11)),
        ]),
        const SizedBox(height: 10),
        Expanded(
          child: _isLoadingClientes 
              ? const Center(child: CircularProgressIndicator(color: _orange))
              : _clientesFiltrados.isEmpty
                  ? _emptyClientes()
                  : ListView.builder(
                      itemCount: _clientesFiltrados.length,
                      itemBuilder: (_, i) => _clienteTile(_clientesFiltrados[i]),
                    ),
        ),
      ]),
    );
  }

  Widget _searchField() => Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _busqueda = v),
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Buscar por nombre o ID…',
            hintStyle: GoogleFonts.poppins(color: Colors.white30, fontSize: 13),
            prefixIcon: const Icon(Icons.search_rounded, color: _orange, size: 22),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      );

  Widget _clienteTile(Map<String, dynamic> c) {
    final selected = _clienteSeleccionado?['id'] == c['id'];
    final nombre = '${c['nombres']} ${c['apellidos']}';
    final initials = _initials(c['nombres'], c['apellidos']);

    return GestureDetector(
      onTap: () => setState(() => _clienteSeleccionado = c),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? _orange.withOpacity(0.11) : _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected ? _orange.withOpacity(0.5) : Colors.white.withOpacity(0.06),
              width: selected ? 1.5 : 1),
          boxShadow: selected
              ? [BoxShadow(color: _orange.withOpacity(0.14), blurRadius: 16, offset: const Offset(0, 4))]
              : [],
        ),
        child: Row(children: [
          // Avatar
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: selected
                    ? [_orange, const Color(0xFFD97706)]
                    : [const Color(0xFF334155), const Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(initials,
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(nombre,
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
              Text('ID #${c['id']}',
                  style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11)),
            ]),
          ),
          AnimatedOpacity(
            opacity: selected ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: _orange),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _emptyClientes() => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.person_search_rounded, size: 64, color: Colors.white.withOpacity(0.06)),
          const SizedBox(height: 12),
          Text('No se encontraron clientes',
              style: GoogleFonts.poppins(color: Colors.white24, fontSize: 14)),
        ]),
      );

  String _initials(String n, String a) =>
      '${n.isNotEmpty ? n[0].toUpperCase() : ''}${a.isNotEmpty ? a[0].toUpperCase() : ''}';

  // ══════════════════════════════════════════════════════════════════════════
  // PASO 2 – Condiciones del préstamo (interés sobre saldo)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _step2Condiciones() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Préstamo para
          if (_clienteSeleccionado != null) _clienteBadge(),
          const SizedBox(height: 22),

          // ── Capital ────────────────────────────────────────────────────
          _sectionLabel('Capital a prestar', Icons.account_balance_wallet_rounded),
          const SizedBox(height: 8),
          _moneyField(),
          const SizedBox(height: 22),

          // ── Tasa de interés ────────────────────────────────────────────
          _sectionLabel('Tasa de interés por período', Icons.percent_rounded),
          const SizedBox(height: 4),
          Text(
            'Porcentaje que se cobra sobre el capital pendiente cada $_frecuencia.',
            style: GoogleFonts.poppins(color: Colors.white30, fontSize: 11),
          ),
          const SizedBox(height: 8),
          _tasaField(),
          const SizedBox(height: 22),

          // ── Frecuencia de cobro de interés ─────────────────────────────
          _sectionLabel('Frecuencia de cobro de interés', Icons.repeat_rounded),
          const SizedBox(height: 4),
          Text(
            'Cada cuánto tiempo se generará el cargo de interés.',
            style: GoogleFonts.poppins(color: Colors.white30, fontSize: 11),
          ),
          const SizedBox(height: 10),
          _frecuenciaSelector(),
          const SizedBox(height: 22),

          // ── Fecha de inicio ────────────────────────────────────────────
          _sectionLabel('Fecha de inicio del préstamo', Icons.event_available_rounded),
          const SizedBox(height: 4),
          Text(
            'Día en que el cliente recibe el dinero y empiezan a correr los intereses.',
            style: GoogleFonts.poppins(color: Colors.white30, fontSize: 11),
          ),
          const SizedBox(height: 8),
          _fechaPicker(),
          const SizedBox(height: 22),

          // ── Preview de interés generado ────────────────────────────────
          if (_capital > 0 && _tasa > 0) _interesPreview(),
          const SizedBox(height: 28),
        ]),
      ),
    );
  }

  Widget _clienteBadge() {
    final nombre =
        '${_clienteSeleccionado!['nombres']} ${_clienteSeleccionado!['apellidos']}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2744),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _orange.withOpacity(0.2)),
      ),
      child: Row(children: [
        const Icon(Icons.person_pin_circle_rounded, color: _orange, size: 18),
        const SizedBox(width: 8),
        Text('Para: ', style: GoogleFonts.poppins(color: Colors.white38, fontSize: 13)),
        Text(nombre,
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
      ]),
    );
  }

  Widget _sectionLabel(String label, IconData icon) => Row(children: [
        Icon(icon, color: _orange, size: 16),
        const SizedBox(width: 8),
        Text(label,
            style: GoogleFonts.poppins(
                color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
      ]);

  // Campo de capital
  Widget _moneyField() => TextFormField(
        controller: _capitalCtrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
        onChanged: (_) => setState(() {}),
        style: GoogleFonts.poppins(
            color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        validator: (v) {
          final val = double.tryParse(v ?? '');
          if (val == null || val <= 0) return 'Ingresa un monto válido';
          return null;
        },
        decoration: _fieldDeco(
          hint: '0.00',
          prefixWidget:
              Text('L ', style: GoogleFonts.poppins(color: _orange, fontWeight: FontWeight.bold, fontSize: 20)),
        ),
      );

  // Campo de tasa
  Widget _tasaField() => TextFormField(
        controller: _tasaCtrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
        onChanged: (_) => setState(() {}),
        style: GoogleFonts.poppins(
            color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        validator: (v) {
          final val = double.tryParse(v ?? '');
          if (val == null || val <= 0) return 'Ingresa una tasa válida';
          if (val > 100) return 'La tasa no puede superar 100%';
          return null;
        },
        decoration: _fieldDeco(
          hint: 'Ej: 5',
          suffixWidget:
              Text('%', style: GoogleFonts.poppins(color: _orange, fontWeight: FontWeight.bold, fontSize: 20)),
        ),
      );

  InputDecoration _fieldDeco({required String hint, Widget? prefixWidget, Widget? suffixWidget}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.white12, fontSize: 22),
        prefixIcon: prefixWidget != null
            ? Padding(padding: const EdgeInsets.only(left: 16, right: 6), child: prefixWidget)
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffixWidget != null
            ? Padding(padding: const EdgeInsets.only(right: 16), child: suffixWidget)
            : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: _surface,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.07))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.07))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _orange, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      );

  // Selector de frecuencia — 3 tarjetas visuales
  Widget _frecuenciaSelector() => Row(
        children: _frecuencias.map((f) {
          final active = _frecuencia == f.label;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _frecuencia = f.label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: f != _frecuencias.last ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: active ? _orange.withOpacity(0.14) : _surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: active ? _orange.withOpacity(0.6) : Colors.white.withOpacity(0.06),
                      width: active ? 1.5 : 1),
                ),
                child: Column(children: [
                  Icon(f.icon, color: active ? _orange : Colors.white30, size: 22),
                  const SizedBox(height: 6),
                  Text(f.label,
                      style: GoogleFonts.poppins(
                          color: active ? _orange : Colors.white30,
                          fontSize: 11,
                          fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
                  const SizedBox(height: 2),
                  Text(f.detail,
                      style: GoogleFonts.poppins(
                          color: active ? _orange.withOpacity(0.7) : Colors.white24,
                          fontSize: 9)),
                ]),
              ),
            ),
          );
        }).toList(),
      );

  // Date picker de inicio
  Widget _fechaPicker() => GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _fechaInicio,
            firstDate: DateTime(2020),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            builder: (ctx, child) => Theme(
              data: Theme.of(ctx).copyWith(
                  colorScheme: const ColorScheme.dark(
                      primary: _orange, surface: Color(0xFF1E293B))),
              child: child!,
            ),
          );
          if (picked != null) setState(() => _fechaInicio = picked);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),
          child: Row(children: [
            const Icon(Icons.calendar_today_rounded, color: _orange, size: 20),
            const SizedBox(width: 12),
            Text(
              DateFormat('dd MMMM yyyy', 'es').format(_fechaInicio),
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: Colors.white30, size: 20),
          ]),
        ),
      );

  /// Preview visual: muestra el interés que se genera cada período
  /// y cómo se acumularía si el cliente no reduce capital.
  Widget _interesPreview() {
    final fmt = NumberFormat('#,##0.00');
    final periodos = [1, 2, 4, 8];

    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _orange.withOpacity(0.15)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: _orange.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.auto_graph_rounded, color: _orange, size: 18),
            ),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Interés generado',
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              Text('Basado en el capital ingresado',
                  style: GoogleFonts.poppins(color: Colors.white38, fontSize: 10)),
            ]),
            const Spacer(),
            // Chip de interés por período
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: _orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _orange.withOpacity(0.3))),
              child: Text(
                'L ${fmt.format(_interesPorPeriodo)} /$_labelPeriodo',
                style: GoogleFonts.poppins(
                    color: _orange, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ]),
        ),

        Divider(height: 1, color: Colors.white.withOpacity(0.06)),

        // Fila explicativa
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            'Si el cliente no abona al capital, estos son los intereses que se acumularían:',
            style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11),
          ),
        ),

        // Barra de proyección por períodos
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: periodos.map((p) {
              final intAcum = _interesAcumulado(p);
              final maxVal = _interesAcumulado(periodos.last);
              final ratio = maxVal > 0 ? (intAcum / maxVal).clamp(0.0, 1.0) : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(children: [
                  // Etiqueta de período
                  SizedBox(
                    width: 52,
                    child: Text(
                      '$p $_labelPeriodo',
                      style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Barra de progreso
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 8,
                        backgroundColor: Colors.white.withOpacity(0.05),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color.lerp(const Color(0xFFF59E0B), Colors.redAccent, ratio * 0.6)!,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Valor
                  Text(
                    'L ${fmt.format(intAcum)}',
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ]),
              );
            }).toList(),
          ),
        ),

        // Nota aclaratoria
        Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blueGrey.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline_rounded, color: Colors.blueGrey, size: 14),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'El interés se cobra solo mientras haya capital pendiente. Cada abono al capital reduce el interés del siguiente período.',
                style: GoogleFonts.poppins(color: Colors.blueGrey.shade200, fontSize: 10),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PASO 3 – Resumen de confirmación
  // ══════════════════════════════════════════════════════════════════════════
  Widget _step3Resumen() {
    final fmt = NumberFormat('#,##0.00');
    final nombre =
        '${_clienteSeleccionado?['nombres'] ?? ''} ${_clienteSeleccionado?['apellidos'] ?? ''}'.trim();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Hero card
        _heroCard(nombre, fmt),
        const SizedBox(height: 18),

        // Tabla resumen
        _resumenTable(fmt),
        const SizedBox(height: 18),

        // Proyección de interés acumulado (escenario sin abonos)
        _proyeccionCard(fmt),
        const SizedBox(height: 18),

        // Nota
        _notice(),
        const SizedBox(height: 28),
      ]),
    );
  }

  Widget _heroCard(String nombre, NumberFormat fmt) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFFF59E0B).withOpacity(0.28),
                blurRadius: 24,
                offset: const Offset(0, 8))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.account_balance_wallet_rounded, color: Colors.white70, size: 16),
            const SizedBox(width: 6),
            Text('Capital a prestar',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
          ]),
          const SizedBox(height: 6),
          Text('L ${fmt.format(_capital)}',
              style: GoogleFonts.poppins(
                  color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, height: 1)),
          const SizedBox(height: 14),
          Container(height: 1, color: Colors.white24),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.person_rounded, color: Colors.white70, size: 15),
            const SizedBox(width: 6),
            Text(nombre,
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          ]),
        ]),
      );

  Widget _resumenTable(NumberFormat fmt) => Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(children: [
          _tableRow('Tasa de interés', '${_tasa.toStringAsFixed(2)}% por $_frecuencia',
              Icons.percent_rounded, isFirst: true),
          _divider(),
          _tableRow('Frecuencia de cobro', _frecuencia, Icons.repeat_rounded),
          _divider(),
          _tableRow(
              'Fecha de inicio',
              DateFormat('dd/MM/yyyy').format(_fechaInicio),
              Icons.event_rounded),
          _divider(),
          _tableRow(
              'Interés por período',
              'L ${fmt.format(_interesPorPeriodo)}',
              Icons.payments_rounded,
              valueColor: _orange),
          _divider(),
          _tableRow(
              'Interés anual estimado*',
              'L ${fmt.format(_interesPorPeriodo * _periodosPorAnio)}',
              Icons.trending_up_rounded,
              isLast: true,
              valueColor: Colors.amberAccent),
        ]),
      );

  Widget _tableRow(String label, String value, IconData icon,
      {bool isFirst = false, bool isLast = false, Color? valueColor}) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(children: [
          Icon(icon, color: _orange, size: 15),
          const SizedBox(width: 10),
          Expanded(
              child: Text(label,
                  style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13))),
          Text(value,
              style: GoogleFonts.poppins(
                  color: valueColor ?? Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ]),
      );

  Widget _divider() =>
      Divider(height: 1, color: Colors.white.withOpacity(0.05), indent: 14, endIndent: 14);

  Widget _proyeccionCard(NumberFormat fmt) {
    final periodos = [1, 4, 8, 12];
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Text('Interés acumulado* (sin abonos al capital)',
              style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w500)),
        ),
        Divider(height: 1, color: Colors.white.withOpacity(0.05)),
        // Header de columnas
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            _colHead('Período', flex: 2),
            _colHead('Capital', flex: 3),
            _colHead('Interés acum.', flex: 3),
            _colHead('Total deuda', flex: 3),
          ]),
        ),
        Divider(height: 1, color: Colors.white.withOpacity(0.04)),
        ...periodos.asMap().entries.map((e) {
          final last = e.key == periodos.length - 1;
          final p = e.value;
          final intAcum = _interesAcumulado(p);
          final totalDeuda = _capital + intAcum;
          return Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              child: Row(children: [
                _colCell('$p $_labelPeriodo', flex: 2, color: _orange, bold: true),
                _colCell('L ${fmt.format(_capital)}', flex: 3),
                _colCell('L ${fmt.format(intAcum)}', flex: 3, color: Colors.amber.shade300),
                _colCell('L ${fmt.format(totalDeuda)}', flex: 3, color: Colors.white70),
              ]),
            ),
            if (!last) Divider(height: 1, color: Colors.white.withOpacity(0.03), indent: 14, endIndent: 14),
          ]);
        }).toList(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Text('* Escenario teórico si el cliente no abona al capital.',
              style: GoogleFonts.poppins(color: Colors.white24, fontSize: 10)),
        ),
      ]),
    );
  }

  Widget _colHead(String text, {int flex = 1}) => Expanded(
        flex: flex,
        child: Text(text,
            style: GoogleFonts.poppins(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.w600)),
      );

  Widget _colCell(String text, {int flex = 1, bool bold = false, Color? color}) =>
      Expanded(
        flex: flex,
        child: Text(text,
            style: GoogleFonts.poppins(
                color: color ?? Colors.white,
                fontSize: 11,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      );

  Widget _notice() => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.blueGrey.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.blueGrey.withOpacity(0.18)),
        ),
        child: Row(children: [
          const Icon(Icons.info_outline_rounded, color: Colors.blueGrey, size: 17),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Los valores son estimados asumiendo capital constante. El sistema calculará los intereses reales conforme el cliente realice abonos.',
              style: GoogleFonts.poppins(color: Colors.blueGrey.shade200, fontSize: 10),
            ),
          ),
        ]),
      );

  // ── Botones de acción ──────────────────────────────────────────────────────
  Widget _bottomActions() {
    final isLast = _step == 2;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration:
          BoxDecoration(color: _darkBg, border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: Row(children: [
        if (_step > 0) ...[
          _backBtn(),
          const SizedBox(width: 12),
        ],
        Expanded(child: _mainBtn(isLast)),
      ]),
    );
  }

  Widget _backBtn() => GestureDetector(
        onTap: _prev,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.07))),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white60, size: 18),
        ),
      );

  Widget _mainBtn(bool isLast) => GestureDetector(
        onTap: isLast
            ? () async {
                final success = await _prestamoService.crearPrestamo(
                  clienteId: _clienteSeleccionado!['id'],
                  capitalInicial: _capital,
                  tasaInteres: _tasa,
                  fechaInicio: _fechaInicio,
                  frecuenciaPago: _frecuencia,
                );
                
                if (success) {
                  _snack('¡Préstamo creado con éxito!');
                  if (mounted) Navigator.pop(context);
                } else {
                  _snack('Error al crear el préstamo.');
                }
              }
            : _next,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFFF59E0B).withOpacity(0.32),
                  blurRadius: 16,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              isLast ? 'Confirmar Préstamo' : 'Continuar',
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(width: 8),
            Icon(
              isLast ? Icons.check_circle_outline_rounded : Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 17,
            ),
          ]),
        ),
      );
}

// ── Modelo ligero para las opciones de frecuencia ──────────────────────────
class _FrecuenciaOption {
  final String label;
  final IconData icon;
  final String detail;
  const _FrecuenciaOption(this.label, this.icon, this.detail);
}
