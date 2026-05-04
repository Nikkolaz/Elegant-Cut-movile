import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elegant_cut_mobile/src/pages/register_page.dart';
import 'package:elegant_cut_mobile/src/pages/index_page.dart';
import 'package:google_fonts/google_fonts.dart';
import '../api/auth_service.dart';
import '../widgets/carita_widget.dart';
import 'dart:io';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _handleLogin() async {
    final usernameInput = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (usernameInput.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.login(usernameInput, password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success']) {
      // GUARDAR DATOS DEL USUARIO REAL
      final prefs = await SharedPreferences.getInstance();
      final userData = result['user'];
      
      // Guardamos el nombre real y el username
      await prefs.setString('firstName', userData['prim_nombre'] ?? 'Usuario');
      await prefs.setString('username', userData['username'] ?? '');
      await prefs.setString('email', userData['email'] ?? '');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const IndexPage()),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Fondo Ilustrativo (Optimizado con RepaintBoundary)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.65,
            child: RepaintBoundary(
              child: Container(
                color: Color(0xFFF0F4F8),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    Text(
                      'Elegant Cut',
                      style: GoogleFonts.outfit(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        letterSpacing: -1.5,
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CaritaWidget(top: 20, left: 30, size: 100, color: Color(0xFF98E68E), expressionType: 0), // Green Happy
                          CaritaWidget(top: 80, right: 40, size: 130, color: Color(0xFFFFB2D1), expressionType: 1), // Pink Wink
                          CaritaWidget(bottom: 60, left: 40, size: 120, color: Color(0xFF88C9F9), expressionType: 3), // Blue Cool
                          CaritaWidget(top: 180, left: -20, size: 90, color: Color(0xFFFFD56B), expressionType: 2), // Yellow Surprised
                          CaritaWidget(bottom: 20, right: 20, size: 80, color: Color(0xFFC7B8F5), expressionType: 4), // Purple Sleepy
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),

          // 2. Draggable Scrollable Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.45,
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
                        'Inicia sesión para comenzar',
                        style: GoogleFonts.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 30),

                      _buildSocialButton(
                        icon: Icons.g_mobiledata,
                        label: 'Sign in with Google',
                        color: Colors.white,
                        textColor: Colors.black,
                        borderColor: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 15),
                      _buildSocialButton(
                        icon: Icons.apple,
                        label: 'Sign in with Apple',
                        color: Colors.black,
                        textColor: Colors.white,
                      ),

                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(child: Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text('o usa tu cuenta', style: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 13)),
                          ),
                          Expanded(child: Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300)),
                        ],
                      ),
                      const SizedBox(height: 30),

                      _buildTextField(
                        controller: _usernameController,
                        hint: 'Nombre de usuario',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: _passwordController,
                        hint: 'Contraseña',
                        isDark: isDark,
                        obscure: true,
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD48B41),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                          ),
                          child: _isLoading 
                            ? const SizedBox(
                                height: 20, 
                                width: 20, 
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              )
                            : Text(
                                'INGRESAR', 
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold, 
                                  letterSpacing: 1.2,
                                  fontSize: 16,
                                )
                              ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterPage()),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: '¿No tienes cuenta? ',
                            style: GoogleFonts.outfit(color: isDark ? Colors.grey.shade400 : Colors.grey, fontSize: 15),
                            children: [
                              TextSpan(
                                text: 'Regístrate',
                                style: GoogleFonts.outfit(color: const Color(0xFFD48B41), fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: Colors.grey, fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildBubble({double? top, double? left, double? right, double? bottom, required double size, required Color color}) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
