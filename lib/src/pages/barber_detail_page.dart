import 'package:flutter/material.dart';
import 'package:elegant_cut_mobile/src/widgets/service_card.dart';

class BarberDetailPage extends StatelessWidget {
  final Map<String, String> barber;

  const BarberDetailPage({super.key, required this.barber});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 1. Imagen de fondo
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.7,
            child: Hero(
              tag: 'barber_image_${barber['name']}',
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(barber['img']!),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. Información fija
          Positioned(
            top: size.height * 0.45,
            left: 25,
            right: 25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  barber['name']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Especialista en Estilo & Barba',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // 3. Panel interactivo
          DraggableScrollableSheet(
            initialChildSize: 0.42,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF121212) : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 5,
                    )
                  ],
                ),
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
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        children: [
                          Text(
                            'Experiencia',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            '${barber['name']} es un experto con más de 8 años en el arte de la barbería. '
                            'Especializado en técnicas modernas de degradado, corte clásico y diseño de barba '
                            'con navaja.',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            'Servicios Destacados',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 15),
                          const ServiceCard(
                            name: 'Corte de Cabello',
                            price: r'$25',
                            duration: '45 min',
                            icon: Icons.content_cut,
                            color: Colors.transparent,
                            isListMode: true,
                          ),
                          const ServiceCard(
                            name: 'Perfilado de Barba',
                            price: r'$15',
                            duration: '30 min',
                            icon: Icons.face,
                            color: Colors.transparent,
                            isListMode: true,
                          ),
                          const ServiceCard(
                            name: 'Tratamiento Capilar',
                            price: r'$20',
                            duration: '20 min',
                            icon: Icons.spa,
                            color: Colors.transparent,
                            isListMode: true,
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // 4. Botón de Agendar
          Positioned(
            bottom: 30,
            left: 25,
            right: 25,
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFFD48B41) : const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(20),
                  child: const Center(
                    child: Text(
                      'Agendar Cita',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 5. Botones Superiores
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildRoundButton(
                    context,
                    icon: Icons.arrow_back_ios_new,
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildRoundButton(
                    context,
                    icon: Icons.ios_share,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundButton(BuildContext context, {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
