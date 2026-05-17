import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoriteBarbersTab extends StatefulWidget {
  const FavoriteBarbersTab({super.key});
  @override
  State<FavoriteBarbersTab> createState() => _FavoriteBarbersTabState();
}

class _FavoriteBarbersTabState extends State<FavoriteBarbersTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<Map<String, dynamic>> _barbers = [
    {
      'name': 'Carlos Medina',
      'specialty': 'Fades & Degradados',
      'rating': 4.9,
      'cuts': 34,
      'color': const Color(0xFFD48B41),
      'initials': 'CM',
      'isFav': true,
    },
    {
      'name': 'Luis Ramírez',
      'specialty': 'Estilos Clásicos',
      'rating': 4.7,
      'cuts': 18,
      'color': const Color(0xFF88C9F9),
      'initials': 'LR',
      'isFav': true,
    },
    {
      'name': 'Miguel Ángel',
      'specialty': 'Barbas & Diseños',
      'rating': 4.8,
      'cuts': 12,
      'color': const Color(0xFF98E68E),
      'initials': 'MA',
      'isFav': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
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
      padding: const EdgeInsets.fromLTRB(25, 10, 25, 120),
      physics: const BouncingScrollPhysics(),
      itemCount: _barbers.length,
      itemBuilder: (context, i) {
        final b = _barbers[i];
        final anim = CurvedAnimation(
          parent: _controller,
          curve: Interval(i * 0.2, 1.0, curve: Curves.easeOutCubic),
        );
        return AnimatedBuilder(
          animation: anim,
          builder: (context, child) => Opacity(
            opacity: anim.value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - anim.value)),
              child: child,
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: (b['color'] as Color).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      b['initials'] as String,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: b['color'] as Color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b['name'] as String,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        b['specialty'] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 14, color: Color(0xFFD48B41)),
                          const SizedBox(width: 3),
                          Text(
                            '${b['rating']}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.content_cut,
                              size: 12, color: Colors.grey.shade400),
                          const SizedBox(width: 3),
                          Text(
                            '${b['cuts']} cortes contigo',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Fav toggle
                GestureDetector(
                  onTap: () => setState(() => b['isFav'] = !(b['isFav'] as bool)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (b['isFav'] as bool)
                          ? Colors.red.withOpacity(0.1)
                          : (isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade100),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      (b['isFav'] as bool)
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 20,
                      color: (b['isFav'] as bool)
                          ? Colors.red
                          : Colors.grey.shade400,
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
