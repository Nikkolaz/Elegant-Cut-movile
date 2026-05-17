import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/carita_widget.dart';
import '../widgets/animated_logo_text.dart';
import 'barber_detail_page.dart';
import 'book_appointment_page.dart';
import 'ubicacion_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _firstName = 'Usuario';
  List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Recordatorio de cita',
      'desc': 'Tu cita con Marcus es mañana a las 10:00 AM.',
      'time': 'Hace 2h',
      'icon': Icons.calendar_today_rounded,
      'color': const Color(0xFF4A90E2),
    },
    {
      'title': 'Nueva promoción',
      'desc': '¡20% de descuento en todos los servicios de barba esta semana!',
      'time': 'Hace 5h',
      'icon': Icons.local_offer_outlined,
      'color': const Color(0xFF50C878),
    },
    {
      'title': 'Puntos acumulados',
      'desc': '¡Has ganado 50 puntos por tu último corte! Sigue así.',
      'time': 'Ayer',
      'icon': Icons.stars_rounded,
      'color': const Color(0xFFFFD56B),
    },
    {
      'title': 'Perfil actualizado',
      'desc': 'Tu información de perfil ha sido actualizada correctamente.',
      'time': 'Hace 2 días',
      'icon': Icons.person_outline_rounded,
      'color': Colors.grey,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _firstName = prefs.getString('firstName') ?? 'Usuario';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(context, isDark),
              const SizedBox(height: 35),
              
              Text(
                '¿Qué quieres hacer hoy?',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              
              _buildQuickActionsGrid(isDark),
              
              const SizedBox(height: 40),
              
              _buildExpertSection(context, isDark),
              
              const SizedBox(height: 40),
              
              _buildNextAppointment(isDark),
              
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, $_firstName', // DINÁMICO
              style: GoogleFonts.outfit(
                fontSize: 18,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 5),
            AnimatedLogoText(isDark: isDark),
          ],

        ),
        GestureDetector(
          onTap: () => _showNotificationsModal(context, isDark),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: isDark ? Colors.grey.shade900 : Colors.grey.shade200),
            ),
            child: Stack(
              children: [
                Icon(Icons.notifications_none_rounded, color: isDark ? Colors.white : Colors.black87),
                if (_notifications.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6B6B),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showNotificationsModal(BuildContext context, bool isDark) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Notifications',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, anim1, anim2) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Notificaciones',
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            if (_notifications.isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  setModalState(() {
                                    _notifications.clear();
                                  });
                                  setState(() {});
                                },
                                child: Text(
                                  'Limpiar',
                                  style: GoogleFonts.outfit(color: const Color(0xFFD48B41)),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Expanded(
                        child: _notifications.isEmpty
                            ? Center(
                                child: Text(
                                  'No hay notificaciones',
                                  style: GoogleFonts.outfit(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 25),
                                physics: const BouncingScrollPhysics(),
                                itemCount: _notifications.length,
                                itemBuilder: (context, index) {
                                  final notif = _notifications[index];
                                  return _buildNotificationItem(
                                    notif['title'],
                                    notif['desc'],
                                    notif['time'],
                                    notif['icon'],
                                    notif['color'],
                                    isDark,
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: const Offset(0, 0),
          ).animate(CurvedAnimation(
            parent: anim1,
            curve: Curves.fastOutSlowIn,
          )),
          child: child,
        );
      },
    );
  }

  Widget _buildNotificationItem(
    String title,
    String desc,
    String time,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: isDark ? Colors.grey.shade900 : Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      time,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  desc,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            _buildActionCard(
              'Agendar Cita',
              'Reserva tu turno ahora',
              Icons.calendar_today_rounded,
              const Color(0xFFE8F1FF),
              const Color(0xFF4A90E2),
              isDark,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BookAppointmentPage()),
                );
              },
            ),
            const SizedBox(width: 20),
            _buildActionCard(
              'Tienda',
              'Productos premium',
              Icons.shopping_bag_outlined,
              const Color(0xFFE8FFEF),
              const Color(0xFF50C878),
              isDark,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _buildActionCard(
              'Cortes',
              'Mira las tendencias',
              Icons.content_cut_rounded,
              const Color(0xFFFFF8E1),
              const Color(0xFFF5A623),
              isDark,
            ),
            const SizedBox(width: 20),
            _buildActionCard(
              'Ubicación',
              '¿Cómo llegar?',
              Icons.location_on_outlined,
              const Color(0xFFFFE8E8),
              const Color(0xFFFF6B6B),
              isDark,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UbicacionPage()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, String desc, IconData icon, Color bgColor, Color iconColor, bool isDark, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : bgColor,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: isDark ? Colors.white : iconColor, size: 28),
            const SizedBox(height: 15),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              desc,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: isDark ? Colors.grey.shade500 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildExpertSection(BuildContext context, bool isDark) {
    final experts = [
      {'name': 'Marcus', 'color': const Color(0xFF98E68E), 'expression': 0},
      {'name': 'Alex', 'color': const Color(0xFFFFB2D1), 'expression': 1},
      {'name': 'Julian', 'color': const Color(0xFF88C9F9), 'expression': 3},
      {'name': 'Daniel', 'color': const Color(0xFFFFD56B), 'expression': 2},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nuestros Expertos',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Column(
                  children: [
                    Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1C1C1E) : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add, color: isDark ? Colors.white : Colors.black54),
                    ),
                    const SizedBox(height: 10),
                    Text('Favorito', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              ...experts.map((exp) => Padding(
                padding: const EdgeInsets.only(right: 20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BarberDetailPage(
                          barber: {
                            'name': exp['name'] as String,
                            'color': exp['color'],
                            'expression': exp['expression'],
                          },
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      SizedBox(
                        width: 65,
                        height: 65,
                        child: Hero(
                          tag: 'barber_hero_${exp['name']}',
                          child: CaritaWidget(
                            size: 65,
                            color: exp['color'] as Color,
                            expressionType: exp['expression'] as int,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(exp['name'] as String, style: GoogleFonts.outfit(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87)),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNextAppointment(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tu próxima cita',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: isDark ? Colors.grey.shade900 : Colors.grey.shade100),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFD48B41).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.access_time_rounded, color: Color(0xFFD48B41)),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Corte & Barba Premium',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Mañana, 14:00 PM con Marcus',
                      style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }
}
