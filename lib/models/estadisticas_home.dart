class EstadisticasHome {
  final int totalPrestamosActivos;
  final double totalCapitalPrestado;
  final double totalPorCobrar;
  final int totalClientes;
  final double totalInteresesGenerados;

  EstadisticasHome({
    required this.totalPrestamosActivos,
    required this.totalCapitalPrestado,
    required this.totalPorCobrar,
    required this.totalClientes,
    required this.totalInteresesGenerados,
  });

  factory EstadisticasHome.empty() {
    return EstadisticasHome(
      totalPrestamosActivos: 0,
      totalCapitalPrestado: 0.0,
      totalPorCobrar: 0.0,
      totalClientes: 0,
      totalInteresesGenerados: 0.0,
    );
  }
}
