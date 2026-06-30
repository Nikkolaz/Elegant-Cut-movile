import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_page.dart';
import '../auth/login_page.dart';
import '../../src/services/notification_service.dart';
import 'tabs/cuts_history_tab.dart';
import 'tabs/favorite_barbers_tab.dart';
import 'tabs/notifications_tab.dart';
import '../../shared/widgets/carita_widget.dart';
import '../../shared/widgets/custom_toast.dart';
import '../../state/profile/profile_provider.dart';
import '../../state/auth/auth_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
    context.read<ProfileProvider>().loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final profile = context.watch<ProfileProvider>();

    return Column(
      children: [
        Container(
          color: theme.scaffoldBackgroundColor,
          padding: const EdgeInsets.fromLTRB(25, 20, 25, 0),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildUserInfo(context, profile),
              const SizedBox(height: 20),
              _buildProfileDetails(context, profile),
              const SizedBox(height: 20),
              _buildTabBar(isDark),
              const SizedBox(height: 4),
            ],
          ),
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              CutsHistoryTab(),
              FavoriteBarbersTab(),
              NotificationsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Perfil', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
        Row(
          children: [
            GestureDetector(
              onTap: () => context.read<ProfileProvider>().fetchFullProfile(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: isDark ? Colors.grey.shade900 : Colors.grey.shade100, shape: BoxShape.circle),
                child: Icon(Icons.refresh_rounded, size: 22, color: isDark ? Colors.grey.shade400 : Colors.grey.shade800),
              ),
            ),
            const SizedBox(width: 10),
            Hero(
              tag: 'settings_gear',
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: isDark ? Colors.grey.shade900 : Colors.grey.shade100, shape: BoxShape.circle),
                  child: Icon(Icons.settings_outlined, size: 22, color: isDark ? Colors.grey.shade400 : Colors.grey.shade800),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context, ProfileProvider profile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGold = const Color(0xFFD48B41);

    return Row(
      children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(color: const Color(0xFFC7B8F5).withOpacity(0.2), shape: BoxShape.circle),
          child: const CaritaWidget(size: 72, color: Color(0xFFC7B8F5), expressionType: 0),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.displayName,
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 2),
              Text(
                '@${profile.username}',
                style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: primaryGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  profile.roleName,
                  style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: primaryGold),
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            GestureDetector(
              onTap: () => _showEditProfileSheet(context, profile),
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: primaryGold.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.edit_outlined, color: primaryGold, size: 18),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final authProvider = context.read<AuthProvider>();
                final navigator = Navigator.of(context);
                await NotificationService().unregisterToken();
                await authProvider.logout();
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('email');
                await prefs.remove('id_usuario');
                await prefs.remove('id_rol');
                await prefs.remove('fcm_token');
                if (!mounted) return;
                navigator.pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginPage()), (r) => false);
              },
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.08), shape: BoxShape.circle),
                child: const Icon(Icons.logout, color: Colors.red, size: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileDetails(BuildContext context, ProfileProvider profile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGold = const Color(0xFFD48B41);

    if (profile.isLoading && profile.fullData == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.grey.shade900 : Colors.grey.shade200),
        ),
        child: const Center(child: CircularProgressIndicator(color: Color(0xFFD48B41), strokeWidth: 2)),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.grey.shade900 : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.person_outline_rounded, 'Nombre completo', profile.fullName, isDark, primaryGold),
          _buildDivider(isDark),
          _buildInfoRow(Icons.mail_outline_rounded, 'Correo electrónico', profile.email.isNotEmpty ? profile.email : 'No especificado', isDark, primaryGold),
          _buildDivider(isDark),
          _buildInfoRow(Icons.phone_android_rounded, 'Teléfono', profile.phone.isNotEmpty ? profile.phone : 'No especificado', isDark, primaryGold),
          _buildDivider(isDark),
          _buildInfoRow(Icons.alternate_email_rounded, 'Username', '@${profile.username}', isDark, primaryGold),
          _buildDivider(isDark),
          _buildInfoRow(Icons.calendar_today_outlined, 'Miembro desde', _formatDate(profile.createdAt), isDark, primaryGold),
        ],
      ),
    ).animate().fade(duration: 300.ms).slideY(begin: 0.03, curve: Curves.easeOut);
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
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

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
    );
  }

  // ── Edit Profile Bottom Sheet ──

  void _showEditProfileSheet(BuildContext context, ProfileProvider profile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGold = const Color(0xFFD48B41);

    final firstNameCtrl = TextEditingController(text: profile.firstName);
    final secondNameCtrl = TextEditingController(text: profile.secondName);
    final lastName1Ctrl = TextEditingController(text: profile.lastName1);
    final lastName2Ctrl = TextEditingController(text: profile.lastName2);
    final emailCtrl = TextEditingController(text: profile.email);
    final phoneCtrl = TextEditingController(text: profile.phone);

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
                  // Handle bar
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryGold.withOpacity(0.2), primaryGold.withOpacity(0.05)],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.edit_rounded, color: primaryGold, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Editar Perfil',
                                style: GoogleFonts.outfit(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                'Actualiza tu información personal',
                                style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close_rounded, size: 20, color: isDark ? Colors.white70 : Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Form fields
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel('Información Personal', isDark),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildFormField(
                                  controller: firstNameCtrl,
                                  label: 'Primer nombre',
                                  icon: Icons.person_outline_rounded,
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildFormField(
                                  controller: secondNameCtrl,
                                  label: 'Segundo nombre',
                                  icon: Icons.person_outline_rounded,
                                  isDark: isDark,
                                  isOptional: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _buildFormField(
                                  controller: lastName1Ctrl,
                                  label: 'Primer apellido',
                                  icon: Icons.badge_outlined,
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildFormField(
                                  controller: lastName2Ctrl,
                                  label: 'Segundo apellido',
                                  icon: Icons.badge_outlined,
                                  isDark: isDark,
                                  isOptional: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          _buildSectionLabel('Contacto', isDark),
                          const SizedBox(height: 12),
                          _buildFormField(
                            controller: emailCtrl,
                            label: 'Correo electrónico',
                            icon: Icons.mail_outline_rounded,
                            isDark: isDark,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 14),
                          _buildFormField(
                            controller: phoneCtrl,
                            label: 'Teléfono',
                            icon: Icons.phone_android_rounded,
                            isDark: isDark,
                            isOptional: true,
                            keyboardType: TextInputType.phone,
                          ),

                          const SizedBox(height: 30),

                          // Save button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: isSaving ? null : () async {
                                // Validate required fields
                                if (firstNameCtrl.text.trim().isEmpty) {
                                  CustomToast.show(ctx, 'El primer nombre es obligatorio', ToastType.error);
                                  return;
                                }
                                if (lastName1Ctrl.text.trim().isEmpty) {
                                  CustomToast.show(ctx, 'El primer apellido es obligatorio', ToastType.error);
                                  return;
                                }
                                if (emailCtrl.text.trim().isEmpty) {
                                  CustomToast.show(ctx, 'El correo es obligatorio', ToastType.error);
                                  return;
                                }

                                setSheetState(() => isSaving = true);

                                final data = <String, dynamic>{
                                  'prim_nombre': firstNameCtrl.text.trim(),
                                  'apellido1': lastName1Ctrl.text.trim(),
                                  'email': emailCtrl.text.trim(),
                                };

                                // Only send optional fields if they have value
                                if (secondNameCtrl.text.trim().isNotEmpty) {
                                  data['seg_nombre'] = secondNameCtrl.text.trim();
                                } else {
                                  data['seg_nombre'] = '';
                                }

                                if (lastName2Ctrl.text.trim().isNotEmpty) {
                                  data['apellido2'] = lastName2Ctrl.text.trim();
                                } else {
                                  data['apellido2'] = '';
                                }

                                if (phoneCtrl.text.trim().isNotEmpty) {
                                  data['telefono'] = phoneCtrl.text.trim();
                                } else {
                                  data['telefono'] = '';
                                }

                                final profileProvider = context.read<ProfileProvider>();
                                final result = await profileProvider.updateProfile(data);

                                setSheetState(() => isSaving = false);

                                if (!ctx.mounted) return;

                                if (result['success'] == true) {
                                  CustomToast.show(ctx, 'Perfil actualizado correctamente', ToastType.success);
                                  Navigator.pop(ctx);
                                } else {
                                  CustomToast.show(ctx, result['message'] ?? 'Error al actualizar', ToastType.error);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGold,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                elevation: 0,
                              ),
                              child: isSaving
                                  ? const SizedBox(
                                      width: 24, height: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.save_rounded, size: 20),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Guardar Cambios',
                                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Info note
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2C2C2E) : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline_rounded, size: 18, color: Colors.blue.shade400),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'El nombre de usuario se cambia desde Configuración.',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
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

  Widget _buildSectionLabel(String label, bool isDark) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade500,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool isOptional = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final primaryGold = const Color(0xFFD48B41);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            if (isOptional) ...[
              const SizedBox(width: 4),
              Text(
                '(opcional)',
                style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.outfit(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 20, color: primaryGold.withOpacity(0.6)),
              hintText: label,
              hintStyle: GoogleFonts.outfit(color: Colors.grey.shade500, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'No disponible';
    try {
      final dt = DateTime.parse(isoDate);
      final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return 'No disponible';
    }
  }

  Widget _buildTabBar(bool isDark) {
    final tabs = [
      {'label': 'Historial', 'icon': Icons.history_rounded},
      {'label': 'Favoritos', 'icon': Icons.favorite_rounded},
      {'label': 'Notificaciones', 'icon': Icons.notifications_rounded},
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isSelected = _tabController.index == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => _tabController.animateTo(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? (isDark ? const Color(0xFF2C2C2E) : Colors.white) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))] : [],
                ),
                child: Column(
                  children: [
                    Icon(tabs[i]['icon'] as IconData, size: 18, color: isSelected ? const Color(0xFFD48B41) : Colors.grey.shade400),
                    const SizedBox(height: 3),
                    Text(
                      tabs[i]['label'] as String,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? (isDark ? Colors.white : Colors.black) : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
