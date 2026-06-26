import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/network/admin_service.dart';
import '../../shared/widgets/custom_toast.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  List<dynamic> _allUsers = [];
  List<dynamic> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final response = await _adminService.getAllUsers();
      
      // The endpoint can return a Map with success: true and data list, or a raw List.
      if (response['success'] == true) {
        setState(() {
          _allUsers = response['data'] ?? [];
          _filteredUsers = List.from(_allUsers);
        });
      } else if (response['success'] == false && response['message'] != null) {
        setState(() {
          _errorMessage = response['message'];
        });
      } else {
        // Fallback in case raw list is decoded
        setState(() {
          _allUsers = response['data'] ?? [];
          _filteredUsers = List.from(_allUsers);
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

  void _filterUsers() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = List.from(_allUsers);
      } else {
        _filteredUsers = _allUsers.where((user) {
          final firstName = (user['prim_nombre'] ?? '').toString().toLowerCase();
          final lastName = (user['apellido1'] ?? '').toString().toLowerCase();
          final email = (user['email'] ?? '').toString().toLowerCase();
          final username = (user['username'] ?? '').toString().toLowerCase();
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

  Future<void> _toggleUserStatus(dynamic user) async {
    final userId = user['id_usuario'] ?? user['id'];
    if (userId == null) return;

    final currentStatus = user['estado'] == true;
    final newStatus = !currentStatus;

    setState(() => _isLoading = true);
    try {
      final response = await _adminService.updateUserStatus(userId, newStatus);
      if (response['success'] == true) {
        if (mounted) {
          CustomToast.show(
            context,
            'Estado del usuario actualizado a ${newStatus ? 'Activo' : 'Inactivo'}',
            ToastType.success,
          );
        }
        _loadUsers();
      } else {
        if (mounted) {
          CustomToast.show(
            context,
            response['message'] ?? 'Error al actualizar usuario',
            ToastType.error,
          );
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

  void _showUserDetails(dynamic user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final primaryGold = const Color(0xFFD48B41);
        final firstName = user['prim_nombre'] ?? '';
        final secondName = user['seg_nombre'] ?? '';
        final lastName1 = user['apellido1'] ?? '';
        final lastName2 = user['apellido2'] ?? '';
        final fullName = '$firstName $secondName $lastName1 $lastName2'.replaceAll(RegExp(r'\s+'), ' ').trim();
        final username = user['username'] ?? 'No especificado';
        final email = user['email'] ?? 'No especificado';
        final phone = user['telefono'] ?? 'No especificado';
        final roleId = user['id_rol'] ?? 2;
        final isActive = user['estado'] == true;

        String roleText = 'Cliente';
        if (roleId == 1) roleText = 'Administrador';
        if (roleId == 3) roleText = 'Barbero';

        // Created at parsing
        String creationDate = 'No disponible';
        if (user['created_at'] != null) {
          try {
            final dt = DateTime.parse(user['created_at']);
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
                      firstName.isNotEmpty ? firstName.substring(0, 1).toUpperCase() : 'U',
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
                          fullName.isNotEmpty ? fullName : 'Usuario',
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
                            roleText,
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
              
              // Status Toggle inside Details
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
                      _toggleUserStatus(user);
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
        title: Text(
          'Usuarios',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: isDark ? Colors.white : Colors.black),
            onPressed: _loadUsers,
          ),
        ],
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
                  hintText: 'Buscar por nombre, usuario o email...',
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
          
          // Users List
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
                                onPressed: _loadUsers,
                                style: ElevatedButton.styleFrom(backgroundColor: primaryGold),
                                child: const Text('Reintentar'),
                              )
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
                        color: primaryGold,
                        child: _filteredUsers.isEmpty
                            ? ListView(
                                children: [
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                                  Center(
                                    child: Text(
                                      'No se encontraron usuarios.',
                                      style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                itemCount: _filteredUsers.length,
                                itemBuilder: (context, index) {
                                  final user = _filteredUsers[index];
                                  final isActive = user['estado'] == true;
                                  final firstName = user['prim_nombre'] ?? '';
                                  final lastName = user['apellido1'] ?? '';
                                  final fullName = firstName.isNotEmpty
                                      ? '$firstName $lastName'
                                      : (user['username'] ?? 'Usuario');
                                  
                                  final email = user['email'] ?? 'Sin correo';

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
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
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () => _showUserDetails(user),
                                        borderRadius: BorderRadius.circular(20),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: primaryGold.withOpacity(0.1),
                                                child: Text(
                                                  firstName.isNotEmpty ? firstName.substring(0, 1).toUpperCase() : 'U',
                                                  style: GoogleFonts.outfit(
                                                    color: primaryGold,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 15),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      fullName,
                                                      style: GoogleFonts.outfit(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                        color: isDark ? Colors.white : Colors.black87,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
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
                                              const SizedBox(width: 10),
                                              // Toggle switch for immediate status change
                                              Switch.adaptive(
                                                value: isActive,
                                                activeColor: primaryGold,
                                                onChanged: (val) => _toggleUserStatus(user),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
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
