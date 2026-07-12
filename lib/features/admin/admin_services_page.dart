import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/network/admin_service.dart';
import '../../shared/widgets/custom_toast.dart';
import 'widgets/admin_service_form_dialog.dart';

class AdminServicesPage extends StatefulWidget {
  const AdminServicesPage({super.key});

  @override
  State<AdminServicesPage> createState() => _AdminServicesPageState();
}

class _AdminServicesPageState extends State<AdminServicesPage> {
  final AdminService _adminService = AdminService();

  bool _isLoading = true;
  List<dynamic> _services = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final response = await _adminService.getAdminServices();
      if (!mounted) return;
      if (response['success'] == true) {
        setState(() {
          _services = response['data'] ?? [];
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Error al cargar servicios';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error de conexión: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _handleSaveService(
      Map<String, dynamic> data, {int? serviceId}) async {
    final isEdit = serviceId != null;
    final Map<String, dynamic> response;

    if (isEdit) {
      response = await _adminService.updateService(serviceId, data);
    } else {
      response = await _adminService.createService(data);
    }

    if (!mounted) return false;

    if (response['success'] == true) {
      CustomToast.show(
        context,
        response['message'] ??
            (isEdit ? 'Servicio actualizado' : 'Servicio creado'),
        ToastType.success,
      );
      _loadServices();
      return true;
    } else {
      CustomToast.show(
        context,
        response['message'] ?? 'Error al procesar solicitud',
        ToastType.error,
      );
      return false;
    }
  }

  Future<void> _handleDeleteService(dynamic service) async {
    final serviceId = service['id_servicio'];
    if (serviceId == null) return;

    final serviceName = service['nombre_servicio'] ?? 'este servicio';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: Text(
            '¿Eliminar servicio?',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Se eliminará "$serviceName" de forma definitiva. Esta acción no se puede deshacer.',
            style: GoogleFonts.outfit(height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Eliminar',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    final response = await _adminService.deleteService(serviceId);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response['success'] == true) {
      CustomToast.show(
          context, 'Servicio eliminado correctamente', ToastType.success);
      _loadServices();
    } else {
      CustomToast.show(
        context,
        response['message'] ?? 'Error al eliminar el servicio',
        ToastType.error,
      );
    }
  }

  void _showFormDialog({Map<String, dynamic>? service}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AdminServiceFormDialog(
        service: service,
        onSave: (data) => _handleSaveService(
          data,
          serviceId: service?['id_servicio'],
        ),
      ),
    );
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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Gestión de Servicios',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: _loadServices,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        backgroundColor: primaryGold,
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD48B41)))
          : _errorMessage.isNotEmpty
              ? _buildErrorState(isDark, primaryGold)
              : RefreshIndicator(
                  onRefresh: _loadServices,
                  color: primaryGold,
                  child: _services.isEmpty
                      ? _buildEmptyState(isDark)
                      : _buildServicesList(isDark, primaryGold),
                ),
    );
  }

  Widget _buildErrorState(bool isDark, Color primaryGold) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 52,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: GoogleFonts.outfit(color: Colors.grey, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadServices,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: Text(
                'Reintentar',
                style: GoogleFonts.outfit(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGold,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFD48B41).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.content_cut_rounded,
                  size: 52,
                  color: Color(0xFFD48B41),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Sin servicios registrados',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Presiona el botón + para agregar\ntu primer servicio.',
                style: GoogleFonts.outfit(
                    color: Colors.grey.shade500, fontSize: 14, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServicesList(bool isDark, Color primaryGold) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        final s = _services[index];
        final name = s['nombre_servicio']?.toString() ?? 'Servicio';
        final description = s['descripcion']?.toString() ?? '';
        final price = s['precio'];
        final durationMin = s['duracion_minutos'];

        return _ServiceCard(
          name: name,
          description: description,
          price: price,
          durationMin: durationMin,
          isDark: isDark,
          primaryGold: primaryGold,
          onEdit: () => _showFormDialog(service: s),
          onDelete: () => _handleDeleteService(s),
        ).animate().fade(duration: 300.ms).slideX(
              begin: 0.05, curve: Curves.easeOut);
      },
    );
  }
}

// ── Service Card ──────────────────────────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  final String name;
  final String description;
  final dynamic price;
  final dynamic durationMin;
  final bool isDark;
  final Color primaryGold;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ServiceCard({
    required this.name,
    required this.description,
    required this.price,
    required this.durationMin,
    required this.isDark,
    required this.primaryGold,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final priceStr = price != null
        ? '\$${_formatPrice(price)}'
        : 'Sin precio';
    final durationStr = durationMin != null ? '$durationMin min' : '--';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
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
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row: avatar + title + badges ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: primaryGold.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.content_cut_rounded,
                  color: primaryGold,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              // Name + description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Price & duration chips ──
          Row(
            children: [
              _buildInfoChip(
                icon: Icons.payments_rounded,
                label: priceStr,
                color: const Color(0xFF50C878),
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              _buildInfoChip(
                icon: Icons.timer_rounded,
                label: durationStr,
                color: const Color(0xFF4A90E2),
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // ── Action buttons ──
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: Colors.redAccent,
                ),
                label: Text(
                  'Eliminar',
                  style: GoogleFonts.outfit(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded,
                    size: 16, color: Colors.white),
                label: Text(
                  'Editar',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGold,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(dynamic price) {
    try {
      final n = double.parse(price.toString());
      if (n == n.truncateToDouble()) {
        return n.toInt().toString();
      }
      return n.toStringAsFixed(2);
    } catch (_) {
      return price.toString();
    }
  }
}
