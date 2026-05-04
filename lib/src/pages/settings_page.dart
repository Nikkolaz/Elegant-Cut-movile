import 'package:flutter/material.dart';
import 'package:elegant_cut_mobile/main.dart';
import 'package:elegant_cut_mobile/src/pages/login_page.dart';
import 'package:elegant_cut_mobile/src/widgets/settings_tile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _promotionsEnabled = false;

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
        title: const Hero(
          tag: 'settings_title',
          child: Material(
            color: Colors.transparent,
            child: Text(
              'Configuración',
              style: TextStyle(
                color: Colors.black, 
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
              icon: Icons.email_outlined,
              title: 'Actualizar Correo',
              subtitle: 'sandra.glam@example.com',
              onTap: () {},
            ),
            SettingsTile(
              icon: Icons.lock_outline,
              title: 'Cambiar Contraseña',
              subtitle: 'Último cambio hace 3 meses',
              onTap: () {},
            ),
            
            const SizedBox(height: 20),
            
            // Sección: Apariencia
            _buildSectionHeader('APARIENCIA'),
            SwitchListTile(
              secondary: _buildIconContainer(Icons.dark_mode_outlined, Colors.indigo),
              title: Text(
                'Modo Oscuro', 
                style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)
              ),
              subtitle: Text(
                'Cambiar el tema de la aplicación',
                style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)
              ),
              value: themeNotifier.value == ThemeMode.dark,
              activeColor: const Color(0xFFD48B41),
              onChanged: (val) {
                setState(() {
                  themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                });
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
              onTap: () {},
            ),
            SettingsTile(
              icon: Icons.block_flipped,
              color: Colors.redAccent,
              title: 'Barberos Bloqueados',
              onTap: () {},
            ),
            
            const SizedBox(height: 20),
            
            // Sección: Acerca de
            _buildSectionHeader('ACERCA DE'),
            SettingsTile(
              icon: Icons.info_outline,
              color: Colors.blue,
              title: 'Términos de Servicio',
              onTap: () {},
            ),
            SettingsTile(
              icon: Icons.privacy_tip_outlined,
              color: Colors.teal,
              title: 'Política de Privacidad',
              onTap: () {},
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Text(
                'Versión 1.0.2 (Build 2405)',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ),
            
            const SizedBox(height: 20),
            
            const SizedBox(height: 40),
          ],
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
}
