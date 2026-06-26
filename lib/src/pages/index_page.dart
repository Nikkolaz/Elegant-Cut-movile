import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:elegant_cut_mobile/src/pages/home_page.dart';
import 'package:elegant_cut_mobile/src/pages/profile_page.dart';
import 'package:elegant_cut_mobile/src/pages/appointments_page.dart';

import 'package:elegant_cut_mobile/src/pages/barbers_page.dart';
import 'package:elegant_cut_mobile/src/pages/shop_page.dart';


class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final PageController _pageController = PageController();
  final ValueNotifier<bool> _isVisible = ValueNotifier<bool>(true);
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(),
      const AppointmentsPage(),
      const ShopPage(),

      const BarbersPage(),

      ProfilePage(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    _isVisible.dispose();
    _selectedIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder<int>(
      valueListenable: _selectedIndex,
      builder: (context, selectedIndex, _) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Stack(
              children: [
                NotificationListener<UserScrollNotification>(
                  onNotification: (notification) {
                    if (notification.direction == ScrollDirection.reverse) {
                      if (_isVisible.value) _isVisible.value = false;
                    } else if (notification.direction == ScrollDirection.forward) {
                      if (!_isVisible.value) _isVisible.value = true;
                    }
                    return false;
                  },
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) => _selectedIndex.value = index,
                    children: _pages,
                  ),
                ),

                // Barra de Navegación Animada
                ValueListenableBuilder<bool>(
                  valueListenable: _isVisible,
                  builder: (context, visible, _) {
                    return AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      left: 0,
                      right: 0,
                      bottom: visible ? 0 : -100,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          border: Border(
                            top: BorderSide(
                              color: isDark
                                  ? Colors.grey.shade900
                                  : Colors.grey.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildNavItem(context, Icons.home_filled, 'Inicio', 0, selectedIndex),
                            _buildNavItem(context, Icons.calendar_month, 'Citas', 1, selectedIndex),
                            _buildNavItem(context, Icons.storefront, 'Servicios', 2, selectedIndex),
                            _buildNavItem(
                              context,
                              Icons.face_retouching_natural,
                              'Barberos',
                              3,
                              selectedIndex,
                            ),
                            _buildNavItem(context, Icons.person, 'Perfil', 4, selectedIndex),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
    int selectedIndex, {
    int badgeCount = 0,
  }) {
    final bool isSelected = selectedIndex == index;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color color = isSelected
        ? const Color(0xFFD48B41)
        : (isDark ? Colors.grey.shade600 : Colors.grey.shade400);

    return GestureDetector(
      onTap: () {
        _selectedIndex.value = index;
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 28),
                if (badgeCount > 0)
                  Positioned(
                    right: -5,
                    top: -5,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
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
    );
  }
}

class _DummyPage extends StatelessWidget {
  final String title;
  const _DummyPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(color: Colors.grey, fontSize: 24),
      ),
    );
  }
}
