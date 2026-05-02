import 'package:flutter/material.dart';
import 'package:elegant_cut_mobile/src/pages/settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
            // 1. Header (Back y Settings)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.arrow_back_ios_new,
                  size: 20,
                  color: isDark ? Colors.white : Colors.grey.shade800,
                ),
                Text(
                  'Profile',
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
            ),
            const SizedBox(height: 30),

            // 2. Info de Usuario
            Row(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?u=sandra',
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sandra Glam',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      'Denmark, Copenhagen',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 25),

            // 3. Stats y Botones de acción
            Row(
              children: [
                _buildStat(context, 'Follow', '72'),
                const SizedBox(width: 30),
                _buildStat(context, 'Followers', '162'),
                const Spacer(),
                _buildActionButton(context, Icons.ios_share),
                const SizedBox(width: 10),
                _buildActionButton(context, Icons.edit_outlined),
              ],
            ),
            const SizedBox(height: 30),

            // 4. Tarjetas de Resumen
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Próxima Cita',
                    value: '14:30',
                    unit: 'Hoy',
                    color: isDark ? const Color(0xFF1B5E20) : const Color(0xFFC8E6C9),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Cortes Totales',
                    value: '12',
                    unit: 'estilos',
                    color: isDark ? const Color(0xFF01579B) : const Color(0xFFB3E5FC),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Puntos Club',
                    value: '450',
                    unit: 'pts',
                    color: isDark ? const Color(0xFFE65100) : const Color(0xFFFFCC80),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 35),

            // 5. Lista de Menú
            _buildMenuItem(
              context,
              Icons.history,
              'Historial de Cortes',
              'Ver mis estilos anteriores',
            ),
            _buildMenuItem(
              context,
              Icons.favorite_border,
              'Barberos Favoritos',
              'Tus expertos preferidos',
            ),
            _buildMenuItem(
              context,
              Icons.credit_card,
              'Métodos de Pago',
              'Gestionar tus tarjetas',
            ),
            _buildMenuItem(
              context,
              Icons.notifications_none,
              'Notificaciones',
              'Citas y promociones',
            ),
            _buildMenuItem(
              context,
              Icons.help_outline,
              'Soporte y Ayuda',
              '¿Necesitas algo?',
            ),

            const SizedBox(height: 120), // Espacio extra para el scroll
          ],
        ),
      ),
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

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String subtitle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Colors.grey.shade700 : Colors.grey.shade400),
        ],
      ),
    );
  }
}
