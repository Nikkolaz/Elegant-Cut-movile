import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:elegant_cut_mobile/src/theme/app_theme.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  // Variable para saber qué pestaña está seleccionada
  int _selectedIndex = 0;

  // Variables para la animación de ocultar la barra
  final ScrollController _scrollController = ScrollController();
  bool _isBottomNavBarVisible = true;

  @override
  void initState() {
    super.initState();
    // Escuchamos los eventos de scroll
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (_isBottomNavBarVisible) {
          setState(() {
            _isBottomNavBarVisible = false;
          });
        }
      } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (!_isBottomNavBarVisible) {
          setState(() {
            _isBottomNavBarVisible = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkSurface,
      // Usamos Stack para apilar la vista y la barra de navegación encima
      body: Stack(
        children: [
          // 1. Contenido de la página que hace scroll
          SingleChildScrollView(
            controller: _scrollController,
            child: Container(
              height: 1500, // Altura temporal para que puedas scrolear y probar la barra
              padding: const EdgeInsets.only(top: 100),
              alignment: Alignment.topCenter,
              child: const Text(
                'Tu contenido irá aquí.\n\n(Haz scroll hacia abajo para probar la animación)', 
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
            ),
          ),
          
          // 2. Barra de navegación animada
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: 0,
            right: 0,
            // Si está visible, la posición inferior es 0. Si no, la bajamos -100 píxeles para esconderla.
            bottom: _isBottomNavBarVisible ? 0 : -100, 
            child: _buildCustomBottomNavBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black, // Color de fondo de la barra
        border: Border(top: BorderSide(color: Colors.grey.shade900, width: 1)),
      ),
      child: SafeArea(
        bottom: true,
        top: false,
        child: SizedBox(
          height: 70, // Altura de los iconos, el SafeArea se encarga del extra
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(icon: Icons.home_filled, label: 'Inicio', index: 0),
              _buildNavItem(icon: Icons.calendar_month, label: 'Citas', index: 1, badgeCount: 2), // badge de 2
              _buildNavItem(icon: Icons.storefront, label: 'Servicios', index: 2),
              _buildNavItem(icon: Icons.notifications, label: 'Avisos', index: 3, badgeCount: 1), // badge de 1
              _buildNavItem(icon: Icons.person, label: 'Perfil', index: 4),
            ],
          ),
        ),
      ),
    );
  }

  // Función para construir cada ícono individualmente
  Widget _buildNavItem({required IconData icon, required String label, required int index, int badgeCount = 0}) {
    // Si el índice seleccionado es igual al de este ícono, lo pintamos de dorado, sino gris
    final isSelected = _selectedIndex == index;
    final color = isSelected ? AppTheme.primaryGold : Colors.grey;

    return GestureDetector(
      onTap: () {
        // Actualizamos la pantalla al tocar un ícono
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        color: Colors.transparent, 
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none, // Permite que la burbuja roja salga del borde del ícono
              children: [
                Icon(icon, color: color, size: 28),
                // Si hay notificaciones, dibujamos el círculo rojo
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badgeCount.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
