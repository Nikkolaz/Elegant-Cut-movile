import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:elegant_cut_mobile/main.dart';
import 'package:elegant_cut_mobile/src/widgets/settings_tile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _promotionsEnabled = false;

  Future<void> _toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Hero(
          tag: 'settings_title',
          child: Material(
            color: Colors.transparent,
            child: Text(
              'Configuración',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black, 
                fontWeight: FontWeight.bold, 
                fontSize: 20
              ),
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          Hero(
            tag: 'settings_gear',
            child: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Icon(Icons.settings_outlined, color: isDark ? Colors.grey.shade400 : Colors.grey.shade800),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            
            // Sección: Cuenta
            _buildSectionHeader('CUENTA'),
            SettingsTile(
              icon: Icons.person_outline,
              title: 'Cambiar Username',
              subtitle: 'sandra_glam',
              onTap: _showEmailDialog,
            ),
            SettingsTile(
              icon: Icons.lock_outline,
              title: 'Cambiar Contraseña',
              subtitle: 'Último cambio hace 3 meses',
              onTap: _showPasswordDialog,
            ),
            
            const SizedBox(height: 20),
            
            // Sección: Apariencia
            _buildSectionHeader('APARIENCIA'),
            ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (context, mode, _) {
                return SwitchListTile(
                  secondary: _buildIconContainer(Icons.dark_mode_outlined, Colors.indigo),
                  title: Text(
                    'Modo Oscuro', 
                    style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)
                  ),
                  subtitle: Text(
                    'Cambiar el tema de la aplicación',
                    style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)
                  ),
                  value: mode == ThemeMode.dark,
                  activeColor: const Color(0xFFD48B41),
                  onChanged: (val) {
                    _toggleTheme(val);
                  },
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Sección: Notificaciones
            _buildSectionHeader('NOTIFICACIONES'),
            SettingsTile(
              icon: Icons.notifications_active_outlined,
              color: Colors.orange,
              title: 'Recordatorios de Citas',
              onTap: () {},
              trailing: Switch(
                value: _notificationsEnabled,
                activeColor: const Color(0xFFD48B41),
                onChanged: (val) => setState(() => _notificationsEnabled = val),
              ),
            ),
            SettingsTile(
              icon: Icons.card_giftcard_outlined,
              color: Colors.pink,
              title: 'Promociones y Ofertas',
              onTap: () {},
              trailing: Switch(
                value: _promotionsEnabled,
                activeColor: const Color(0xFFD48B41),
                onChanged: (val) => setState(() => _promotionsEnabled = val),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Sección: Privacidad
            _buildSectionHeader('PRIVACIDAD'),
            SettingsTile(
              icon: Icons.security_outlined,
              color: Colors.green,
              title: 'Privacidad y Seguridad',
              onTap: () => _showSnackbar('Cargando panel de privacidad...'),
            ),
            SettingsTile(
              icon: Icons.block_flipped,
              color: Colors.redAccent,
              title: 'Barberos Bloqueados',
              onTap: () => _showSnackbar('No tienes barberos bloqueados.'),
            ),
            
            const SizedBox(height: 20),
            
            // Sección: Acerca de
            _buildSectionHeader('ACERCA DE'),
            SettingsTile(
              icon: Icons.info_outline,
              color: Colors.blue,
              title: 'Términos de Servicio',
              onTap: () => _showSnackbar('Abriendo términos de servicio...'),
            ),
            SettingsTile(
              icon: Icons.privacy_tip_outlined,
              color: Colors.teal,
              title: 'Política de Privacidad',
              onTap: () => _showSnackbar('Abriendo política de privacidad...'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Text(
                'Versión 1.0.2 (Build 2405)',
                style: GoogleFonts.outfit(color: Colors.grey.shade500, fontSize: 12),
              ),
            ),
            
            const SizedBox(height: 20),
            
            const SizedBox(height: 40),
          ].animate(interval: 40.ms).fade(duration: 300.ms, curve: Curves.easeOut).slideX(begin: 0.05, curve: Curves.easeOut),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildIconContainer(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.outfit()),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
    );
  }

  void _showEmailDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Cambiar Username', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          content: TextField(
            style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: 'Nuevo nombre de usuario',
              hintStyle: GoogleFonts.outfit(color: Colors.grey),
              filled: true,
              fillColor: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFFD48B41), width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar', style: GoogleFonts.outfit(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showSnackbar('Username actualizado (simulado)');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD48B41),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Text('Guardar', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showPasswordDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Cambiar Contraseña', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                obscureText: true,
                style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Contraseña actual',
                  hintStyle: GoogleFonts.outfit(color: Colors.grey),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                obscureText: true,
                style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Nueva contraseña',
                  hintStyle: GoogleFonts.outfit(color: Colors.grey),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Color(0xFFD48B41), width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar', style: GoogleFonts.outfit(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showSnackbar('Contraseña actualizada (simulada)');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD48B41),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Text('Guardar', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
