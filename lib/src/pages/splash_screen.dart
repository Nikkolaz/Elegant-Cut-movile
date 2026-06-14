import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:elegant_cut_mobile/src/pages/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animación de entrada inicial para los textos (Estilo Apple: Suave y elegante)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutQuart),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutQuart),
    );

    // Iniciar la animación al cargar la pantalla
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Animación de subida fluida desde el fondo de la pantalla (Estilo Premium)
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1.0), // Empieza totalmente abajo
              end: Offset.zero,            // Termina en su posición original
            ).animate(CurvedAnimation(
              parent: animation, 
              curve: Curves.fastLinearToSlowEaseIn, // Curva suave y elegante
            )),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color brandOrange = Color(0xFFD48B41);
    const Color pureBlack = Color(0xFF000000);
    const Color darkGrey = Color(0xFF0D0D0D);

    return Scaffold(
      backgroundColor: pureBlack,
      body: RepaintBoundary(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [darkGrey, pureBlack],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Contenido central optimizado
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: RepaintBoundary(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Bienvenido a',
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              color: Colors.white54,
                              letterSpacing: 4.0,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Elegant Cut',
                            style: GoogleFonts.outfit(
                              fontSize: 54,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: -1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: 40,
                            height: 2,
                            decoration: BoxDecoration(
                              color: brandOrange.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Botón con respuesta táctil inmediata
              Positioned(
                bottom: 60,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _AnimatedStartButton(onPressed: _navigateToLogin),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedStartButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _AnimatedStartButton({required this.onPressed});

  @override
  State<_AnimatedStartButton> createState() => _AnimatedStartButtonState();
}

class _AnimatedStartButtonState extends State<_AnimatedStartButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 220,
          height: 55,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            border: Border.all(color: Colors.white24, width: 1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Comenzar',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 2.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 15),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}

