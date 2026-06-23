import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../api/admin_service.dart';

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
      setState(() {
        _appointments = response['data'] ?? [];
      });
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
        title: Text(
          'Gestión de Citas',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: isDark ? Colors.white : Colors.black),
            onPressed: _loadAppointments,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD48B41)))
          : _appointments.isEmpty
              ? Center(child: Text('No hay citas', style: GoogleFonts.outfit(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _appointments.length,
                  itemBuilder: (context, index) {
                    final appt = _appointments[index];
                    return _buildAppointmentCard(appt, isDark)
                        .animate()
                        .fadeIn(delay: Duration(milliseconds: 100 * index))
                        .slideY(begin: 0.1);
                  },
                ),
    );
  }

  Widget _buildAppointmentCard(dynamic appt, bool isDark) {
    final statusMap = {
      1: {'text': 'Pendiente', 'color': Colors.orange},
      2: {'text': 'Confirmada', 'color': Colors.blue},
      3: {'text': 'Completada', 'color': Colors.green},
      4: {'text': 'Cancelada', 'color': Colors.red},
    };

    final int statusId = appt['id_estado_reserva'] ?? 1;
    final String statusText = statusMap[statusId]?['text'] as String? ?? 'Desconocido';
    final Color statusColor = statusMap[statusId]?['color'] as Color? ?? Colors.grey;

    final String clientName = appt['usuario'] != null 
        ? '${appt['usuario']['prim_nombre'] ?? ''} ${appt['usuario']['apellido1'] ?? ''}'.trim()
        : 'Cliente';
    
    final String serviceName = appt['servicio'] != null ? appt['servicio']['nombre_servicio'] ?? 'Servicio' : 'Servicio';
    final String date = appt['fecha_reserva']?.toString().split('T')[0] ?? 'Fecha';
    final String time = appt['hora_inicio']?.toString().substring(0, 5) ?? 'Hora';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border(
          left: BorderSide(color: statusColor, width: 5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                clientName,
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.outfit(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.cut, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  serviceName,
                  style: GoogleFonts.outfit(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.access_time, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 5),
              Text(
                '$date $time',
                style: GoogleFonts.outfit(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
