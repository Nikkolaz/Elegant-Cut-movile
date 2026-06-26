import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/network/booking_api_service.dart';

class RescheduleSheet extends StatefulWidget {
  final bool isDark;
  final Map<String, dynamic> appointment;

  const RescheduleSheet({
    super.key,
    required this.isDark,
    required this.appointment,
  });

  @override
  State<RescheduleSheet> createState() => _RescheduleSheetState();
}

class _RescheduleSheetState extends State<RescheduleSheet> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  int _selectedTimeSlot = -1;
  List<Map<String, dynamic>> _timeSlots = [];
  bool _isLoadingSlots = true;
  bool _isSubmitting = false;
  final BookingApiService _bookingApi = BookingApiService();

  @override
  void initState() {
    super.initState();
    _fetchSlots();
  }

  Future<void> _fetchSlots() async {
    setState(() {
      _isLoadingSlots = true;
      _selectedTimeSlot = -1;
    });

    final barberId = widget.appointment['barber_id'] ?? 1;
    final slots = await _bookingApi.getAvailableSlots(
      _selectedDate,
      barberId is int ? barberId : int.parse(barberId.toString()),
    );

    if (mounted) {
      setState(() {
        _timeSlots = slots;
        _isLoadingSlots = false;
      });
    }
  }

  Future<void> _confirmReschedule() async {
    if (_selectedTimeSlot < 0) return;

    HapticFeedback.heavyImpact();
    setState(() => _isSubmitting = true);

    final success = await _bookingApi.rescheduleAppointment(
      appointmentId: widget.appointment['id'],
      fecha: _selectedDate,
      idHorarios: _timeSlots[_selectedTimeSlot]['id'] is int
          ? _timeSlots[_selectedTimeSlot]['id']
          : int.parse(_timeSlots[_selectedTimeSlot]['id'].toString()),
    );

    if (mounted) {
      setState(() => _isSubmitting = false);

      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cita reprogramada con éxito'),
            backgroundColor: const Color(0xFF50C878),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al reprogramar la cita, intenta de nuevo'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final monthNames = ['', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

    return Container(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 35),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Reprogramar Cita', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 4),
          Text('Selecciona la nueva fecha y hora', style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey.shade500)),
          const SizedBox(height: 20),
          Text('Nueva Fecha', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black54)),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: 14,
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index + 1));
                final isSelected = _selectedDate.day == date.day && _selectedDate.month == date.month;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedDate = date);
                    _fetchSlots();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: 68,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFD48B41) : (isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? Colors.transparent : Colors.transparent),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(dayNames[date.weekday - 1], style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: isSelected ? Colors.white.withOpacity(0.8) : Colors.grey.shade500)),
                        const SizedBox(height: 4),
                        Text('${date.day}', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87))),
                        Text(monthNames[date.month], style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w500, color: isSelected ? Colors.white.withOpacity(0.7) : Colors.grey.shade500)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Text('Nuevo Horario', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black54)),
          const SizedBox(height: 12),
          if (_isLoadingSlots)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator(color: Color(0xFFD48B41))),
            )
          else if (_timeSlots.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('No hay horarios disponibles para esta fecha', style: GoogleFonts.outfit(color: Colors.grey))),
            )
          else
            Wrap(
              spacing: 10, runSpacing: 10,
              children: List.generate(_timeSlots.length, (index) {
                final isSelected = _selectedTimeSlot == index;
                final isUnavailable = !_timeSlots[index]['isAvailable'];

                return GestureDetector(
                  onTap: isUnavailable ? null : () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedTimeSlot = index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUnavailable
                          ? (isDark ? Colors.white.withOpacity(0.02) : Colors.grey.shade100)
                          : isSelected ? const Color(0xFFD48B41) : (isDark ? const Color(0xFF2C2C2E) : Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isUnavailable
                            ? Colors.transparent
                            : isSelected ? Colors.transparent : (isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade200),
                      ),
                    ),
                    child: Text(
                      _timeSlots[index]['time'],
                      style: GoogleFonts.outfit(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: isUnavailable
                            ? Colors.grey.shade400
                            : isSelected ? Colors.white : (isDark ? Colors.white.withOpacity(0.8) : Colors.black87),
                        decoration: isUnavailable ? TextDecoration.lineThrough : TextDecoration.none,
                      ),
                    ),
                  ),
                );
              }),
            ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity, height: 55,
            child: ElevatedButton(
              onPressed: (_selectedTimeSlot < 0 || _isSubmitting) ? null : _confirmReschedule,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD48B41),
                disabledBackgroundColor: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade200,
                disabledForegroundColor: Colors.grey.shade400,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Text('Confirmar Reprogramación', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
