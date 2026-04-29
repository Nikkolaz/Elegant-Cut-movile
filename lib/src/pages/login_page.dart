import 'package:flutter/material.dart';
import 'package:elegant_cut_mobile/src/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Nuestro interruptor
  bool _mostrarFormulario = false;

  @override
  void initState() {
    super.initState();
    // A los 2 segundos, actualizamos el estado para encender el formulario
    Future.delayed(const Duration(seconds: 2), () {
      // Usamos setState que sí existe aquí dentro de _LoginPageState
      setState(() {
        _mostrarFormulario = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Título imponente (Este SIEMPRE se ve)
              const Text(
                'Elegant\nCut.',
                style: TextStyle(
                  fontSize: 54,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15),

              // 2. El Formulario Animado
              AnimatedOpacity(
                duration: const Duration(
                  milliseconds: 1500,
                ), // Tarda 1.5s en aparecer
                opacity: _mostrarFormulario ? 1.0 : 0.0,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reserva tu estilo.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 50),

                    // Input de Email Mágico!
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const TextField(
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Correo electrónico',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(22),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Input de Contraseña (Código Dos)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const TextField(
                        obscureText: true, // Oculta las letras
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        decoration: InputDecoration(
                          hintText: 'Contraseña',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(22),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFFD48B41,
                          ), // Naranja Madera
                          foregroundColor: Colors.white, // Color de texto
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation:
                              0, // Las apps modernas de iOS no usan sombra aquí
                        ),
                        onPressed: () {
                          // Aquí mandaremos a llamar el servicio backend luego
                        },
                        child: const Text(
                          'INICIAR SESIÓN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),

                    // Debajo del botón de Iniciar Sesión es el de registro 
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterPage()),
                          );
                        },
                        child: RichText(
                          text: const TextSpan(
                            text: '¿No tienes cuenta? ',
                            style: TextStyle(color: Colors.grey),
                            children: [
                              TextSpan(
                                text: 'Regístrate',
                                style: TextStyle(
                                  color: Color(0xFFD48B41),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
