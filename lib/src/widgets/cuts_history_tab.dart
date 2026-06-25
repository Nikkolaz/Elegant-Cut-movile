import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../api/booking_api_service.dart';

class CutsHistoryTab extends StatefulWidget {
  const CutsHistoryTab({super.key});
  @override
  State<CutsHistoryTab> createState() => _CutsHistoryTabState();
}

class _CutsHistoryTabState extends State<CutsHistoryTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final BookingApiService _bookingApi = BookingApiService();
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _cuts = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadCuts();
  }

  Future<void> _loadCuts() async {
    final appointments = await _bookingApi.getUserAppointments();
    if (mounted) {
      setState(() {
        _cuts = appointments;
        _isLoading = false;
      });
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFD48B41)));
    }
    
    if (_cuts.isEmpty) {
      return Center(
        child: Text(
          'No hay historial de citas',
          style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 120),
      physics: const BouncingScrollPhysics(),
      itemCount: _cuts.length,
      itemBuilder: (context, i) {
        final cut = _cuts[i];
        
        // Formatear datos de la API
        String dateStr = cut['fecha'] ?? '';
        if (dateStr.isNotEmpty) {
          try {
            final dt = DateTime.parse(dateStr);
            dateStr = '${dt.day}/${dt.month}/${dt.year}';
          } catch (_) {}
        }
        final String serviceName = cut['servicio'] ?? 'Corte General';
        final String priceStr = cut['precio'] != null ? '\$${cut['precio']}' : '\$0';
        final String status = cut['estado'] ?? 'Pendiente';
        final String dateTimeDisplay = '$dateStr - ${cut['hora'] ?? ''}';
        
        final Color itemColor = status == 'Pendiente' ? const Color(0xFF88C9F9) : const Color(0xFFD48B41);
        final IconData itemIcon = status == 'Pendiente' ? Icons.calendar_today : Icons.content_cut;

        final anim = CurvedAnimation(
          parent: _controller,
          curve: Interval(i * 0.15 > 1.0 ? 1.0 : i * 0.15, 1.0, curve: Curves.easeOutCubic),
        );
        return AnimatedBuilder(
          animation: anim,
          builder: (context, child) => Opacity(
            opacity: anim.value,
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - anim.value)),
              child: child,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 25, right: 25),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Línea de tiempo
                Column(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: itemColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(itemIcon,
                          color: itemColor, size: 20),
                    ),
                    if (i < _cuts.length - 1)
                      Container(
                        width: 2,
                        height: 60,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              itemColor.withOpacity(0.4),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 15),
                // Card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E1E1E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              serviceName,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            Text(
                              priceStr,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: itemColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          status,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: List.generate(
                                5,
                                (s) => Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: status == 'Completada' ? const Color(0xFFD48B41) : Colors.grey.withOpacity(0.3),
                                ),
                              ),
                            ),
                            Text(
                              dateTimeDisplay,
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
