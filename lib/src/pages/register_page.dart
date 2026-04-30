import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // 1. Controladores para capturar lo que el usuario escribe
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fondo oscuro Premium
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context), // Volver al Login
        ),
      ),
      body: SingleChildScrollView(
        // Para evitar errores si el teclado tapa los campos
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Crea tu\nCuenta.',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Únete a la experiencia Elegant Cut.',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
              ),
              const SizedBox(height: 40),

              // 2. Campo de Nombre
              _buildCustomTextField(
                controller: _nameController,
                hintText: 'Nombre completo',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),

              // 3. Campo de Correo
              _buildCustomTextField(
                controller: _emailController,
                hintText: 'Correo electrónico',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // 4. Campo de Teléfono
              _buildCustomTextField(
                controller: _phoneController,
                hintText: 'Teléfono',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),

              // 5. Campo de Contraseña
              _buildCustomTextField(
                controller: _passwordController,
                hintText: 'Contraseña',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 40),

              // 6. Botón de Registro
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFFD48B41,
                    ), // Tu Naranja Madera
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    // Aquí procesaremos los datos
                    print('Registrando a: ${_nameController.text}');
                  },
                  child: const Text(
                    'REGISTRARSE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 7. Widget helper para no repetir código de diseño en los inputs
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E), // Gris oscuro como el Login
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }
}
