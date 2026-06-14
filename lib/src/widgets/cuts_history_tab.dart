import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CutsHistoryTab extends StatefulWidget {
  const CutsHistoryTab({super.key});
  @override
  State<CutsHistoryTab> createState() => _CutsHistoryTabState();
}

class _CutsHistoryTabState extends State<CutsHistoryTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<Map<String, dynamic>> _cuts = [
    {
      'style': 'Fade + Degradado',
      'barber': 'Carlos M.',
      'date': 'Hace 3 días',
      'price': r'$25',
      'rating': 5,
      'color': const Color(0xFFD48B41),
      'icon': Icons.content_cut,
    },
    {
      'style': 'Pompadour Clásico',
      'barber': 'Luis R.',
      'date': 'Hace 2 semanas',
      'price': r'$30',
      'rating': 4,
      'color': const Color(0xFF88C9F9),
      'icon': Icons.face_retouching_natural,
    },
    {
      'style': 'Undercut Texturizado',
      'barber': 'Miguel A.',
      'date': 'Hace 1 mes',
      'price': r'$28',
      'rating': 5,
      'color': const Color(0xFF98E68E),
      'icon': Icons.auto_awesome,
    },
    {
      'style': 'Corte Clásico',
      'barber': 'Carlos M.',
      'date': 'Hace 2 meses',
      'price': r'$20',
      'rating': 4,
      'color': const Color(0xFFB4B0FE),
      'icon': Icons.content_cut,
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 120),
      physics: const BouncingScrollPhysics(),
      itemCount: _cuts.length,
      itemBuilder: (context, i) {
        final cut = _cuts[i];
        final anim = CurvedAnimation(
          parent: _controller,
          curve: Interval(i * 0.15, 1.0, curve: Curves.easeOutCubic),
        );
        return AnimatedBuilder(
          animation: anim,
          builder: (context, child) => Opacity(
            opacity: anim.value,
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - anim.value)),
              child: child,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 25, right: 25),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Línea de tiempo
                Column(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: (cut['color'] as Color).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(cut['icon'] as IconData,
                          color: cut['color'] as Color, size: 20),
                    ),
                    if (i < _cuts.length - 1)
                      Container(
                        width: 2,
                        height: 60,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              (cut['color'] as Color).withOpacity(0.4),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 15),
                // Card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E1E1E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              cut['style'] as String,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            Text(
                              cut['price'] as String,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: cut['color'] as Color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cut['barber'] as String,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: List.generate(
                                5,
                                (s) => Icon(
                                  s < (cut['rating'] as int)
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  size: 14,
                                  color: const Color(0xFFD48B41),
                                ),
                              ),
                            ),
                            Text(
                              cut['date'] as String,
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
