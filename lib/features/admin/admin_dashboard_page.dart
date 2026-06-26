import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../../core/network/admin_service.dart';
import '../../shared/widgets/custom_toast.dart';
import 'admin_barbers_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  bool _isDownloadingPdf = false;
  Map<String, dynamic>? _stats;
  List<dynamic> _recentActivities = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final statsResponse = await _adminService.getStats();
      final activityResponse = await _adminService.getActivity();

      if (mounted) {
        setState(() {
          if (statsResponse['success']) {
            _stats = statsResponse['data'];
          }
          if (activityResponse['success'] == true) {
            _recentActivities = activityResponse['data'] ?? [];
          } else {
            _recentActivities = [];
          }
        });
      }
    } catch (e) {
      print('Dashboard loading error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _downloadReport() async {
    if (_isDownloadingPdf) return;

    setState(() => _isDownloadingPdf = true);
    CustomToast.show(context, 'Generando reporte PDF...', ToastType.success);

    try {
      final pdfBytes = await _adminService.downloadStatsPdf();
      if (pdfBytes == null || pdfBytes.isEmpty) {
        if (mounted) {
          CustomToast.show(context, 'No se pudo generar el reporte PDF. Verifica la conexión con el servidor.', ToastType.error);
        }
        return;
      }

      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/Reporte_Estadisticas_$timestamp.pdf');
      await file.writeAsBytes(pdfBytes);

      if (mounted) {
        CustomToast.show(context, 'Reporte descargado con éxito', ToastType.success);
        await OpenFilex.open(file.path);
      }
    } catch (e) {
      if (mounted) {
        CustomToast.show(context, 'Error al descargar el reporte: ${e.toString().replaceAll("Exception: ", "")}', ToastType.error);
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloadingPdf = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = const Color(0xFFD48B41);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Elegant Cut',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: isDark ? Colors.white : Colors.black),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD48B41)))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: primaryGold,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome & status banner
                    _buildWelcomeCard(isDark),
                    const SizedBox(height: 25),
                    
                    // Metrics Title
                    Text(
                      'Métricas de Hoy',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Grid of Metrics
                    Row(
                      children: [
                        _buildStatCard(
                          title: 'Citas Hoy',
                          value: '${_stats?['citasHoy'] ?? 0}',
                          icon: Icons.calendar_today_rounded,
                          color: const Color(0xFF50C878),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 15),
                        _buildStatCard(
                          title: 'Ingresos Hoy',
                          value: '\$${_stats?['ingresosHoy'] ?? 0}',
                          icon: Icons.payments_rounded,
                          color: primaryGold,
                          isDark: isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        _buildStatCard(
                          title: 'Clientes Nuevos',
                          value: '${_stats?['clientesNuevos'] ?? 0}',
                          icon: Icons.person_add_rounded,
                          color: const Color(0xFF4A90E2),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 15),
                        _buildStatCard(
                          title: 'Citas Pendientes',
                          value: '${_stats?['citasPendientes'] ?? 0}',
                          icon: Icons.hourglass_empty_rounded,
                          color: const Color(0xFFFF9500),
                          isDark: isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // Quick Actions
                    Text(
                      'Acciones Rápidas',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildQuickAction(
                      title: 'Gestionar Barberos',
                      subtitle: 'Registrar, editar y activar barberos',
                      icon: Icons.content_cut_rounded,
                      color: primaryGold,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AdminBarbersPage()),
                        );
                      },
                    ),
                    _buildQuickAction(
                      title: 'Descargar Reporte PDF',
                      subtitle: 'Estadísticas e historial general en PDF',
                      icon: Icons.picture_as_pdf_rounded,
                      color: const Color(0xFFFF3B30),
                      isDark: isDark,
                      isLoading: _isDownloadingPdf,
                      onTap: _downloadReport,
                    ),
                    const SizedBox(height: 25),

                    // Recent Activity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Actividad Reciente',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const Icon(Icons.history_rounded, size: 20, color: Colors.grey),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildRecentActivityList(isDark),
                    const SizedBox(height: 30),
                  ].animate(interval: 60.ms).fade(duration: 350.ms).slideY(begin: 0.05, curve: Curves.easeOut),
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1E24), const Color(0xFF121214)]
              : [const Color(0xFFF0F4F8), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? const Color(0xFFD48B41).withOpacity(0.2) : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Hola, Administrador 👋',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Bienvenido al panel de control de Elegant Cut. Aquí puedes ver el resumen de tu negocio en tiempo real.',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.grey.shade500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF50C878).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF50C878),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Servidores en línea y conectados',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF50C878),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 15),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
    bool isLoading = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.grey.shade900 : Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: color, strokeWidth: 2),
                        )
                      : Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivityList(bool isDark) {
    if (_recentActivities.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? Colors.grey.shade900 : Colors.grey.shade200),
        ),
        child: Center(
          child: Text(
            'No hay actividad registrada recientemente.',
            style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentActivities.length > 5 ? 5 : _recentActivities.length,
      itemBuilder: (context, index) {
        final activity = _recentActivities[index];
        final clientName = activity['usuarios'] != null 
            ? '${activity['usuarios']['prim_nombre'] ?? ''} ${activity['usuarios']['apellido1'] ?? ''}'
            : 'Cliente';
        
        final statusId = activity['id_estado_cita'] ?? 1;
        
        String statusText = 'Pendiente';
        Color statusColor = const Color(0xFFD48B41);
        if (statusId == 2) {
          statusText = 'Completada';
          statusColor = Colors.green;
        } else if (statusId == 3) {
          statusText = 'Cancelada';
          statusColor = Colors.redAccent;
        }

        // Parse date string
        String dateStr = '';
        if (activity['fecha'] != null) {
          try {
            final dt = DateTime.parse(activity['fecha']);
            dateStr = '${dt.day}/${dt.month}/${dt.year}';
          } catch (e) {
            dateStr = activity['fecha'].toString().split('T')[0];
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.grey.shade900 : Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reserva por $clientName',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Fecha: $dateStr',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
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
