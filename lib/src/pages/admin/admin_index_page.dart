import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:elegant_cut_mobile/src/pages/admin/admin_dashboard_page.dart';
import 'package:elegant_cut_mobile/src/pages/admin/admin_users_page.dart';
import 'package:elegant_cut_mobile/src/pages/admin/admin_appointments_page.dart';
import 'package:elegant_cut_mobile/src/pages/profile_page.dart';

class AdminIndexPage extends StatefulWidget {
  const AdminIndexPage({super.key});

  @override
  State<AdminIndexPage> createState() => _AdminIndexPageState();
}

class _AdminIndexPageState extends State<AdminIndexPage> {
  final PageController _pageController = PageController();
  final ValueNotifier<bool> _isVisible = ValueNotifier<bool>(true);
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const AdminDashboardPage(),
      const AdminUsersPage(),
      const AdminAppointmentsPage(),
      ProfilePage(), // Usamos el ProfilePage existente
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

                // Barra de Navegación Animada para Admin
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
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          border: Border(
                            top: BorderSide(
                              color: isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, -5),
                            )
                          ]
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildNavItem(context, Icons.dashboard_rounded, 'Dashboard', 0, selectedIndex),
                            _buildNavItem(context, Icons.people_alt_rounded, 'Usuarios', 1, selectedIndex),
                            _buildNavItem(context, Icons.calendar_today_rounded, 'Citas', 2, selectedIndex),
                            _buildNavItem(context, Icons.person, 'Perfil', 3, selectedIndex),
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
        ? const Color(0xFFD48B41) // Color primario Elegant Cut
        : (isDark ? Colors.grey.shade500 : Colors.grey.shade400);

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
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              transform: Matrix4.identity()..scale(isSelected ? 1.15 : 1.0),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, color: color, size: 26),
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
            ),
            const SizedBox(height: 4),
            AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
