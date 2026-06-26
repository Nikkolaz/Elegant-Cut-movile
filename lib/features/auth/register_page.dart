import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/widgets/carita_widget.dart';
import '../../shared/widgets/custom_toast.dart';
import '../../state/auth/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _secondNameController = TextEditingController();
  final _lastName1Controller = TextEditingController();
  final _lastName2Controller = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _handleRegister() async {
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final firstName = _firstNameController.text.trim();
    final secondName = _secondNameController.text.trim();
    final lastName1 = _lastName1Controller.text.trim();
    final lastName2 = _lastName2Controller.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || username.isEmpty || firstName.isEmpty || lastName1.isEmpty || password.isEmpty) {
      CustomToast.show(context, 'Por favor completa los campos obligatorios (*)', ToastType.error);
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      username: username,
      email: email,
      firstName: firstName,
      secondName: secondName,
      lastName1: lastName1,
      lastName2: lastName2,
      phone: phone,
      password: password,
    );

    if (!mounted) return;

    if (success) {
      CustomToast.show(context, '¡Cuenta creada con éxito!', ToastType.success);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    } else {
      CustomToast.show(context, authProvider.error ?? 'Error al registrarse', ToastType.error);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _firstNameController.dispose();
    _secondNameController.dispose();
    _lastName1Controller.dispose();
    _lastName2Controller.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.45,
            child: RepaintBoundary(
              child: Container(
                color: Color(0xFFF0F4F8),
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          'Crear Cuenta',
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CaritaWidget(top: 10, right: 40, size: 90, color: Color(0xFF98E68E), expressionType: 0),
                          CaritaWidget(top: 40, left: 30, size: 100, color: Color(0xFFFFB2D1), expressionType: 1),
                          CaritaWidget(bottom: 20, right: 20, size: 110, color: Color(0xFF88C9F9), expressionType: 3),
                          CaritaWidget(top: 80, left: 120, size: 95, color: Color(0xFFFFD56B), expressionType: 2),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.6,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: isDark ? Color(0xFF121212) : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Únete a la experiencia Elegant Cut',
                        style: GoogleFonts.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildSocialButton(
                        icon: Icons.g_mobiledata,
                        label: 'Register with Google',
                        color: Colors.white,
                        textColor: Colors.black,
                        borderColor: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(child: Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text('o crea tu cuenta', style: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 13)),
                          ),
                          Expanded(child: Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300)),
                        ],
                      ),
                      const SizedBox(height: 30),
                      _buildTextField(
                        controller: _emailController,
                        hint: 'Correo electrónico *',
                        icon: Icons.email_outlined,
                        isDark: isDark,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: _usernameController,
                        hint: 'Nombre de usuario *',
                        icon: Icons.person_outline,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _firstNameController,
                              hint: 'Primer nombre *',
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                              controller: _secondNameController,
                              hint: 'Segundo nombre',
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _lastName1Controller,
                              hint: 'Primer apellido *',
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                              controller: _lastName2Controller,
                              hint: 'Segundo apellido',
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: _phoneController,
                        hint: 'Teléfono',
                        icon: Icons.phone_outlined,
                        isDark: isDark,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: _passwordController,
                        hint: 'Contraseña *',
                        icon: Icons.lock_outline,
                        isDark: isDark,
                        obscure: true,
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD48B41),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                          ),
                          child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                'CREAR CUENTA',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  fontSize: 16,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    required bool isDark,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black, fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey, size: 20) : null,
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: Colors.grey, fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    Color? borderColor,
  }) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        border: borderColor != null ? Border.all(color: borderColor) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 28),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
