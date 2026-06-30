import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/network/admin_service.dart';
import '../../shared/widgets/custom_toast.dart';
import 'widgets/admin_barber_form_dialog.dart';

class AdminBarbersPage extends StatefulWidget {
  const AdminBarbersPage({super.key});

  @override
  State<AdminBarbersPage> createState() => _AdminBarbersPageState();
}

class _AdminBarbersPageState extends State<AdminBarbersPage> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  List<dynamic> _barbers = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadBarbers();
  }

  Future<void> _loadBarbers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final response = await _adminService.getAllBarbers();
      if (response['success'] == true) {
        setState(() {
          _barbers = response['data'] ?? [];
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Error al cargar barberos';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _handleSaveBarber(Map<String, dynamic> data, {int? barberId}) async {
    final isEdit = barberId != null;
    final Map<String, dynamic> response;

    // backend handles id_rol assignment

    if (isEdit) {
      response = await _adminService.updateBarber(barberId, data);
    } else {
      response = await _adminService.createBarber(data);
    }

    if (!mounted) return false;

    if (response['success'] == true) {
      CustomToast.show(
        context,
        response['message'] ?? (isEdit ? 'Barbero actualizado' : 'Barbero creado'),
        ToastType.success,
      );
      _loadBarbers();
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

  Future<void> _handleToggleStatus(dynamic barber) async {
    final barberId = barber['id_usuario'] ?? barber['id'];
    if (barberId == null) return;

    // Show dialog confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final currentStatus = barber['estado'] == true;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            currentStatus ? '¿Desactivar Barbero?' : '¿Activar Barbero?',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Text(
            currentStatus 
                ? 'El barbero ya no aparecerá disponible para recibir nuevas citas en la aplicación.'
                : 'El barbero volverá a estar disponible para que los clientes agenden citas con él.',
            style: GoogleFonts.outfit(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancelar', style: TextStyle(color: Colors.grey.shade500)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: currentStatus ? Colors.redAccent : const Color(0xFFD48B41),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Confirmar', style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    final response = await _adminService.toggleBarberStatus(barberId);
    
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response['success'] == true) {
      CustomToast.show(context, 'Estado actualizado correctamente', ToastType.success);
      _loadBarbers();
    } else {
      CustomToast.show(context, response['message'] ?? 'Error al actualizar estado', ToastType.error);
    }
  }

  void _showFormDialog({Map<String, dynamic>? barber}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AdminBarberFormDialog(
        barber: barber,
        onSave: (data) => _handleSaveBarber(data, barberId: barber?['id_usuario'] ?? barber?['id']),
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
          icon: Icon(Icons.arrow_back_ios_rounded, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Gestión de Barberos',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: isDark ? Colors.white : Colors.black),
            onPressed: _loadBarbers,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        backgroundColor: primaryGold,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD48B41)))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loadBarbers,
                          style: ElevatedButton.styleFrom(backgroundColor: primaryGold),
                          child: const Text('Reintentar'),
                        )
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBarbers,
                  color: primaryGold,
                  child: _barbers.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                            Center(
                              child: Text(
                                'No hay barberos registrados.',
                                style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          itemCount: _barbers.length,
                          itemBuilder: (context, index) {
                            final b = _barbers[index];
                            final isActive = b['estado'] == true;
                            final name = b['prim_nombre'] != null 
                                ? '${b['prim_nombre']} ${b['apellido1'] ?? ''}' 
                                : (b['name'] ?? 'Barbero');
                            
                            final rating = double.tryParse(b['calificacion_promedio']?.toString() ?? b['rating']?.toString() ?? '5.0') ?? 5.0;
                            final experience = b['portafolios']?['experiencia'] ?? b['experience'] ?? 'Sin especificar';
                            
                            // Specialties
                            List<String> specs = [];
                            final rawSpecs = b['portafolios']?['especialidades'] ?? b['specialty'] ?? b['specialties'];
                            if (rawSpecs != null) {
                              if (rawSpecs is List) {
                                specs = rawSpecs.map((s) => s.toString()).toList();
                              } else {
                                specs = rawSpecs.toString().split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
                              }
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              padding: const EdgeInsets.all(16),
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
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundColor: primaryGold.withOpacity(0.1),
                                        child: Text(
                                          name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'B',
                                          style: GoogleFonts.outfit(
                                            color: primaryGold,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: GoogleFonts.outfit(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: isDark ? Colors.white : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                                const SizedBox(width: 4),
                                                Text(
                                                  rating.toStringAsFixed(1),
                                                  style: GoogleFonts.outfit(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '• $experience de exp',
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 13,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Status Chip
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          isActive ? 'Activo' : 'Inactivo',
                                          style: GoogleFonts.outfit(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isActive ? Colors.green : Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Contact Info
                                  Text(
                                    '✉ ${b['email'] ?? 'Sin correo'}',
                                    style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade500),
                                  ),
                                  if (b['telefono'] != null && b['telefono'].toString().isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      '📞 ${b['telefono']}',
                                      style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade500),
                                    ),
                                  ],
                                  if (specs.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: specs.map((s) => Chip(
                                        label: Text(s),
                                        labelStyle: GoogleFonts.outfit(fontSize: 11, color: primaryGold, fontWeight: FontWeight.w600),
                                        backgroundColor: primaryGold.withOpacity(0.08),
                                        elevation: 0,
                                        side: BorderSide.none,
                                        padding: EdgeInsets.zero,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      )).toList(),
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  const Divider(height: 1),
                                  const SizedBox(height: 10),
                                  // Action Buttons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () => _handleToggleStatus(b),
                                        icon: Icon(
                                          isActive ? Icons.power_settings_new_rounded : Icons.offline_bolt_rounded,
                                          size: 18,
                                          color: isActive ? Colors.redAccent : Colors.green,
                                        ),
                                        label: Text(
                                          isActive ? 'Desactivar' : 'Activar',
                                          style: GoogleFonts.outfit(
                                            color: isActive ? Colors.redAccent : Colors.green,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      ElevatedButton.icon(
                                        onPressed: () => _showFormDialog(barber: b),
                                        icon: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                                        label: Text(
                                          'Editar',
                                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryGold,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ).animate().fade(duration: 300.ms).slideX(begin: 0.05, curve: Curves.easeOut);
                          },
                        ),
                ),
    );
  }
}
