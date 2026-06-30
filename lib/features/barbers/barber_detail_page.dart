import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../shared/widgets/barber_avatar.dart';
import '../../shared/widgets/cloudinary_image.dart';
import '../home/widgets/service_card.dart';
import '../booking/book_appointment_page.dart';

class BarberDetailPage extends StatelessWidget {
  final Map<String, dynamic> barber;

  const BarberDetailPage({super.key, required this.barber});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    final Color barberColor = barber['color'] ?? const Color(0xFF98E68E);
    final int expression = barber['expression'] ?? 0;
    final String? photoUrl = barber['photoUrl'];
    final List<dynamic> portfolioPhotos = barber['portfolioPhotos'] ?? [];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FB),
      body: Stack(
        children: [
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
                  child: BarberAvatar(
                    photoUrl: photoUrl,
                    size: 180,
                    caritaColor: barberColor,
                    expressionType: expression,
                    borderColor: const Color(0xFFD48B41),
                    borderWidth: 3,
                  ),
                ),
              ),
            ),
          ),

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
                      barber['specialty'] ?? 'Experto en Estilo & Barba',
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
                      barber['biography'] ?? 'Con más de 8 años de experiencia, me especializo en crear estilos únicos que resaltan tu personalidad. La precisión es mi firma.',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),

                    // --- Galería del portafolio ---
                    if (portfolioPhotos.isNotEmpty) ...[
                      const SizedBox(height: 30),
                      Text(
                        'Portafolio',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 160,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: portfolioPhotos.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: GestureDetector(
                                onTap: () => _showFullImage(context, portfolioPhotos[index].toString()),
                                child: CloudinaryImage(
                                  imageUrl: portfolioPhotos[index].toString(),
                                  width: 140,
                                  height: 160,
                                  shape: BoxShape.rectangle,
                                  borderRadius: 20,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],

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

          Positioned(
            bottom: 30,
            left: 30,
            right: 30,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookAppointmentPage(preselectedBarber: barber),
                  ),
                );
              },
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

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(color: Color(0xFFD48B41)),
              ),
              errorWidget: (context, url, error) => const Center(
                child: Icon(Icons.error_outline, color: Colors.white, size: 48),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStats(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem('Rating', '${barber['rating'] ?? 4.9}', Icons.star, Colors.orange),
        _buildStatItem('Exp.', barber['experience'] ?? '8 años', Icons.history, Colors.blue),
        _buildStatItem('Reseñas', '${barber['reviews'] ?? 0}', Icons.check_circle, Colors.green),
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
