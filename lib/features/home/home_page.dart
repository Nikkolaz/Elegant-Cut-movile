import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/network/barber_api_service.dart';
import '../../core/network/reviews_api_service.dart';
import '../../shared/widgets/barber_avatar.dart';
import '../../shared/widgets/animated_logo_text.dart';
import '../barbers/barber_detail_page.dart';
import '../booking/book_appointment_page.dart';
import '../shop/shop_page.dart';
import 'create_review_page.dart';
import '../booking/ubicacion_page.dart';
import '../../core/network/booking_api_service.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _firstName = 'Usuario';
  Map<String, dynamic>? _nextAppointment;
  final BookingApiService _bookingApi = BookingApiService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadNextAppointment();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _firstName = prefs.getString('firstName') ?? 'Usuario';
    });
  }

  Future<void> _loadNextAppointment() async {
    final appointments = await _bookingApi.getUserAppointments();
    if (mounted) {
      try {
        final pending = appointments.firstWhere((a) => a['estado'] == 'Pendiente');
        setState(() {
          _nextAppointment = pending;
        });
      } catch (_) {
        setState(() {
          _nextAppointment = null;
        });
      }
    }
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

              _buildReviewsSection(isDark),

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
              'Hola, $_firstName',
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
        bool hasNotifications = true; //Esto es para crear las variables de estado
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
                            TextButton(
                              onPressed: () {
                                setModalState(() {
                                  hasNotifications = false;
                                });
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
                      hasNotifications
                          ? Expanded(
                              child: ListView(
                                padding: const EdgeInsets.symmetric(horizontal: 25),
                                physics: const BouncingScrollPhysics(),
                                children: [
                                  _buildNotificationItem(
                                    'Recordatorio de cita',
                                    'Tu cita con Marcus es mañana a las 10:00 AM.',
                                    'Hace 2h',
                                    Icons.calendar_today_rounded,
                                    const Color(0xFF4A90E2),
                                    isDark,
                                  ),
                                  _buildNotificationItem(
                                    'Nueva promoción',
                                    '¡20% de descuento en todos los servicios de barba esta semana!',
                                    'Hace 5h',
                                    Icons.local_offer_outlined,
                                    const Color(0xFF50C878),
                                    isDark,
                                  ),
                                  _buildNotificationItem(
                                    'Puntos acumulados',
                                    '¡Has ganado 50 puntos por tu último corte! Sigue así.',
                                    'Ayer',
                                    Icons.stars_rounded,
                                    const Color(0xFFFFD56B),
                                    isDark,
                                  ),
                                  _buildNotificationItem(
                                    'Perfil actualizado',
                                    'Tu información de perfil ha sido actualizada correctamente.',
                                    'Hace 2 días',
                                    Icons.person_outline_rounded,
                                    Colors.grey,
                                    isDark,
                                  ),
                                ],
                              ),
                            )
                          : Expanded(
                              child: Center(
                                child: Text(
                                  'No tienes notificaciones nuevas',
                                  style: GoogleFonts.outfit(
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
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
              'Servicios',
              'Cortes y estilos',
              Icons.shopping_bag_outlined,
              const Color(0xFFE8FFEF),
              const Color(0xFF50C878),
              isDark,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShopPage()),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
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
            const SizedBox(width: 20),
            _buildActionCard(
              'Crear Reseña',
              'Califica tu servicio',
              Icons.rate_review_outlined,
              const Color(0xFFFFF4E5),
              const Color(0xFFD48B41),
              isDark,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateReviewPage()),
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
        FutureBuilder<List<Map<String, dynamic>>>(
          future: BarberApiService().getBarbers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator(color: Color(0xFFD48B41))),
              );
            }

            final allExperts = snapshot.data ?? [];
            final experts = allExperts.take(5).toList();

            return SingleChildScrollView(
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
                  if (experts.isEmpty)
                    Text('No hay expertos disponibles.', style: GoogleFonts.outfit(color: Colors.grey)),
                  ...experts.map((exp) {
                    final colorHex = [0xFF98E68E, 0xFFFFB2D1, 0xFF88C9F9, 0xFFFFD56B];
                    final color = Color(colorHex[experts.indexOf(exp) % colorHex.length]);
                    final expression = experts.indexOf(exp) % 4;

                    return Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BarberDetailPage(
                                barber: {
                                  'id': exp['id'],
                                  'name': exp['name'],
                                  'color': color,
                                  'expression': expression,
                                  'specialties': exp['specialties'],
                                  'rating': exp['rating'],
                                  'reviews': exp['reviews'],
                                  'experience': exp['experience'],
                                  'isAvailable': exp['isAvailable'],
                                  'photoUrl': exp['photoUrl'],
                                  'portfolioPhotos': exp['portfolioPhotos'] ?? [],
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
                                child: BarberAvatar(
                                  photoUrl: exp['photoUrl'],
                                  size: 65,
                                  caritaColor: color,
                                  expressionType: expression,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(exp['name'] as String, style: GoogleFonts.outfit(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87)),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReviewsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reseñas Recientes',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              'Ver todas',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: const Color(0xFFD48B41),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: ReviewsApiService().getReviews(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator(color: Color(0xFFD48B41))),
              );
            }
            final reviews = snapshot.data ?? [];
            if (reviews.isEmpty) {
              return Text('No hay reseñas recientes.', style: GoogleFonts.outfit(color: Colors.grey));
            }
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: reviews.take(3).map((review) {
                  return Container(
                    width: 250,
                    margin: const EdgeInsets.only(right: 15),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person, color: Colors.grey),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                review['name'] ?? 'Usuario',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                              ),
                            ),
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < (review['rating'] ?? 5) ? Icons.star : Icons.star_border,
                                  color: const Color(0xFFFFD56B),
                                  size: 14,
                                );
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          review['comment'] ?? '',
                          style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNextAppointment(bool isDark) {
    if (_nextAppointment == null) {
      return const SizedBox.shrink();
    }

    String dateStr = _nextAppointment!['fecha'] ?? '';
    if (dateStr.isNotEmpty) {
      try {
        final dt = DateTime.parse(dateStr);
        dateStr = '${dt.day}/${dt.month}/${dt.year}';
      } catch (_) {}
    }

    final String serviceName = _nextAppointment!['servicio'] ?? 'Servicio reservado';
    final String timeStr = _nextAppointment!['hora'] ?? '';

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
                      serviceName,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      '$dateStr, $timeStr',
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
