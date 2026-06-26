import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_page.dart';
import '../home/index_page.dart';
import '../admin/admin_index_page.dart';
import '../../src/services/notification_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/widgets/carita_widget.dart';
import '../../shared/widgets/custom_toast.dart';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:math' as math;
import '../../state/auth/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final GoogleSignIn _googleSignIn;
  bool _isHeavyContentVisible = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _googleSignIn = GoogleSignIn(
      serverClientId: '859330875259-h0oa83sb0k5e46rg3bop16unfao1jch6.apps.googleusercontent.com',
    );

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _isHeavyContentVisible = true);
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final usernameInput = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (usernameInput.isEmpty || password.isEmpty) {
      CustomToast.show(
        context,
        'Por favor completa todos los campos',
        ToastType.error,
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(usernameInput, password);

    if (!mounted) return;

    if (success) {
      await NotificationService().registerAfterLogin();
      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      final int idRol = prefs.getInt('id_rol') ?? 2;

      CustomToast.show(context, 'Inicio de sesión exitoso', ToastType.success);

      if (idRol == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminIndexPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const IndexPage()),
        );
      }
    } else {
      CustomToast.show(
        context,
        authProvider.error ?? 'Error al iniciar sesión',
        ToastType.error,
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken != null) {
        final authProvider = context.read<AuthProvider>();
        final success = await authProvider.loginWithGoogle(idToken);

        if (!mounted) return;

        if (success) {
          final prefs = await SharedPreferences.getInstance();
          final int idRol = prefs.getInt('id_rol') ?? 2;

          CustomToast.show(context, 'Inicio de sesión exitoso', ToastType.success);

          await NotificationService().registerAfterLogin();

          if (!mounted) return;
          if (idRol == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminIndexPage()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const IndexPage()),
            );
          }
        } else {
          CustomToast.show(
            context,
            authProvider.error ?? 'Error al iniciar sesión con Google',
            ToastType.error,
          );
        }
      }
    } catch (error) {
      if (!mounted) return;
      CustomToast.show(context, 'Error al conectar con Google', ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
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
                    const SizedBox(height: 100),
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
                        children: _isHeavyContentVisible
                          ? [
                              CaritaWidget(top: 20, left: 30, size: 100, color: const Color(0xFF98E68E), expressionType: 0),
                              CaritaWidget(top: 80, right: 40, size: 130, color: const Color(0xFFFFB2D1), expressionType: 1),
                              CaritaWidget(bottom: 60, left: 40, size: 120, color: const Color(0xFF88C9F9), expressionType: 3),
                              CaritaWidget(top: 180, left: -20, size: 90, color: const Color(0xFFFFD56B), expressionType: 2),
                              CaritaWidget(bottom: 20, right: 20, size: 80, color: const Color(0xFFC7B8F5), expressionType: 4),
                            ]
                          : [],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 15.0, right: 20.0),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD48B41).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Material(
                      color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const RegisterPage(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.fastOutSlowIn;
                                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                return SlideTransition(
                                  position: animation.drive(tween),
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                              transitionDuration: const Duration(milliseconds: 400),
                            ),
                          );
                        },
                        splashColor: const Color(0xFFD48B41).withOpacity(0.1),
                        highlightColor: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Únete ahora',
                                style: GoogleFonts.outfit(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD48B41),
                                  shape: BoxShape.circle,
                                ),
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(seconds: 3),
                                  builder: (context, value, child) {
                                    final offset = math.sin(value * 6 * math.pi) * 3.0;
                                    return Transform.translate(
                                      offset: Offset(offset, 0),
                                      child: child,
                                    );
                                  },
                                  child: const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.45,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return RepaintBoundary(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF121212) : Colors.white,
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
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: _isHeavyContentVisible
                            ? Column(
                                children: [
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
                                    isLoading: isLoading,
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
                                      onPressed: isLoading ? null : _handleLogin,
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
                                            'INGRESAR',
                                            style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.2,
                                              fontSize: 16,
                                            ),
                                          ),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(height: 300),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
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
    bool isLoading = false,
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
          onTap: isLoading ? null : _handleGoogleSignIn,
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
}
