import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/rating_slider.dart';
import '../api/booking_api_service.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  bool _isIslandExpanded = false;
  bool _remindersEnabled = true;
  bool _isLoading = true;
  List<Map<String, dynamic>> _appointments = [];
  final BookingApiService _bookingApi = BookingApiService();

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    setState(() {
      _isLoading = true;
    });
    
    final appointments = await _bookingApi.getUserAppointments();
    
    setState(() {
      _appointments = appointments;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FB),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Forzamos el ancho máximo disponible para evitar errores de "unbounded width"
            final double fullWidth = constraints.maxWidth;
            final double horizontalPadding = 25.0;
            final double contentWidth = fullWidth - (horizontalPadding * 2);

            return Stack(
              children: [
                // Contenido principal
                Positioned.fill(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: SizedBox(
                      width: contentWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _buildHeader(isDark),
                          const SizedBox(height: 35),
                          
                          Text(
                            'Mis Citas',
                            style: GoogleFonts.outfit(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 25),
                          
                          // Stats Cards
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatCard(
                                'Tiempo total',
                                '3h 45m',
                                Icons.access_time_filled_rounded,
                                const Color(0xFFA78BFA),
                                isDark,
                                (contentWidth - 15) / 2,
                              ),
                              _buildStatCard(
                                'Cortes realizados',
                                '12 cortes',
                                Icons.content_cut_rounded,
                                const Color(0xFF60A5FA),
                                isDark,
                                (contentWidth - 15) / 2,
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Streak Tracker
                          _buildStreakTracker(isDark, contentWidth),
                          
                          const SizedBox(height: 40),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Historial',
                                style: GoogleFonts.outfit(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              Text(
                                'Ver todo',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          _isLoading
                              ? const Center(child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: CircularProgressIndicator(color: Color(0xFFD48B41)),
                                ))
                              : _appointments.isEmpty
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Text(
                                          'No tienes citas agendadas.',
                                          style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16),
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: _appointments.length,
                                      separatorBuilder: (context, index) => const SizedBox(height: 15),
                                      itemBuilder: (context, index) {
                                        return _buildAppointmentItem(
                                          _appointments[index], 
                                          isDark,
                                          contentWidth,
                                        );
                                      },
                                    ),
                          
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ),

                // Backdrop para cerrar la isla
                if (_isIslandExpanded)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => setState(() => _isIslandExpanded = false),
                      behavior: HitTestBehavior.opaque,
                      child: Container(color: Colors.transparent),
                    ),
                  ),

                // Dynamic Island Menu
                _buildDynamicIsland(isDark),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildDynamicIsland(bool isDark) {
    return AnimatedAlign(
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: GestureDetector(
          onTap: () => setState(() => _isIslandExpanded = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
            width: _isIslandExpanded ? 300 : 0,
            height: _isIslandExpanded ? 70 : 0,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isIslandExpanded ? 1 : 0,
              child: _isIslandExpanded ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.notifications_active_rounded, 
                            color: isDark ? Colors.white : Colors.black87, 
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              'Recordatorios',
                              style: GoogleFonts.outfit(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _remindersEnabled,
                      activeColor: const Color(0xFFD48B41),
                      onChanged: (val) {
                        setState(() {
                          _remindersEnabled = val;
                        });
                      },
                    ),
                  ],
                ),
              ) : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: const DecorationImage(
              image: NetworkImage('https://i.pravatar.cc/150?u=user'),
              fit: BoxFit.cover,
            ),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _isIslandExpanded = true;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: isDark ? Colors.grey.shade900 : Colors.grey.shade200),
            ),
            child: Icon(Icons.more_horiz_rounded, color: isDark ? Colors.white : Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDark, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStreakTracker(bool isDark, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isDark ? Colors.grey.shade900 : Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD56B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.flash_on_rounded, color: Color(0xFFFFD56B)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Racha de fidelidad',
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '¡10 meses seguidos!',
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildAppointmentItem(Map<String, dynamic> appointment, bool isDark, double width) {
    // Parse fecha para mostrarla bonito
    String dateStr = appointment['fecha'] ?? '';
    if (dateStr.isNotEmpty) {
      try {
        final dt = DateTime.parse(dateStr);
        dateStr = '${dt.day}/${dt.month}/${dt.year}';
      } catch (_) {}
    }
    
    final bool isPendiente = appointment['estado'] == 'Pendiente';
    final Color itemColor = isPendiente ? const Color(0xFF60A5FA) : const Color(0xFFA78BFA);
    final IconData itemIcon = isPendiente ? Icons.calendar_today_rounded : Icons.check_circle_outline_rounded;
    
    return GestureDetector(
      onTap: () => isPendiente ? null : _showReviewModal(context, appointment),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: isDark ? Colors.grey.shade900 : Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: itemColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(itemIcon, color: itemColor),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment['servicio'] ?? 'Servicio',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '$dateStr • ${appointment['hora'] ?? ''}',
                    style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isPendiente ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isPendiente ? 'Pendiente' : 'Opinar',
                style: GoogleFonts.outfit(
                  color: isPendiente ? Colors.orange : Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReviewModal(BuildContext context, Map<String, dynamic> appointment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          ),
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                '¿Qué te pareció el servicio?',
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Tu opinión sobre ${appointment['service']} con ${appointment['barber']} nos ayuda a mejorar.',
                style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              RatingSlider(
                onChanged: (val) {
                  // Manejar cambio de rating
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD48B41),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Enviar Reseña',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
