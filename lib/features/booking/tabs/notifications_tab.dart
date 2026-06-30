import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});
  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<Map<String, dynamic>> _notifs = [
    {
      'type': 'cita',
      'title': 'Cita confirmada',
      'body': 'Tu cita con Carlos M. mañana a las 14:30 está confirmada.',
      'time': 'Hace 5 min',
      'read': false,
      'icon': Icons.event_available_rounded,
      'color': const Color(0xFF98E68E),
    },
    {
      'type': 'promo',
      'title': '¡Oferta especial!',
      'body': '20% de descuento en productos esta semana. ¡No te lo pierdas!',
      'time': 'Hace 2 horas',
      'read': false,
      'icon': Icons.local_offer_rounded,
      'color': const Color(0xFFD48B41),
    },
    {
      'type': 'recordatorio',
      'title': 'Recordatorio de cita',
      'body': 'Tienes una cita con Luis R. en 24 horas.',
      'time': 'Ayer',
      'read': true,
      'icon': Icons.alarm_rounded,
      'color': const Color(0xFF88C9F9),
    },
    {
      'type': 'puntos',
      'title': '¡Ganaste puntos!',
      'body': 'Acumulaste 50 puntos en tu último corte. Total: 450 pts.',
      'time': 'Hace 3 días',
      'read': true,
      'icon': Icons.stars_rounded,
      'color': const Color(0xFFB4B0FE),
    },
    {
      'type': 'promo',
      'title': 'Nuevo barbero disponible',
      'body': 'Miguel Ángel ahora tiene horarios libres esta semana.',
      'time': 'Hace 5 días',
      'read': true,
      'icon': Icons.person_add_rounded,
      'color': const Color(0xFFFFD56B),
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _markAllRead() {
    setState(() {
      for (final n in _notifs) {
        n['read'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unread = _notifs.where((n) => !(n['read'] as bool)).length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(25, 10, 25, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (unread > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD48B41).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$unread sin leer',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFD48B41),
                    ),
                  ),
                )
              else
                const SizedBox(),
              if (unread > 0)
                GestureDetector(
                  onTap: _markAllRead,
                  child: Text(
                    'Marcar todas',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(25, 4, 25, 120),
            physics: const BouncingScrollPhysics(),
            itemCount: _notifs.length,
            itemBuilder: (context, i) {
              final n = _notifs[i];
              final anim = CurvedAnimation(
                parent: _controller,
                curve: Interval(i * 0.12, 1.0, curve: Curves.easeOutCubic),
              );
              return AnimatedBuilder(
                animation: anim,
                builder: (context, child) => Opacity(
                  opacity: anim.value,
                  child: Transform.translate(
                    offset: Offset(20 * (1 - anim.value), 0),
                    child: child,
                  ),
                ),
                child: Dismissible(
                  key: Key('notif_$i'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.delete_rounded,
                        color: Colors.white, size: 22),
                  ),
                  onDismissed: (_) => setState(() => _notifs.removeAt(i)),
                  child: GestureDetector(
                    onTap: () => setState(() => n['read'] = true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (n['read'] as bool)
                            ? (isDark
                                ? const Color(0xFF1E1E1E)
                                : Colors.white)
                            : (isDark
                                ? const Color(0xFF252525)
                                : const Color(0xFFFFF8F2)),
                        borderRadius: BorderRadius.circular(20),
                        border: (n['read'] as bool)
                            ? null
                            : Border.all(
                                color: const Color(0xFFD48B41).withOpacity(0.3),
                                width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(isDark ? 0.25 : 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: (n['color'] as Color).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(n['icon'] as IconData,
                                size: 20, color: n['color'] as Color),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        n['title'] as String,
                                        style: GoogleFonts.outfit(
                                          fontWeight: (n['read'] as bool)
                                              ? FontWeight.w500
                                              : FontWeight.w700,
                                          fontSize: 14,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    if (!(n['read'] as bool))
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFD48B41),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  n['body'] as String,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  n['time'] as String,
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
