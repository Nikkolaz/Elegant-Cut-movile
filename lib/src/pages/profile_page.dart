import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elegant_cut_mobile/src/pages/settings_page.dart';
import 'package:elegant_cut_mobile/src/pages/login_page.dart';
import 'package:elegant_cut_mobile/src/widgets/summary_card.dart';
import 'package:elegant_cut_mobile/src/widgets/profile_menu_item.dart';
import '../widgets/carita_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _firstName = 'Usuario';
  String _username = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _firstName = prefs.getString('firstName') ?? 'Usuario';
      _username = prefs.getString('username') ?? '';
      _email = prefs.getString('email') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildHeader(context),
            const SizedBox(height: 30),

            _buildUserInfo(context),
            const SizedBox(height: 25),

            _buildStatsAndActions(context),
            const SizedBox(height: 30),

            _buildSummarySection(context),
            const SizedBox(height: 35),

            _buildMenuSection(context),

            const SizedBox(height: 30),

            // Botón Cerrar Sesión
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () async {
                    // Limpiar memoria al salir
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('firstName');
                    await prefs.remove('username');
                    
                    if (!mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: isDark ? Colors.red.withOpacity(0.1) : Colors.red.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout, color: Colors.red, size: 20),
                      const SizedBox(width: 10),
                      const Text(
                        'Cerrar Sesión',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(
          Icons.arrow_back_ios_new,
          size: 20,
          color: isDark ? Colors.white : Colors.grey.shade800,
        ),
        Text(
          'Perfil',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        Hero(
          tag: 'settings_gear',
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.settings_outlined,
                size: 22,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade800,
              ),
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
        // Avatar Estilo Carita para el usuario también
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFC7B8F5).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const CaritaWidget(
            size: 80,
            color: Color(0xFFC7B8F5),
            expressionType: 0,
          ),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _firstName, // DINÁMICO
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            Text(
              '@$_username', // DINÁMICO
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsAndActions(BuildContext context) {
    return Row(
      children: [
        _buildStat(context, 'Citas', '12'),
        const SizedBox(width: 30),
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
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
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

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      children: const [
        ProfileMenuItem(
          icon: Icons.history,
          title: 'Historial de Cortes',
          subtitle: 'Ver mis estilos anteriores',
        ),
        ProfileMenuItem(
          icon: Icons.favorite_border,
          title: 'Barberos Favoritos',
          subtitle: 'Tus expertos preferidos',
        ),
        ProfileMenuItem(
          icon: Icons.notifications_none,
          title: 'Notificaciones',
          subtitle: 'Citas y promociones',
        ),
      ],
    );
  }
}
