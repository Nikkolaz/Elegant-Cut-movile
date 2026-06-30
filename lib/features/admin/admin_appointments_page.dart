import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/network/admin_service.dart';
import '../../shared/widgets/custom_toast.dart';

class AdminAppointmentsPage extends StatefulWidget {
  const AdminAppointmentsPage({super.key});

  @override
  State<AdminAppointmentsPage> createState() => _AdminAppointmentsPageState();
}

class _AdminAppointmentsPageState extends State<AdminAppointmentsPage> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  List<dynamic> _allAppointments = [];
  List<dynamic> _filteredAppointments = [];
  String _selectedFilter = 'Todas';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final response = await _adminService.getAllAppointments();

      if (response['success'] == true) {
        final rawData = response['data'];
        setState(() {
          _allAppointments = rawData is List ? rawData : (rawData is Map ? (rawData['citas'] ?? []) : []);
          _filterAppointments(_selectedFilter);
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Error al cargar citas';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterAppointments(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'Todas') {
        _filteredAppointments = List.from(_allAppointments);
      } else {
        _filteredAppointments = _allAppointments.where((apt) {
          final estado = apt['estado'] ?? 'Pendiente';
          return estado == filter;
        }).toList();
      }
    });
  }

  Future<void> _changeStatus(int id, int statusId, String statusName) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            '¿Cambiar estado de la cita?',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Se marcará la cita como "$statusName".',
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
                backgroundColor: statusId == 2
                    ? Colors.green
                    : statusId == 3
                        ? Colors.redAccent
                        : const Color(0xFFD48B41),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final response = await _adminService.updateAppointmentStatus(id, statusId);
      if (response['success'] == true) {
        if (mounted) {
          CustomToast.show(context, 'Estado de la cita actualizado a $statusName', ToastType.success);
        }
        _loadAppointments();
      } else {
        if (mounted) {
          CustomToast.show(context, response['message'] ?? 'Error al actualizar cita', ToastType.error);
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        CustomToast.show(context, 'Error de conexión: $e', ToastType.error);
        setState(() => _isLoading = false);
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
          'Gestión de Citas',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: isDark ? Colors.white : Colors.black),
            onPressed: _loadAppointments,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 5, 20, 15),
            child: Row(
              children: ['Todas', 'Pendiente', 'Completada', 'Cancelada'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(filter == 'Todas' ? 'Todas' : '${filter}s'),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) _filterAppointments(filter);
                    },
                    selectedColor: primaryGold,
                    backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.grey.shade100,
                    labelStyle: GoogleFonts.outfit(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(
                      color: isSelected
                          ? Colors.transparent
                          : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                      width: 1,
                    ),
                    elevation: 0,
                    pressElevation: 0,
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Appointments List
          Expanded(
            child: _isLoading
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
                                onPressed: _loadAppointments,
                                style: ElevatedButton.styleFrom(backgroundColor: primaryGold),
                                child: const Text('Reintentar'),
                              )
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadAppointments,
                        color: primaryGold,
                        child: _filteredAppointments.isEmpty
                            ? ListView(
                                children: [
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                                  Center(
                                    child: Text(
                                      'No hay citas registradas en este estado.',
                                      style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                itemCount: _filteredAppointments.length,
                                itemBuilder: (context, index) {
                                  final apt = _filteredAppointments[index];
                                  final id = apt['id_reservas'] ?? apt['id'];
                                  final estado = apt['estado'] ?? 'Pendiente';
                                  
                                  Color statusColor = primaryGold;
                                  if (estado == 'Completada') {
                                    statusColor = Colors.green;
                                  } else if (estado == 'Cancelada') {
                                    statusColor = Colors.redAccent;
                                  }

                                  // Parse date string
                                  String dateStr = '';
                                  if (apt['fecha'] != null) {
                                    try {
                                      final dt = DateTime.parse(apt['fecha']);
                                      dateStr = '${dt.day}/${dt.month}/${dt.year}';
                                    } catch (e) {
                                      dateStr = apt['fecha'].toString().split('T')[0];
                                    }
                                  }

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
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
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Status icon box
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Icon(
                                            Icons.calendar_today_rounded,
                                            color: statusColor,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        // Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                apt['servicio'] ?? 'Servicio',
                                                style: GoogleFonts.outfit(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: isDark ? Colors.white : Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Cliente: ${apt['cliente'] ?? 'Desconocido'}',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 14,
                                                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '$dateStr • ${apt['hora_inicio'] ?? apt['hora'] ?? ''}',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 13,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Action Popup Menu or Badge
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                              decoration: BoxDecoration(
                                                color: statusColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                estado,
                                                style: GoogleFonts.outfit(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: statusColor,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            // Action popup menu
                                            if (id != null)
                                              PopupMenuButton<int>(
                                                icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade500),
                                                onSelected: (val) {
                                                  if (val == 1) _changeStatus(id, 1, 'Pendiente');
                                                  if (val == 2) _changeStatus(id, 2, 'Completada');
                                                  if (val == 3) _changeStatus(id, 3, 'Cancelada');
                                                },
                                                itemBuilder: (context) => [
                                                  if (estado != 'Pendiente')
                                                    const PopupMenuItem(
                                                      value: 1,
                                                      child: Text('Marcar Pendiente'),
                                                    ),
                                                  if (estado != 'Completada')
                                                    const PopupMenuItem(
                                                      value: 2,
                                                      child: Text('Marcar Completada'),
                                                    ),
                                                  if (estado != 'Cancelada')
                                                    const PopupMenuItem(
                                                      value: 3,
                                                      child: Text('Cancelar Cita'),
                                                    ),
                                                ],
                                                elevation: 8,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                                color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ).animate().fade(duration: 300.ms).slideX(begin: 0.05, curve: Curves.easeOut);
                                },
                              ),
                      ),
          ),
        ],
      ),
    );
  }
}
