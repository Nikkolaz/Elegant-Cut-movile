import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/widgets/rating_slider.dart';
import '../../core/network/booking_api_service.dart';

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
    setState(() { _isLoading = true; });
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
            final double fullWidth = constraints.maxWidth;
            final double horizontalPadding = 25.0;
            final double contentWidth = fullWidth - (horizontalPadding * 2);

            return Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 25),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tus citas', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                              Text('${_appointments.length} citas registradas', style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey.shade500)),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => _showFilterModal(context, isDark),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: isDark ? const Color(0xFF1C1C1E) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.grey.shade900 : Colors.grey.shade200)),
                              child: const Icon(Icons.tune, color: Colors.grey, size: 22),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD48B41)))
                          : _appointments.isEmpty
                              ? Center(child: Text('No hay citas agendadas todavía', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16)))
                              : ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(horizontal: 0),
                                  itemCount: _appointments.length + 1,
                                  itemBuilder: (context, index) {
                                    if (index == 0) {
                                      return _buildHeaderSection(isDark);
                                    }
                                    final appointment = _appointments[index - 1];
                                    return _buildAppointmentCard(appointment, isDark, contentWidth);
                                  },
                                ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showFilterModal(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(35))),
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 25),
              Text('Filtrar citas', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 20),
              Text('Estado', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black54)),
              const SizedBox(height: 10),
              _buildFilterChip(isDark, 'Todas', () {}),
              const SizedBox(height: 10),
              _buildFilterChip(isDark, 'Pendientes', () {}),
              const SizedBox(height: 10),
              _buildFilterChip(isDark, 'Completadas', () {}),
              const SizedBox(height: 10),
              _buildFilterChip(isDark, 'Canceladas', () {}),
              const SizedBox(height: 30),
              SwitchListTile(
                title: Text('Recordatorios', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                subtitle: Text('Notificaciones push 24h antes', style: GoogleFonts.outfit(fontSize: 13, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                value: _remindersEnabled,
                activeColor: const Color(0xFFD48B41),
                onChanged: (val) { setState(() => _remindersEnabled = val); },
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(bool isDark, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: GoogleFonts.outfit(color: isDark ? Colors.white70 : Colors.black87, fontSize: 15)),
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade400, width: 2)),
              child: const Icon(Icons.circle, color: Colors.transparent, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark ? [const Color(0xFF1C1C1E), const Color(0xFF2C2520)] : [Colors.white, const Color(0xFFFFF5EE)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: isDark ? [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))] : [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Próxima cita', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFFD48B41), letterSpacing: 1.2)),
                          const SizedBox(height: 10),
                          Text('Corta & Diseña', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black, letterSpacing: -0.5)),
                          const SizedBox(height: 6),
                          Text('Hoy, 14:30', style: GoogleFonts.outfit(fontSize: 15, color: isDark ? Colors.grey.shade400 : Colors.black54)),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              _buildPill('3 servicios', isDark),
                              const SizedBox(width: 10),
                              _buildPill('Confirmada', isDark),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _isIslandExpanded = !_isIslandExpanded),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 60, height: _isIslandExpanded ? 120 : 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD48B41).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Transform.rotate(
                              angle: _isIslandExpanded ? 0.5 : 0,
                              child: const Icon(Icons.more_horiz_outlined, color: Color(0xFFD48B41), size: 20),
                            ),
                            if (_isIslandExpanded) ...[
                              const SizedBox(height: 8),
                              GestureDetector(onTap: () {}, child: const Icon(Icons.edit_outlined, color: Color(0xFFD48B41), size: 18)),
                              const SizedBox(height: 8),
                              GestureDetector(onTap: () {}, child: const Icon(Icons.close_outlined, color: Colors.redAccent, size: 18)),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Text('Historial de citas', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildPill(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFD48B41).withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFD48B41))),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment, bool isDark, double contentWidth) {
    final infoIdx = _appointments.indexOf(appointment);
    final List<Map<String, dynamic>> history = [
      {'name': 'Corte Premium + Barba', 'barber': 'Carlos M.', 'date': '20 enero', 'price': r'$45', 'status': 'Completada'},
      {'name': 'Sesión Facial', 'barber': 'Luis R.', 'date': '10 enero', 'price': r'$30', 'status': 'Completada'},
      {'name': 'Corte Degradado', 'barber': 'Miguel A.', 'date': '28 dic', 'price': r'$35', 'status': 'Cancelada'},
      {'name': 'Perfilado Barba', 'barber': 'Carlos M.', 'date': '15 dic', 'price': r'$20', 'status': 'Completada'},
      {'name': 'Corte + Tinte', 'barber': 'Sofía G.', 'date': '5 dic', 'price': r'$75', 'status': 'Completada'},
    ];

    bool isCanceled = history[infoIdx]['status'] == 'Cancelada';
    bool isCompleted = history[infoIdx]['status'] == 'Completada';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 6),
      child: GestureDetector(
        onTap: () {
          if (isCompleted) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => _RatingModal(isDark: isDark, historyItem: history[infoIdx]),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: isDark ? Colors.grey.shade900 : Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${infoIdx + 1}', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: isCanceled ? Colors.red.withOpacity(0.1) : (isCompleted ? Colors.green.withOpacity(0.1) : const Color(0xFFD48B41).withOpacity(0.1)),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCanceled ? Icons.cancel_outlined : (isCompleted ? Icons.check_circle_outline : Icons.schedule_rounded),
                      color: isCanceled ? Colors.red : (isCompleted ? Colors.green : const Color(0xFFD48B41)),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(history[infoIdx]['name'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                    const SizedBox(height: 4),
                    Text('${history[infoIdx]['barber']} • ${history[infoIdx]['date']}', style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(history[infoIdx]['price'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white70 : Colors.black87)),
                  const SizedBox(height: 5),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFFD48B41).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                      child: Text('Calificar', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFFD48B41))),
                    ),
                  if (isCanceled)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: Colors.red.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                      child: Text('Cancelada', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.red)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RatingModal extends StatefulWidget {
  final bool isDark;
  final Map<String, dynamic> historyItem;

  const _RatingModal({required this.isDark, required this.historyItem});

  @override
  State<_RatingModal> createState() => _RatingModalState();
}

class _RatingModalState extends State<_RatingModal> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _ratingValue = 0.7;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.55,
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
        ),
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text('¿Cómo fue tu experiencia?', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: widget.isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 8),
            Text('${widget.historyItem['name']} con ${widget.historyItem['barber']}', style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey.shade500)),
            const SizedBox(height: 30),
            RatingSlider(onChanged: (val) { setState(() { _ratingValue = val; }); }),
            const SizedBox(height: 30),
            TextField(
              style: GoogleFonts.outfit(color: widget.isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'Cuéntanos cómo te fue...',
                hintStyle: GoogleFonts.outfit(color: Colors.grey),
                filled: true,
                fillColor: widget.isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD48B41), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0,
                ),
                child: Text('Enviar calificación', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
