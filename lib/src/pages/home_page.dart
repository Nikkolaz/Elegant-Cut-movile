import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/carita_widget.dart';
import '../widgets/animated_logo_text.dart';
import 'barber_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _firstName = 'Usuario';

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
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: isDark ? Colors.grey.shade900 : Colors.grey.shade200),
          ),
          child: Stack(
            children: [
              Icon(Icons.notifications_none_rounded, color: isDark ? Colors.white : Colors.black87),
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
      ],
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
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, String desc, IconData icon, Color bgColor, Color iconColor, bool isDark) {
    return Expanded(
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
