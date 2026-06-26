import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elegant_cut_mobile/src/pages/register_page.dart';
import 'package:elegant_cut_mobile/src/pages/index_page.dart';
import 'package:elegant_cut_mobile/src/pages/admin/admin_index_page.dart';
import 'package:elegant_cut_mobile/src/services/notification_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../api/auth_service.dart';
import '../widgets/carita_widget.dart';
import '../widgets/custom_toast.dart';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:math' as math;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  late final GoogleSignIn _googleSignIn;
  bool _isHeavyContentVisible = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _googleSignIn = GoogleSignIn(
      serverClientId: '859330875259-h0oa83sb0k5e46rg3bop16unfao1jch6.apps.googleusercontent.com',
    );

    // Retraso mínimo para asegurar que la transición de entrada sea fluida
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _isHeavyContentVisible = true);
    });
  }

  void _handleLogin() async {
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

    setState(() => _isLoading = true);

    final result = await _authService.login(usernameInput, password);

    if (!mounted) return;
    setState(() => _isLoading = false);

      if (result['success']) {
        // GUARDAR DATOS DEL USUARIO REAL
        final prefs = await SharedPreferences.getInstance();
        final userData = result['user'];
        
        // Guardamos el nombre real y el username
        await prefs.setString('token', result['token'] ?? '');
        await prefs.setInt('id_usuario', userData['id_usuario'] ?? userData['id'] ?? 1);
        
        final int idRol = userData['id_rol'] ?? 2; // Asumimos cliente (2) si es nulo
        await prefs.setInt('id_rol', idRol);
        
        await prefs.setString('firstName', userData['prim_nombre'] ?? 'Usuario');
        await prefs.setString('username', userData['username'] ?? '');
        await prefs.setString('email', userData['email'] ?? '');

        // Registrar token FCM para notificaciones push
        await NotificationService().registerAfterLogin();

        if (!mounted) return;
        CustomToast.show(
          context,
          result['message'],
          ToastType.success,
        );
        
        if (idRol == 1) { // 1 es Administrador
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
      if (!mounted) return;
      CustomToast.show(
        context,
        result['message'],
        ToastType.error,
      );
    }
  }

  /// Función para el proceso de inicio de sesión con Google
  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() => _isLoading = true);

      // 1. Abrir el selector de cuentas de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => _isLoading = false);
        return; // El usuario canceló
      }

      // 2. Obtener el token de identidad
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken != null) {
        // 3. Enviar el token a tu backend usando el servicio
        final result = await _authService.loginWithGoogle(idToken);

        if (!mounted) return;
        setState(() => _isLoading = false);

        if (result['success']) {
          // Guardar datos del usuario igual que el login normal
          final prefs = await SharedPreferences.getInstance();
          final userData = result['user'];

          await prefs.setString('token', result['token'] ?? '');
          await prefs.setInt('id_usuario', userData['id_usuario'] ?? userData['id'] ?? 1);
          
          final int idRol = userData['id_rol'] ?? 2;
          await prefs.setInt('id_rol', idRol);
          
          await prefs.setString(
              'firstName', userData['prim_nombre'] ?? 'Usuario');
          await prefs.setString('username', userData['username'] ?? '');
          await prefs.setString('email', userData['email'] ?? '');

          // Registrar token FCM para notificaciones push
          await NotificationService().registerAfterLogin();

          if (!mounted) return;
          CustomToast.show(
            context,
            result['message'],
            ToastType.success,
          );
          
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
          if (!mounted) return;
          CustomToast.show(
            context,
            result['message'],
            ToastType.error,
          );
        }
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      print('Error en Google Sign In: $error');
      CustomToast.show(
        context,
        'Error al conectar con Google',
        ToastType.error,
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
                              CaritaWidget(top: 20, left: 30, size: 100, color: const Color(0xFF98E68E), expressionType: 0), // Green Happy
                              CaritaWidget(top: 80, right: 40, size: 130, color: const Color(0xFFFFB2D1), expressionType: 1), // Pink Wink
                              CaritaWidget(bottom: 60, left: 40, size: 120, color: const Color(0xFF88C9F9), expressionType: 3), // Blue Cool
                              CaritaWidget(top: 180, left: -20, size: 90, color: const Color(0xFFFFD56B), expressionType: 2), // Yellow Surprised
                              CaritaWidget(bottom: 20, right: 20, size: 80, color: const Color(0xFFC7B8F5), expressionType: 4), // Purple Sleepy
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

          // 2. Botón de Registro animado (Esquina superior derecha)
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
                                    final offset = math.sin(value * 6 * math.pi) * 3.0; // 3 rebotes rápidos
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
                    // 3. Draggable Scrollable Sheet optimizado
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
                        
                        // Entrada animada sutil para el contenido
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
                                ],
                              )
                            : const SizedBox(height: 300), // Placeholder mientras carga
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
          onTap: _isLoading ? null : _handleGoogleSignIn,
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
