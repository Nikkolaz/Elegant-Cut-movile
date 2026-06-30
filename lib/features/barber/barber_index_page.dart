import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/network/booking_api_service.dart';
import '../../core/network/admin_service.dart';
import '../../core/network/profile_api_service.dart';
import '../appointments/reschedule_sheet.dart';
import '../auth/login_page.dart';
import '../../shared/widgets/custom_toast.dart';
import '../../shared/widgets/carita_widget.dart';

class BarberIndexPage extends StatefulWidget {
  const BarberIndexPage({super.key});

  @override
  State<BarberIndexPage> createState() => _BarberIndexPageState();
}

class _BarberIndexPageState extends State<BarberIndexPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const BarberAppointmentsView(),
      const BarberProfileView(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = const Color(0xFFD48B41);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: Container(
        height: 75,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.grey.shade900 : Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.calendar_month_rounded, 'Mis Citas', 0, primaryGold, isDark),
            _buildNavItem(Icons.person_pin_rounded, 'Mi Perfil', 1, primaryGold, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, Color primaryGold, bool isDark) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? primaryGold : (isDark ? Colors.grey.shade600 : Colors.grey.shade400);

    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── SUB-VIEW 1: APPOINTMENTS LIST ──
class BarberAppointmentsView extends StatefulWidget {
  const BarberAppointmentsView({super.key});

  @override
  State<BarberAppointmentsView> createState() => _BarberAppointmentsViewState();
}

class _BarberAppointmentsViewState extends State<BarberAppointmentsView> {
  final BookingApiService _bookingApi = BookingApiService();
  final AdminService _adminService = AdminService();

  bool _isLoading = true;
  String _barberName = 'Barbero';
  int? _barberId;
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _filteredAppointments = [];
  String _activeFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadBarberData();
  }

  Future<void> _loadBarberData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _barberName = prefs.getString('firstName') ?? 'Barbero';
      _barberId = prefs.getInt('id_usuario');
    });
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    if (_barberId == null) return;
    setState(() => _isLoading = true);

    try {
      final list = await _bookingApi.getBarberAppointments(_barberId!);
      setState(() {
        _appointments = list;
        _applyFilter();
      });
    } catch (e) {
      if (mounted) {
        CustomToast.show(context, 'Error al cargar citas: $e', ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    setState(() {
      if (_activeFilter == 'all') {
        _filteredAppointments = _appointments;
      } else if (_activeFilter == 'pending') {
        _filteredAppointments = _appointments.where((a) => a['estado'] == 'Pendiente').toList();
      } else if (_activeFilter == 'completed') {
        _filteredAppointments = _appointments.where((a) => a['estado'] == 'Completada').toList();
      } else if (_activeFilter == 'canceled') {
        _filteredAppointments = _appointments.where((a) => a['estado'] == 'Cancelada').toList();
      }
    });
  }

  Future<void> _changeStatus(int appointmentId, int statusId, String actionLabel) async {
    setState(() => _isLoading = true);
    try {
      final res = await _adminService.updateAppointmentStatus(appointmentId, statusId);
      if (res['success'] == true) {
        if (mounted) {
          CustomToast.show(context, 'Cita $actionLabel con éxito', ToastType.success);
        }
        _fetchAppointments();
      } else {
        if (mounted) {
          CustomToast.show(context, res['message'] ?? 'Error al actualizar estado', ToastType.error);
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

  void _openRescheduleSheet(Map<String, dynamic> appointment) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: RescheduleSheet(
          isDark: isDark,
          appointment: appointment,
          isBarber: true,
        ),
      ),
    ).then((rescheduled) {
      if (rescheduled == true) {
        _fetchAppointments();
      }
    });
  }

  void _callClient(String? phone) async {
    if (phone == null || phone.isEmpty || phone == 'No especificado') {
      CustomToast.show(context, 'Teléfono del cliente no disponible', ToastType.error);
      return;
    }
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        CustomToast.show(context, 'No se pudo iniciar la llamada', ToastType.error);
      }
    }
  }

  String _formatDate(dynamic dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString.toString());
      final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return dateString.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = const Color(0xFFD48B41);

    final todayCount = _appointments.where((a) {
      try {
        final dt = DateTime.parse(a['fecha'].toString());
        final today = DateTime.now();
        return dt.year == today.year && dt.month == today.month && dt.day == today.day;
      } catch (_) {
        return false;
      }
    }).length;

    final pendingCount = _appointments.where((a) => a['estado'] == 'Pendiente').length;

    return Column(
      children: [
        // App bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hola, $_barberName',
                    style: GoogleFonts.outfit(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Mis citas programadas ✂',
                    style: GoogleFonts.outfit(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.refresh_rounded, color: isDark ? Colors.white : Colors.black),
                onPressed: _fetchAppointments,
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        // Stats
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildMiniStatCard('Citas de Hoy', '$todayCount', Icons.today_rounded, const Color(0xFF4A90E2), isDark),
              const SizedBox(width: 15),
              _buildMiniStatCard('Pendientes', '$pendingCount', Icons.pending_actions_rounded, primaryGold, isDark),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildFilterChip('Todas', 'all', isDark, primaryGold),
                const SizedBox(width: 10),
                _buildFilterChip('Pendientes', 'pending', isDark, primaryGold),
                const SizedBox(width: 10),
                _buildFilterChip('Completadas', 'completed', isDark, const Color(0xFF50C878)),
                const SizedBox(width: 10),
                _buildFilterChip('Canceladas', 'canceled', isDark, Colors.redAccent),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),

        // List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFD48B41)))
              : RefreshIndicator(
                  onRefresh: _fetchAppointments,
                  color: primaryGold,
                  child: _filteredAppointments.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.18),
                            Center(
                              child: Column(
                                children: [
                                  Icon(Icons.calendar_month_outlined, size: 56, color: Colors.grey.shade400),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No tienes citas en esta categoría.',
                                    style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16),
                                  ),
                                ],
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
                            return _buildAppointmentCard(apt, isDark, primaryGold)
                                .animate()
                                .fade(duration: 300.ms)
                                .slideY(begin: 0.05, curve: Curves.easeOut);
                          },
                        ),
                ),
        ),
      ],
    );
  }

  Widget _buildMiniStatCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.grey.shade900 : Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  Text(title, style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey.shade500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String filterValue, bool isDark, Color color) {
    final isActive = _activeFilter == filterValue;
    return GestureDetector(
      onTap: () {
        setState(() => _activeFilter = filterValue);
        _applyFilter();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.12) : (isDark ? const Color(0xFF1C1C1E) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? color.withOpacity(0.4) : (isDark ? Colors.grey.shade900 : Colors.grey.shade200),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? color : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> apt, bool isDark, Color primaryGold) {
    final status = apt['estado'] ?? 'Pendiente';
    final isPending = status == 'Pendiente';
    final isCompleted = status == 'Completada';

    Color statusColor = primaryGold;
    if (isCompleted) {
      statusColor = const Color(0xFF50C878);
    } else if (status == 'Cancelada') {
      statusColor = Colors.redAccent;
    }

    final obs = apt['observaciones'] != null && apt['observaciones'].toString().trim().isNotEmpty
        ? apt['observaciones'].toString()
        : 'Sin observaciones';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: isDark ? Colors.grey.shade900 : Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: primaryGold.withOpacity(0.1),
                  child: Text(
                    apt['cliente'].toString().substring(0, 1).toUpperCase(),
                    style: GoogleFonts.outfit(color: primaryGold, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        apt['cliente'] ?? 'Cliente',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87),
                      ),
                      const SizedBox(height: 2),
                      GestureDetector(
                        onTap: () => _callClient(apt['telefono']),
                        child: Row(
                          children: [
                            Icon(Icons.phone_rounded, size: 10, color: primaryGold),
                            const SizedBox(width: 4),
                            Text(
                              apt['telefono'] ?? 'Llamar',
                              style: GoogleFonts.outfit(fontSize: 11, color: primaryGold, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    status,
                    style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            _buildDetailRow(Icons.content_cut_rounded, 'Servicio:', apt['servicio'] ?? '', isDark),
            const SizedBox(height: 6),
            _buildDetailRow(Icons.calendar_today_rounded, 'Fecha:', _formatDate(apt['fecha']), isDark),
            const SizedBox(height: 6),
            _buildDetailRow(Icons.access_time_rounded, 'Horario:', apt['hora'] ?? '', isDark),
            const SizedBox(height: 6),
            _buildDetailRow(Icons.notes_rounded, 'Nota:', obs, isDark),

            if (isPending) ...[
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.check_circle_outline_rounded,
                      label: 'Completar',
                      color: const Color(0xFF50C878),
                      onTap: () => _changeStatus(apt['id'], 2, 'completada'),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.edit_calendar_rounded,
                      label: 'Reprogramar',
                      color: primaryGold,
                      onTap: () => _openRescheduleSheet(apt),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.cancel_outlined,
                      label: 'Cancelar',
                      color: Colors.redAccent,
                      onTap: () => _changeStatus(apt['id'], 3, 'cancelada'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Text(
          '$label ',
          style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.outfit(fontSize: 12, color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── SUB-VIEW 2: PROFILE & PORTFOLIO ──
class BarberProfileView extends StatefulWidget {
  const BarberProfileView({super.key});

  @override
  State<BarberProfileView> createState() => _BarberProfileViewState();
}

class _BarberProfileViewState extends State<BarberProfileView> {
  final ProfileApiService _profileApi = ProfileApiService();

  bool _isLoading = true;
  int? _barberId;
  Map<String, dynamic> _profile = {};
  Map<String, dynamic> _portfolio = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    _barberId = prefs.getInt('id_usuario');

    if (_barberId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Fetch user profile info
      final profRes = await _profileApi.getMyProfile();
      if (profRes['success'] == true) {
        _profile = profRes['data'];
      }

      // Fetch portfolio info
      final portRes = await _profileApi.getBarberPortfolio(_barberId!);
      if (portRes['success'] == true && portRes['data'] != null) {
        _portfolio = portRes['data'];
      } else {
        _portfolio = {};
      }
    } catch (e) {
      print('Error loading profile/portfolio: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showEditProfileSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGold = const Color(0xFFD48B41);

    final firstNameCtrl = TextEditingController(text: _profile['prim_nombre'] ?? '');
    final secondNameCtrl = TextEditingController(text: _profile['seg_nombre'] ?? '');
    final lastName1Ctrl = TextEditingController(text: _profile['apellido1'] ?? '');
    final lastName2Ctrl = TextEditingController(text: _profile['apellido2'] ?? '');
    final emailCtrl = TextEditingController(text: _profile['email'] ?? '');
    final phoneCtrl = TextEditingController(text: _profile['telefono'] ?? '');

    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              height: MediaQuery.of(ctx).size.height * 0.85,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Container(
                      width: 50, height: 5,
                      decoration: BoxDecoration(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryGold.withOpacity(0.2), primaryGold.withOpacity(0.05)]), shape: BoxShape.circle),
                          child: Icon(Icons.edit_rounded, color: primaryGold, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Editar Perfil', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                              Text('Datos personales del barbero', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade500)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100, shape: BoxShape.circle),
                            child: Icon(Icons.close_rounded, size: 20, color: isDark ? Colors.white70 : Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: _buildField(firstNameCtrl, 'Primer nombre', Icons.person_outline, isDark)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildField(secondNameCtrl, 'Segundo nombre', Icons.person_outline, isDark, isOptional: true)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(child: _buildField(lastName1Ctrl, 'Primer apellido', Icons.badge_outlined, isDark)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildField(lastName2Ctrl, 'Segundo apellido', Icons.badge_outlined, isDark, isOptional: true)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildField(emailCtrl, 'Correo electrónico', Icons.mail_outline_rounded, isDark, keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 14),
                          _buildField(phoneCtrl, 'Teléfono', Icons.phone_android_rounded, isDark, keyboardType: TextInputType.phone),
                          const SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: isSaving ? null : () async {
                                if (firstNameCtrl.text.trim().isEmpty || lastName1Ctrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) {
                                  CustomToast.show(ctx, 'Completa los campos obligatorios', ToastType.error);
                                  return;
                                }
                                setSheetState(() => isSaving = true);

                                final body = {
                                  'prim_nombre': firstNameCtrl.text.trim(),
                                  'seg_nombre': secondNameCtrl.text.trim(),
                                  'apellido1': lastName1Ctrl.text.trim(),
                                  'apellido2': lastName2Ctrl.text.trim(),
                                  'email': emailCtrl.text.trim(),
                                  'telefono': phoneCtrl.text.trim(),
                                };

                                final result = await _profileApi.updateMyProfile(body);
                                setSheetState(() => isSaving = false);

                                if (!ctx.mounted) return;

                                if (result['success'] == true) {
                                  CustomToast.show(ctx, 'Perfil actualizado', ToastType.success);
                                  Navigator.pop(ctx);
                                  _loadProfile();
                                } else {
                                  CustomToast.show(ctx, result['message'] ?? 'Error al guardar', ToastType.error);
                                }
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: primaryGold, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                              child: isSaving
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text('Guardar Cambios', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditPortfolioSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGold = const Color(0xFFD48B41);

    final bioCtrl = TextEditingController(text: _portfolio['biografia'] ?? '');
    final expCtrl = TextEditingController(text: _portfolio['experiencia'] ?? '');
    final instaCtrl = TextEditingController(text: _portfolio['instagram'] ?? '');
    final specsCtrl = TextEditingController(
      text: _portfolio['especialidades'] != null
          ? (_portfolio['especialidades'].toString().startsWith('[')
              ? (jsonDecode(_portfolio['especialidades'].toString()) as List).join(', ')
              : _portfolio['especialidades'].toString())
          : '',
    );

    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              height: MediaQuery.of(ctx).size.height * 0.85,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Container(
                      width: 50, height: 5,
                      decoration: BoxDecoration(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryGold.withOpacity(0.2), primaryGold.withOpacity(0.05)]), shape: BoxShape.circle),
                          child: Icon(Icons.star_purple500_rounded, color: primaryGold, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Editar Portafolio', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                              Text('Información profesional del barbero', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade500)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100, shape: BoxShape.circle),
                            child: Icon(Icons.close_rounded, size: 20, color: isDark ? Colors.white70 : Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildField(bioCtrl, 'Biografía', Icons.text_snippet_outlined, isDark, maxLines: 3),
                          const SizedBox(height: 14),
                          _buildField(expCtrl, 'Experiencia laboral', Icons.history_edu_rounded, isDark, hint: 'Ej: 5 años en cortes clásicos'),
                          const SizedBox(height: 14),
                          _buildField(specsCtrl, 'Especialidades (separadas por coma)', Icons.workspace_premium_outlined, isDark, hint: 'Ej: Fade, Afeitado, Perfilado'),
                          const SizedBox(height: 14),
                          _buildField(instaCtrl, 'Enlace de Instagram', Icons.camera_alt_outlined, isDark, hint: 'Ej: @barber_elegant'),
                          const SizedBox(height: 20),

                          // Warning alert:
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: primaryGold.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: primaryGold.withOpacity(0.2))),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline_rounded, color: primaryGold, size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Si tu portafolio ya fue inicializado anteriormente, es posible que el servidor restrinja la re-creación. Si ocurre algún error, contacta a soporte administrativo.',
                                    style: GoogleFonts.outfit(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 25),

                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: isSaving ? null : () async {
                                setSheetState(() => isSaving = true);

                                // Parse specialties to list
                                List<String> specList = specsCtrl.text
                                    .split(',')
                                    .map((s) => s.trim())
                                    .where((s) => s.isNotEmpty)
                                    .toList();

                                final body = {
                                  'id_usuario': _barberId,
                                  'biografia': bioCtrl.text.trim(),
                                  'experiencia': expCtrl.text.trim(),
                                  'instagram': instaCtrl.text.trim(),
                                  'especialidades': specList,
                                };

                                final result = await _profileApi.saveBarberPortfolio(body);
                                setSheetState(() => isSaving = false);

                                if (!ctx.mounted) return;

                                if (result['success'] == true) {
                                  CustomToast.show(ctx, 'Portafolio guardado con éxito', ToastType.success);
                                  Navigator.pop(ctx);
                                  _loadProfile();
                                } else {
                                  CustomToast.show(ctx, result['message'] ?? 'Error al guardar portafolio', ToastType.error);
                                }
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: primaryGold, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                              child: isSaving
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text('Guardar Portafolio', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool isDark, {
    bool isOptional = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hint,
  }) {
    final primaryGold = const Color(0xFFD48B41);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black87)),
            if (isOptional) ...[
              const SizedBox(width: 4),
              Text('(opcional)', style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade500)),
            ]
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black87, fontSize: 15),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 20, color: primaryGold.withOpacity(0.6)),
              hintText: hint ?? label,
              hintStyle: GoogleFonts.outfit(color: Colors.grey.shade500, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = const Color(0xFFD48B41);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFD48B41)));
    }

    final String name = '${_profile['prim_nombre'] ?? ''} ${_profile['apellido1'] ?? ''}'.trim();
    final String username = _profile['username'] ?? 'barber';
    final String email = _profile['email'] ?? 'No especificado';
    final String phone = _profile['telefono'] ?? 'No especificado';

    // Portfolio details
    final bio = _portfolio['biografia'] ?? 'Sin biografía profesional cargada.';
    final exp = _portfolio['experiencia'] ?? 'Sin experiencia cargada.';
    final insta = _portfolio['instagram'] ?? 'No especificado';

    // Parse specialties
    List<dynamic> specs = [];
    if (_portfolio['especialidades'] != null) {
      try {
        final raw = _portfolio['especialidades'];
        if (raw.toString().startsWith('[')) {
          specs = jsonDecode(raw.toString()) as List;
        } else {
          specs = raw.toString().split(',');
        }
      } catch (_) {}
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Row(
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(color: const Color(0xFF88C9F9).withOpacity(0.2), shape: BoxShape.circle),
                child: const CaritaWidget(size: 72, color: Color(0xFF88C9F9), expressionType: 0),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name.isNotEmpty ? name : 'Barbero', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                    Text('@$username', style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade500)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: primaryGold.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text('Personal de Barbería', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: primaryGold)),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                onPressed: _handleLogout,
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Action buttons for edits
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showEditProfileSheet,
                  icon: const Icon(Icons.person_outline, size: 18),
                  label: Text('Editar Datos', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.grey.shade100,
                    foregroundColor: isDark ? Colors.white : Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showEditPortfolioSheet,
                  icon: const Icon(Icons.star_border_rounded, size: 18),
                  label: Text('Editar Portafolio', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGold,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),

          // Personal data card
          Text('DATOS DE CONTACTO', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1.2)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? Colors.grey.shade900 : Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildInfoRow(Icons.mail_outline_rounded, 'Email', email, primaryGold, isDark),
                const Divider(),
                _buildInfoRow(Icons.phone_android_rounded, 'Teléfono', phone, primaryGold, isDark),
              ],
            ),
          ),
          const SizedBox(height: 25),

          // Portfolio details card
          Text('PORTAFOLIO PROFESIONAL', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1.2)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? Colors.grey.shade900 : Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.text_snippet_outlined, 'Biografía', bio, primaryGold, isDark),
                const Divider(),
                _buildInfoRow(Icons.history_edu_rounded, 'Experiencia', exp, primaryGold, isDark),
                const Divider(),
                _buildInfoRow(Icons.camera_alt_outlined, 'Instagram', insta, primaryGold, isDark),
                if (specs.isNotEmpty) ...[
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.workspace_premium_outlined, color: primaryGold, size: 18),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Especialidades', style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade500)),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6, runSpacing: 6,
                                children: specs.map((s) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(color: primaryGold.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: primaryGold.withOpacity(0.2))),
                                  child: Text(s.toString(), style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: primaryGold)),
                                )).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color accentColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 18),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade500)),
                const SizedBox(height: 3),
                Text(value, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
