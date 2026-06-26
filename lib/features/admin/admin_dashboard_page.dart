import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/network/admin_service.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final statsResponse = await _adminService.getStats();

    if (statsResponse['success']) {
      setState(() { _stats = statsResponse['data']; });
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
        title: Text('Dashboard', style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
        actions: [
          IconButton(icon: Icon(Icons.refresh, color: isDark ? Colors.white : Colors.black), onPressed: _loadData),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD48B41)))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bienvenido Admin', style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey.shade500)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildStatCard('Total Usuarios', '${_stats?['totalUsers'] ?? 0}', Icons.people_alt_rounded, const Color(0xFF4A90E2)),
                      const SizedBox(width: 15),
                      _buildStatCard('Citas Hoy', '${_stats?['todayAppointments'] ?? 0}', Icons.calendar_today_rounded, const Color(0xFF50C878)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      _buildStatCard('Ingresos', '${_stats?['revenue'] ?? '\$0'}', Icons.payments_rounded, const Color(0xFFD48B41)),
                      const SizedBox(width: 15),
                      _buildStatCard('Activos', '${_stats?['activeBarbers'] ?? 0}', Icons.content_cut_rounded, const Color(0xFFFF6B6B)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text('Acciones Rápidas', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                  const SizedBox(height: 20),
                  _buildQuickAction('Gestionar Barberos', Icons.person_search_rounded, const Color(0xFF88C9F9)),
                  _buildQuickAction('Ver Reportes', Icons.assessment_rounded, const Color(0xFFFFD56B)),
                  _buildQuickAction('Configurar Horarios', Icons.schedule_rounded, const Color(0xFF98E68E)),
                ].animate(interval: 80.ms).fade(duration: 400.ms).slideY(begin: 0.1, curve: Curves.easeOut),
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 15),
            Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(String title, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.grey.shade900 : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 24)),
          const SizedBox(width: 15),
          Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
          const Spacer(),
          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
