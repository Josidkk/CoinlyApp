import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'prestamos_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(
        onNavigateToPrestamos: () {
          setState(() {
            _currentIndex = 1;
          });
        },
      ),
      const PrestamosScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      extendBody:
          true, // Permite que el contenido se extienda detrás del navbar
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() => _currentIndex = index);
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFFF59E0B),
              unselectedItemColor: Colors.white.withOpacity(0.35),
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedLabelStyle: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: GoogleFonts.poppins(
                fontSize: 11,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: _buildNavIcon(
                    icon: Icons.home_outlined,
                    isSelected: _currentIndex == 0,
                  ),
                  activeIcon: _buildNavIcon(icon: Icons.home, isSelected: true),
                  label: 'Inicio',
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon(
                    icon: Icons.receipt_long_outlined,
                    isSelected: _currentIndex == 1,
                  ),
                  activeIcon: _buildNavIcon(
                    icon: Icons.receipt_long,
                    isSelected: true,
                  ),
                  label: 'Préstamos',
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon(
                    icon: Icons.settings_outlined,
                    isSelected: _currentIndex == 2,
                  ),
                  activeIcon: _buildNavIcon(
                    icon: Icons.settings,
                    isSelected: true,
                  ),
                  label: 'Configuración',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon({required IconData icon, required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 26),
    );
  }
}
