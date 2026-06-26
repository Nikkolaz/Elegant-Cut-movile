import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'admin_dashboard_page.dart';
import 'admin_users_page.dart';
import 'admin_appointments_page.dart';
import '../profile/profile_page.dart';

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
                              color: isDark ? Colors.grey.shade900 : Colors.grey.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildNavItem(Icons.dashboard_rounded, 'Dashboard', 0, selectedIndex),
                            _buildNavItem(Icons.people_alt_rounded, 'Usuarios', 1, selectedIndex),
                            _buildNavItem(Icons.calendar_month_rounded, 'Citas', 2, selectedIndex),
                            _buildNavItem(Icons.person_rounded, 'Perfil', 3, selectedIndex),
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

  Widget _buildNavItem(IconData icon, String label, int index, int selectedIndex) {
    final bool isSelected = selectedIndex == index;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color color = isSelected
        ? const Color(0xFFD48B41)
        : (isDark ? Colors.grey.shade600 : Colors.grey.shade400);

    return GestureDetector(
      onTap: () {
        _selectedIndex.value = index;
        _pageController.animateToPage(index, duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
