import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/carita_widget.dart';
import '../widgets/service_card.dart';

class BarberDetailPage extends StatelessWidget {
  final Map<String, dynamic> barber;

  const BarberDetailPage({super.key, required this.barber});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    // Colores por defecto si no vienen en el mapa
    final Color barberColor = barber['color'] ?? const Color(0xFF98E68E);
    final int expression = barber['expression'] ?? 0;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FB),
      body: Stack(
        children: [
          // 1. Cabecera con Animación Hero
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.45,
            child: Container(
              decoration: BoxDecoration(
                color: barberColor.withOpacity(isDark ? 0.2 : 0.4),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Center(
                child: Hero(
                  tag: 'barber_hero_${barber['name']}',
                  child: CaritaWidget(
                    size: 180,
                    color: barberColor,
                    expressionType: expression,
                  ),
                ),
              ),
            ),
          ),

          // 2. Panel de Información (Minimalista)
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.55,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -10),
                      )
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      barber['name'],
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      'Experto en Estilo & Barba',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildStats(isDark),
                    const SizedBox(height: 30),
                    Text(
                      'Sobre mí',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Con más de 8 años de experiencia, me especializo en crear estilos únicos que resaltan tu personalidad. La precisión es mi firma.',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Servicios',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const ServiceCard(
                      name: 'Corte Premium',
                      price: r'$25',
                      duration: '45 min',
                      icon: Icons.content_cut,
                      color: Colors.transparent,
                      isListMode: true,
                    ),
                    const ServiceCard(
                      name: 'Perfilado Barba',
                      price: r'$15',
                      duration: '30 min',
                      icon: Icons.face,
                      color: Colors.transparent,
                      isListMode: true,
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              );
            },
          ),

          // 3. Botón de Acción Fijo
          Positioned(
            bottom: 30,
            left: 30,
            right: 30,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD48B41),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: Text(
                'Agendar Cita',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // 4. Botón Volver
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem('Rating', '4.9', Icons.star, Colors.orange),
        _buildStatItem('Exp.', '8 años', Icons.history, Colors.blue),
        _buildStatItem('Citas', '1.2k', Icons.check_circle, Colors.green),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 5),
        Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
