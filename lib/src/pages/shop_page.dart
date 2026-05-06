import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  int? _expandedIndex;

  final List<Map<String, dynamic>> _services = [
    {
      'title': 'Corte Clásico',
      'subtitle': 'Tijera y máquina',
      'icon': Icons.content_cut_rounded,
      'color': const Color(0xFFFFB2D1),
      'description':
          'Un corte atemporal que nunca pasa de moda. Incluye lavado de cabello y peinado con productos premium.',
      'price': r'$25.00',
    },
    {
      'title': 'Perfilado de Barba',
      'subtitle': 'Navaja y toalla caliente',
      'icon': Icons.face_rounded,
      'color': const Color(0xFFFFD56B),
      'description':
          'Tratamiento completo para tu barba. Utilizamos toallas calientes y aceites esenciales para un acabado perfecto.',
      'price': r'$15.00',
    },
    {
      'title': 'Tratamiento Facial',
      'subtitle': 'Limpieza profunda',
      'icon': Icons.spa_rounded,
      'color': const Color(0xFF88C9F9),
      'description':
          'Relájate con una limpieza profunda que dejará tu piel renovada. Incluye exfoliación y mascarilla hidratante.',
      'price': r'$20.00',
    },
    {
      'title': 'Combo Premium',
      'subtitle': 'Corte + Barba + Facial',
      'icon': Icons.star_rounded,
      'color': const Color(0xFF98E68E),
      'description':
          'La experiencia completa de Elegant Cut. Ideal para quienes buscan un cambio total y un momento de relajación.',
      'price': r'$50.00',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF8F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(context, isDark),
              const SizedBox(height: 35),

              // Estadísticas rápidas (opcional, imitando la imagen)
              _buildQuickStats(isDark),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Servicios Disponibles',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    'Ver todos',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: const Color(0xFFD48B41),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _services.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  final service = _services[index];
                  final isExpanded = _expandedIndex == index;

                  return _buildServiceCard(index, service, isExpanded, isDark);
                },
              ),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
            ),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          'Tienda',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: const Color(0xFFD48B41),
            shape: BoxShape.circle,
            image: const DecorationImage(
              image: NetworkImage('https://i.pravatar.cc/150?u=barber'),
              fit: BoxFit.cover,
            ),
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(bool isDark) {
    return Row(
      children: [
        _buildStatItem('Estilo', 'Premium', isDark),
        const SizedBox(width: 15),
        _buildStatItem('Nivel', 'Gold', isDark),
        const SizedBox(width: 15),
        _buildStatItem('Puntos', '1.2k', isDark),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    int index,
    Map<String, dynamic> service,
    bool isExpanded,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedIndex = isExpanded ? null : index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: service['color'],
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            if (isExpanded)
              BoxShadow(
                color: (service['color'] as Color).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(service['icon'], color: Colors.black87, size: 24),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['title'],
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        service['subtitle'],
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: service['color'],
                    size: 16,
                  ),
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 20),
              Text(
                service['description'],
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: Colors.black87.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      service['price'],
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black87.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Reservar',
                          style: GoogleFonts.outfit(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const CircleAvatar(
                          radius: 12,
                          backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/100?u=marcus',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
