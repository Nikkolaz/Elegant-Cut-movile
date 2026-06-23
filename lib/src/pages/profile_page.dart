import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elegant_cut_mobile/src/pages/settings_page.dart';
import 'package:elegant_cut_mobile/src/pages/login_page.dart';
import 'package:elegant_cut_mobile/src/widgets/summary_card.dart';
import 'package:elegant_cut_mobile/src/widgets/cuts_history_tab.dart';
import 'package:elegant_cut_mobile/src/widgets/favorite_barbers_tab.dart';
import 'package:elegant_cut_mobile/src/widgets/notifications_tab.dart';
import '../widgets/carita_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  String _firstName = 'Usuario';
  String _username = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _firstName = prefs.getString('firstName') ?? 'Usuario';
      _username = prefs.getString('username') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // ── Sección superior scrollable ──
        Container(
          color: theme.scaffoldBackgroundColor,
          padding: const EdgeInsets.fromLTRB(25, 20, 25, 0),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildUserInfo(context),
              const SizedBox(height: 20),
              _buildStatsAndActions(context),
              const SizedBox(height: 20),
              _buildSummarySection(context),
              const SizedBox(height: 24),
              _buildTabBar(isDark),
              const SizedBox(height: 4),
            ],
          ),
        ),

        // ── Contenido de la pestaña activa ──
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              CutsHistoryTab(),
              FavoriteBarbersTab(),
              NotificationsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Perfil',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        Hero(
          tag: 'settings_gear',
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.settings_outlined, size: 22,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade800),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFC7B8F5).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const CaritaWidget(size: 72, color: Color(0xFFC7B8F5), expressionType: 0),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_firstName,
                  style: GoogleFonts.outfit(
                    fontSize: 20, fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black)),
              Text('@$_username',
                  style: GoogleFonts.outfit(
                    fontSize: 13, color: Colors.grey.shade500)),
            ],
          ),
        ),
        // Botón logout compacto
        GestureDetector(
          onTap: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('firstName');
            await prefs.remove('username');
            await prefs.remove('email');
            await prefs.remove('token');
            await prefs.remove('id_usuario');
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (r) => false);
          },
          child: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.logout, color: Colors.red, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsAndActions(BuildContext context) {
    return Row(
      children: [
        _buildStat(context, 'Citas', '12'),
        const SizedBox(width: 28),
        _buildStat(context, 'Puntos', '450'),
        const Spacer(),
        _buildActionButton(context, Icons.ios_share),
        const SizedBox(width: 10),
        _buildActionButton(context, Icons.edit_outlined),
      ],
    );
  }

  Widget _buildStat(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade500)),
        Text(value, style: GoogleFonts.outfit(
          fontSize: 18, fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black)),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
      ),
      child: Icon(icon, size: 20, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: SummaryCard(
            title: 'Próxima Cita',
            value: '14:30',
            unit: 'Hoy',
            color: isDark ? const Color(0xFF1B5E20) : const Color(0xFFC8E6C9),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SummaryCard(
            title: 'Puntos Club',
            value: '450',
            unit: 'pts',
            color: isDark ? const Color(0xFFE65100) : const Color(0xFFFFCC80),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(bool isDark) {
    final tabs = [
      {'label': 'Historial', 'icon': Icons.history_rounded},
      {'label': 'Favoritos', 'icon': Icons.favorite_rounded},
      {'label': 'Notificaciones', 'icon': Icons.notifications_rounded},
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isSelected = _tabController.index == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => _tabController.animateTo(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? const Color(0xFF2C2C2E) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8, offset: const Offset(0, 2))]
                      : [],
                ),
                child: Column(
                  children: [
                    Icon(
                      tabs[i]['icon'] as IconData,
                      size: 18,
                      color: isSelected
                          ? const Color(0xFFD48B41)
                          : Colors.grey.shade400,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tabs[i]['label'] as String,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? (isDark ? Colors.white : Colors.black)
                            : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
