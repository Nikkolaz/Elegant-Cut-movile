import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
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
          body: Stack(
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
              
              // Animated Bottom Bar
              ValueListenableBuilder<bool>(
                valueListenable: _isVisible,
                builder: (context, visible, _) {
                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    left: 20,
                    right: 20,
                    bottom: visible ? MediaQuery.of(context).padding.bottom + 10 : -100,
                    child: Container(
                      height: 70,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xEE1C1C1E) : const Color(0xEEDFDFE3),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
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
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, int selectedIndex) {
    final bool isSelected = selectedIndex == index;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color activeColor = const Color(0xFFD48B41);
    final Color inactiveColor = isDark ? Colors.grey.shade500 : Colors.grey.shade600;

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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Nav item indicator & icon container
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? activeColor.withOpacity(0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: isSelected ? activeColor : inactiveColor,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
