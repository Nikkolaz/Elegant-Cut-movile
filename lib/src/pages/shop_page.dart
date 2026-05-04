import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  String? _expandedId;

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Cortes de Cabello',
      'services': [
        {
          'id': 'c1',
          'title': 'Corte Clásico',
          'subtitle': 'Tijera y máquina',
          'icon': Icons.content_cut_rounded,
          'color': const Color(0xFFFFB2D1),
          'description': 'Un corte atemporal que nunca pasa de moda. Incluye lavado de cabello y peinado con productos premium.',
          'price': r'$25.00',
        },
        {
          'id': 'c2',
          'title': 'Fade Moderno',
          'subtitle': 'Degradado perfecto',
          'icon': Icons.trending_up_rounded,
          'color': const Color(0xFFFFD56B),
          'description': 'El estilo más popular hoy en día. Un degradado limpio en los laterales con volumen arriba.',
          'price': r'$30.00',
        },
      ]
    },
    {
      'name': 'Cuidado de Barba',
      'services': [
        {
          'id': 'b1',
          'title': 'Perfilado Navaja',
          'subtitle': 'Toalla caliente',
          'icon': Icons.face_rounded,
          'color': const Color(0xFF88C9F9),
          'description': 'Tratamiento completo para tu barba. Utilizamos toallas calientes y aceites esenciales.',
          'price': r'$15.00',
        },
        {
          'id': 'b2',
          'title': 'Barba Completa',
          'subtitle': 'Recorte y forma',
          'icon': Icons.brush_rounded,
          'color': const Color(0xFF98E68E),
          'description': 'Dale la forma ideal a tu barba. Incluye hidratación y peinado con bálsamo.',
          'price': r'$20.00',
        },
      ]
    },
    {
      'name': 'Tratamientos',
      'services': [
        {
          'id': 't1',
          'title': 'Facial Express',
          'subtitle': 'Limpieza rápida',
          'icon': Icons.spa_rounded,
          'color': const Color(0xFFC7B8EA),
          'description': 'Ideal para después de un corte. Limpieza profunda y mascarilla refrescante.',
          'price': r'$18.00',
        },
        {
          'id': 't2',
          'title': 'Masaje Capilar',
          'subtitle': 'Relajación total',
          'icon': Icons.self_improvement_rounded,
          'color': const Color(0xFFF9A8D4),
          'description': '15 minutos de masaje relajante con aceites esenciales durante el lavado.',
          'price': r'$12.00',
        },
      ]
    }
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FB),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth - 50;
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(context, isDark),
                  const SizedBox(height: 35),
                  _buildQuickStats(isDark, availableWidth),
                  const SizedBox(height: 40),
                  
                  ..._categories.map((cat) => _buildCategorySection(cat, isDark)),
                  
                  const SizedBox(height: 120),
                ],
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 45), 

        Text(
          'Servicios',
          style: GoogleFonts.outfit(
            fontSize: 22,
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

  Widget _buildQuickStats(bool isDark, double width) {
    final itemWidth = (width - 30) / 3;
    return Row(
      children: [
        _buildStatItem('Estilo', 'Premium', isDark, itemWidth),
        const SizedBox(width: 15),
        _buildStatItem('Nivel', 'Gold', isDark, itemWidth),
        const SizedBox(width: 15),
        _buildStatItem('Puntos', '1.2k', isDark, itemWidth),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, bool isDark, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.grey.shade900 : Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey), maxLines: 1),
          const SizedBox(height: 5),
          Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black), maxLines: 1),
        ],
      ),
    );
  }

  Widget _buildCategorySection(Map<String, dynamic> category, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20, top: 10),
          child: Text(
            category['name'],
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
        ...category['services'].map<Widget>((service) => Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: _buildServiceCard(service, isDark),
        )).toList(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service, bool isDark) {
    final bool isExpanded = _expandedId == service['id'];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedId = isExpanded ? null : service['id'];
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastLinearToSlowEaseIn,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: service['color'],
          borderRadius: BorderRadius.circular(isExpanded ? 35 : 25),
          boxShadow: [
            if (isExpanded)
              BoxShadow(
                color: (service['color'] as Color).withOpacity(0.3),
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
                AnimatedRotation(
                  duration: const Duration(milliseconds: 300),
                  turns: isExpanded ? 0.5 : 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: service['color'],
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            
            AnimatedSize(
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastLinearToSlowEaseIn,
              child: ConstrainedBox(
                constraints: isExpanded 
                    ? const BoxConstraints() 
                    : const BoxConstraints(maxHeight: 0),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: isExpanded ? 1 : 0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service['description'],
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              service['price'],
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Reservar',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
