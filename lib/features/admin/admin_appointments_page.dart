import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/network/admin_service.dart';

class AdminAppointmentsPage extends StatefulWidget {
  const AdminAppointmentsPage({super.key});

  @override
  State<AdminAppointmentsPage> createState() => _AdminAppointmentsPageState();
}

class _AdminAppointmentsPageState extends State<AdminAppointmentsPage> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  List<dynamic> _appointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    final response = await _adminService.getAllAppointments();

    if (response['success']) {
      setState(() { _appointments = response['data'] ?? []; });
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Gestión de Citas', style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
        actions: [
          IconButton(icon: Icon(Icons.refresh, color: isDark ? Colors.white : Colors.black), onPressed: _loadAppointments),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD48B41)))
          : _appointments.isEmpty
              ? Center(child: Text('No hay citas registradas.', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16)))
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: _appointments.length,
                  itemBuilder: (context, index) {
                    final apt = _appointments[index];
                    final estado = apt['estado'] ?? 'Pendiente';
                    Color statusColor;
                    switch (estado) {
                      case 'Completada': statusColor = Colors.green; break;
                      case 'Cancelada': statusColor = Colors.red; break;
                      default: statusColor = const Color(0xFFD48B41);
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? Colors.grey.shade900 : Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                            child: Icon(Icons.calendar_today_rounded, color: statusColor, size: 22),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(apt['servicio'] ?? 'Servicio', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                                Text('${apt['fecha'] ?? ''} • ${apt['hora'] ?? ''}', style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade500)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                            child: Text(estado, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)),
                          ),
                        ],
                      ),
                    ).animate().fade(duration: 300.ms).slideX(begin: 0.05, curve: Curves.easeOut);
                  },
                ),
    );
  }
}
