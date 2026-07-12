import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/network/admin_service.dart';
import '../../shared/widgets/custom_toast.dart';
import 'widgets/admin_administrator_form_dialog.dart';

class AdminAdministratorsPage extends StatefulWidget {
  const AdminAdministratorsPage({super.key});

  @override
  State<AdminAdministratorsPage> createState() => _AdminAdministratorsPageState();
}

class _AdminAdministratorsPageState extends State<AdminAdministratorsPage> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  List<dynamic> _allAdmins = [];
  List<dynamic> _filteredAdmins = [];
  final TextEditingController _searchController = TextEditingController();
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadAdministrators();
    _searchController.addListener(_filterAdministrators);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAdministrators() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final response = await _adminService.getAdministrators();
      if (response['success'] == true) {
        setState(() {
          _allAdmins = response['data'] ?? [];
          _filteredAdmins = List.from(_allAdmins);
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Error al cargar administradores';
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

  void _filterAdministrators() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredAdmins = List.from(_allAdmins);
      } else {
        _filteredAdmins = _allAdmins.where((admin) {
          final firstName = (admin['prim_nombre'] ?? '').toString().toLowerCase();
          final lastName = (admin['apellido1'] ?? '').toString().toLowerCase();
          final email = (admin['email'] ?? '').toString().toLowerCase();
          final username = (admin['username'] ?? '').toString().toLowerCase();
          final fullName = '$firstName $lastName';
          
          return firstName.contains(query) ||
              lastName.contains(query) ||
              email.contains(query) ||
              username.contains(query) ||
              fullName.contains(query);
        }).toList();
      }
    });
  }

  Future<bool> _handleSaveAdministrator(Map<String, dynamic> data, {int? adminId}) async {
    final isEdit = adminId != null;
    final Map<String, dynamic> response;

    if (isEdit) {
      response = await _adminService.updateAdmin(adminId, data);
    } else {
      response = await _adminService.createAdmin(data);
    }

    if (!mounted) return false;

    if (response['success'] == true) {
      CustomToast.show(
        context,
        response['message'] ?? (isEdit ? 'Administrador actualizado' : 'Administrador creado'),
        ToastType.success,
      );
      _loadAdministrators();
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

  Future<void> _handleToggleStatus(dynamic admin) async {
    final adminId = admin['id_usuario'] ?? admin['id'];
    if (adminId == null) return;

    final currentStatus = admin['estado'] == true;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            currentStatus ? '¿Desactivar Administrador?' : '¿Activar Administrador?',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Text(
            currentStatus 
                ? 'El administrador perderá sus credenciales de acceso al panel administrativo de inmediato.'
                : 'El administrador recuperará sus privilegios de acceso al sistema.',
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
              child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    final response = await _adminService.toggleAdminStatus(adminId);
    
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response['success'] == true) {
      CustomToast.show(context, 'Estado actualizado correctamente', ToastType.success);
      _loadAdministrators();
    } else {
      CustomToast.show(context, response['message'] ?? 'Error al actualizar estado', ToastType.error);
    }
  }

  void _showFormDialog({Map<String, dynamic>? admin}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AdminAdministratorFormDialog(
        administrator: admin,
        onSave: (data) => _handleSaveAdministrator(data, adminId: admin?['id_usuario'] ?? admin?['id']),
      ),
    );
  }

  void _showAdminDetails(dynamic admin) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final primaryGold = const Color(0xFFD48B41);
        final firstName = admin['prim_nombre'] ?? '';
        final secondName = admin['seg_nombre'] ?? '';
        final lastName1 = admin['apellido1'] ?? '';
        final lastName2 = admin['apellido2'] ?? '';
        final fullName = '$firstName $secondName $lastName1 $lastName2'.replaceAll(RegExp(r'\s+'), ' ').trim();
        final username = admin['username'] ?? 'No especificado';
        final email = admin['email'] ?? 'No especificado';
        final phone = admin['telefono'] ?? 'No especificado';
        final isActive = admin['estado'] == true;

        String creationDate = 'No disponible';
        if (admin['created_at'] != null) {
          try {
            final dt = DateTime.parse(admin['created_at']);
            creationDate = '${dt.day}/${dt.month}/${dt.year} a las ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
          } catch (_) {}
        }

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: primaryGold.withOpacity(0.1),
                    child: Text(
                      firstName.isNotEmpty ? firstName.substring(0, 1).toUpperCase() : 'A',
                      style: GoogleFonts.outfit(
                        color: primaryGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName.isNotEmpty ? fullName : 'Administrador',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryGold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Administrador del Sistema',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: primaryGold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              const Divider(height: 1),
              const SizedBox(height: 20),
              _buildDetailItem('Nombre de usuario', username, Icons.person_outline_rounded, isDark),
              _buildDetailItem('Correo electrónico', email, Icons.mail_outline_rounded, isDark),
              _buildDetailItem('Teléfono', phone, Icons.phone_android_rounded, isDark),
              _buildDetailItem('Fecha de registro', creationDate, Icons.calendar_today_outlined, isDark),
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estado de la cuenta',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        isActive ? 'Cuenta activa y con acceso' : 'Cuenta inhabilitada',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  Switch.adaptive(
                    value: isActive,
                    activeColor: primaryGold,
                    onChanged: (val) {
                      Navigator.pop(context);
                      _handleToggleStatus(admin);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String title, String val, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade500, size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  val,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
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
          'Gestión de Administradores',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: isDark ? Colors.white : Colors.black),
            onPressed: _loadAdministrators,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        backgroundColor: primaryGold,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C1E) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o email...',
                  hintStyle: GoogleFonts.outfit(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
          ),
          
          // List content
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
                                onPressed: _loadAdministrators,
                                style: ElevatedButton.styleFrom(backgroundColor: primaryGold),
                                child: const Text('Reintentar'),
                              )
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadAdministrators,
                        color: primaryGold,
                        child: _filteredAdmins.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                                  Center(
                                    child: Text(
                                      'No se encontraron administradores.',
                                      style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                itemCount: _filteredAdmins.length,
                                itemBuilder: (context, index) {
                                  final admin = _filteredAdmins[index];
                                  final isActive = admin['estado'] == true;
                                  final firstName = admin['prim_nombre'] ?? '';
                                  final lastName = admin['apellido1'] ?? '';
                                  final fullName = firstName.isNotEmpty
                                      ? '$firstName $lastName'
                                      : (admin['username'] ?? 'Administrador');
                                  final email = admin['email'] ?? 'Sin correo';

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
                                                firstName.isNotEmpty ? firstName.substring(0, 1).toUpperCase() : 'A',
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
                                                    fullName,
                                                    style: GoogleFonts.outfit(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 18,
                                                      color: isDark ? Colors.white : Colors.black87,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    email,
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 13,
                                                      color: Colors.grey.shade500,
                                                    ),
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
                                        if (admin['telefono'] != null && admin['telefono'].toString().isNotEmpty) ...[
                                          const SizedBox(height: 12),
                                          Text(
                                            '📞 ${admin['telefono']}',
                                            style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade500),
                                          ),
                                        ],
                                        const SizedBox(height: 16),
                                        const Divider(height: 1),
                                        const SizedBox(height: 10),
                                        // Action Buttons
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () => _showAdminDetails(admin),
                                              child: Text(
                                                'Ver Detalles',
                                                style: GoogleFonts.outfit(
                                                  color: primaryGold,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            const Spacer(),
                                            TextButton.icon(
                                              onPressed: () => _handleToggleStatus(admin),
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
                                              onPressed: () => _showFormDialog(admin: admin),
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
          ),
        ],
      ),
    );
  }
}
