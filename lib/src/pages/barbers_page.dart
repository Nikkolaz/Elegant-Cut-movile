import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/carita_widget.dart';
import 'barber_detail_page.dart';

class BarbersPage extends StatefulWidget {
  const BarbersPage({super.key});

  @override
  State<BarbersPage> createState() => _BarbersPageState();
}

class _BarbersPageState extends State<BarbersPage>
    with TickerProviderStateMixin {
  int _selectedTab = 0; // 0 = Top Barberos, 1 = Nuevos
  String _selectedSpecialty = 'Todos';

  late AnimationController _staggerController;
  late AnimationController _headerController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  final List<String> _specialties = [
    'Todos',
    'Cortes',
    'Barba',
    'Color',
    'Facial',
  ];

  // ── Barberos Destacados ──
  final List<Map<String, dynamic>> _featuredBarbers = [
    {
      'name': 'Carlos Mendoza',
      'nickname': '"El Maestro"',
      'specialty': 'Cortes Clásicos & Degradados',
      'specialties': ['Cortes', 'Barba'],
      'rating': '4.9',
      'reviews': 312,
      'experience': '12 años',
      'availability': 'Disponible hoy',
      'price': 'Desde \$25',
      'color': const Color(0xFF98E68E),
      'expression': 3,
      'isAvailable': true,
    },
    {
      'name': 'Miguel Ángel R.',
      'nickname': '"The Artist"',
      'specialty': 'Diseños & Fade Art',
      'specialties': ['Cortes', 'Color'],
      'rating': '5.0',
      'reviews': 489,
      'experience': '8 años',
      'availability': 'Próximo: 2:00 PM',
      'price': 'Desde \$30',
      'color': const Color(0xFF88C9F9),
      'expression': 0,
      'isAvailable': true,
    },
    {
      'name': 'Sofía López',
      'nickname': '"La Experta"',
      'specialty': 'Coloración & Damas',
      'specialties': ['Color', 'Facial'],
      'rating': '4.8',
      'reviews': 267,
      'experience': '6 años',
      'availability': 'Disponible hoy',
      'price': 'Desde \$35',
      'color': const Color(0xFFFFB2D1),
      'expression': 1,
      'isAvailable': true,
    },
  ];

  // ── Todos los Barberos ──
  final List<Map<String, dynamic>> _allBarbers = [
    {
      'name': 'Carlos Mendoza',
      'specialty': 'Cortes Clásicos & Degradados',
      'specialties': ['Cortes', 'Barba'],
      'rating': 4.9,
      'reviews': 312,
      'experience': '12 años',
      'price': 'Desde \$25',
      'color': const Color(0xFF98E68E),
      'expression': 3,
      'isAvailable': true,
      'status': 'Disponible',
    },
    {
      'name': 'Miguel Ángel R.',
      'specialty': 'Diseños & Fade Art',
      'specialties': ['Cortes', 'Color'],
      'rating': 5.0,
      'reviews': 489,
      'experience': '8 años',
      'price': 'Desde \$30',
      'color': const Color(0xFF88C9F9),
      'expression': 0,
      'isAvailable': true,
      'status': 'Próx: 2:00 PM',
    },
    {
      'name': 'Andrés Ruiz',
      'specialty': 'Barba & Cuidado Facial',
      'specialties': ['Barba', 'Facial'],
      'rating': 4.7,
      'reviews': 198,
      'experience': '5 años',
      'price': 'Desde \$20',
      'color': const Color(0xFFFFD56B),
      'expression': 2,
      'isAvailable': true,
      'status': 'Disponible',
    },
    {
      'name': 'Sofía López',
      'specialty': 'Coloración & Damas',
      'specialties': ['Color', 'Facial'],
      'rating': 4.8,
      'reviews': 267,
      'experience': '6 años',
      'price': 'Desde \$35',
      'color': const Color(0xFFFFB2D1),
      'expression': 1,
      'isAvailable': true,
      'status': 'Disponible',
    },
    {
      'name': 'Diego Fernández',
      'specialty': 'Estilos Modernos & Tendencias',
      'specialties': ['Cortes'],
      'rating': 4.6,
      'reviews': 142,
      'experience': '3 años',
      'price': 'Desde \$20',
      'color': const Color(0xFFC7B8F5),
      'expression': 4,
      'isAvailable': false,
      'status': 'No disponible',
    },
    {
      'name': 'Ricardo Torres',
      'specialty': 'Afeitado Clásico & Hot Towel',
      'specialties': ['Barba'],
      'rating': 4.8,
      'reviews': 231,
      'experience': '10 años',
      'price': 'Desde \$15',
      'color': const Color(0xFFA8E6CF),
      'expression': 3,
      'isAvailable': true,
      'status': 'Disponible',
    },
  ];

  @override
  void initState() {
    super.initState();

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic),
    );

    _headerController.forward();
    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredBarbers {
    if (_selectedSpecialty == 'Todos') return _allBarbers;
    return _allBarbers
        .where((b) =>
            (b['specialties'] as List<String>).contains(_selectedSpecialty))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredBarbers;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _headerFade,
                child: SlideTransition(
                  position: _headerSlide,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nuestro Equipo',
                                  style: GoogleFonts.outfit(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : Colors.black,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Los mejores profesionales para ti',
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                            // Online count badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF50C878).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF50C878),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '5 activos',
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF50C878),
                                    ),
                                  ),
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

            // ── Toggle Tabs ──
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1A1A1C)
                        : Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      _buildToggleTab('Destacados', 0, isDark),
                      _buildToggleTab('Nuevos', 1, isDark),
                    ],
                  ),
                ),
              ),
            ),

            // ── Featured Barbers (Horizontal) ──
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _featuredBarbers.length,
                      itemBuilder: (context, index) {
                        return _AnimatedFeaturedCard(
                          barber: _featuredBarbers[index],
                          isDark: isDark,
                          index: index,
                          parentAnimation: _staggerController,
                          onTap: () => _navigateToDetail(
                              context, _featuredBarbers[index]),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),

            // ── Section Title ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Todos los Barberos',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      '${filtered.length} profesionales',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Specialty Filter Chips ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 5),
                child: SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _specialties.length,
                    itemBuilder: (context, index) {
                      final spec = _specialties[index];
                      final isSelected = _selectedSpecialty == spec;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedSpecialty = spec);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFD48B41)
                                  : (isDark
                                      ? const Color(0xFF1A1A1C)
                                      : Colors.white),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : (isDark
                                        ? Colors.white.withOpacity(0.06)
                                        : Colors.black.withOpacity(0.06)),
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFFD48B41)
                                            .withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Text(
                              spec,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? Colors.white.withOpacity(0.7)
                                        : Colors.black54),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 15)),

            // ── Barber List ──
            filtered.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No hay barberos en esta especialidad',
                              style: GoogleFonts.outfit(
                                color: Colors.grey.shade500,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final barber = filtered[index];
                        return _AnimatedBarberListItem(
                          barber: barber,
                          isDark: isDark,
                          index: index,
                          onTap: () =>
                              _navigateToDetail(context, barber),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(
      BuildContext context, Map<String, dynamic> barber) {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) {
          return BarberDetailPage(barber: barber);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved =
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Widget _buildToggleTab(String title, int index, bool isDark) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedTab = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFD48B41)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFFD48B41).withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════
// ANIMATED FEATURED CARD
// ══════════════════════════════════════════
class _AnimatedFeaturedCard extends StatefulWidget {
  final Map<String, dynamic> barber;
  final bool isDark;
  final int index;
  final AnimationController parentAnimation;
  final VoidCallback onTap;

  const _AnimatedFeaturedCard({
    required this.barber,
    required this.isDark,
    required this.index,
    required this.parentAnimation,
    required this.onTap,
  });

  @override
  State<_AnimatedFeaturedCard> createState() => _AnimatedFeaturedCardState();
}

class _AnimatedFeaturedCardState extends State<_AnimatedFeaturedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnim;
  late Animation<double> _entranceAnim;

  @override
  void initState() {
    super.initState();

    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );

    // Staggered entrance
    final start = (widget.index * 0.15).clamp(0.0, 0.6);
    final end = (start + 0.4).clamp(0.0, 1.0);
    _entranceAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.parentAnimation,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barber = widget.barber;
    final Color accentColor = barber['color'] as Color;

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnim, _entranceAnim]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _entranceAnim.value)),
          child: Opacity(
            opacity: _entranceAnim.value,
            child: Transform.scale(
              scale: _scaleAnim.value,
              child: child,
            ),
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => _hoverController.forward(),
        onTapUp: (_) {
          _hoverController.reverse();
          widget.onTap();
        },
        onTapCancel: () => _hoverController.reverse(),
        child: Container(
          width: 220,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF1A1A1C) : Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.1),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
              if (!widget.isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
            ],
          ),
          child: Column(
            children: [
              // Top - Avatar Section
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withOpacity(0.3),
                      accentColor.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: Stack(
                  children: [
                    // Avatar
                    Center(
                      child: Hero(
                        tag: 'barber_hero_${barber['name']}',
                        child: CaritaWidget(
                          size: 100,
                          color: accentColor,
                          expressionType: barber['expression'] as int,
                        ),
                      ),
                    ),
                    // Rating Badge
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFFD56B),
                              size: 14,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              barber['rating'] as String,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Availability dot
                    if (barber['isAvailable'] == true)
                      Positioned(
                        top: 14,
                        left: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF50C878),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Online',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Bottom - Info Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        barber['name'] as String,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          color: widget.isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        barber['specialty'] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      // Bottom row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Experience
                          Row(
                            children: [
                              Icon(
                                Icons.workspace_premium_rounded,
                                size: 14,
                                color: const Color(0xFFD48B41),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                barber['experience'] as String,
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: widget.isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          // Reviews
                          Text(
                            '${barber['reviews']} reseñas',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: Colors.grey.shade500,
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
      ),
    );
  }
}

// ══════════════════════════════════════════
// ANIMATED BARBER LIST ITEM
// ══════════════════════════════════════════
class _AnimatedBarberListItem extends StatefulWidget {
  final Map<String, dynamic> barber;
  final bool isDark;
  final int index;
  final VoidCallback onTap;

  const _AnimatedBarberListItem({
    required this.barber,
    required this.isDark,
    required this.index,
    required this.onTap,
  });

  @override
  State<_AnimatedBarberListItem> createState() =>
      _AnimatedBarberListItemState();
}

class _AnimatedBarberListItemState extends State<_AnimatedBarberListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.06, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    // Delayed start based on index
    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barber = widget.barber;
    final Color accentColor = barber['color'] as Color;
    final bool isAvailable = barber['isAvailable'] as bool;
    final double rating = barber['rating'] as double;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: child,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 6),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? const Color(0xFF1A1A1C)
                  : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: widget.isDark
                    ? Colors.white.withOpacity(0.04)
                    : Colors.black.withOpacity(0.03),
              ),
              boxShadow: [
                if (!widget.isDark)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Row(
              children: [
                // Avatar
                Stack(
                  children: [
                    Hero(
                      tag: 'barber_list_hero_${barber['name']}',
                      child: Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CaritaWidget(
                            size: 62,
                            color: accentColor,
                            expressionType: barber['expression'] as int,
                          ),
                        ),
                      ),
                    ),
                    // Online indicator
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? const Color(0xFF50C878)
                              : Colors.grey.shade400,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.isDark
                                ? const Color(0xFF1A1A1C)
                                : Colors.white,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              barber['name'] as String,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: widget.isDark
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (rating >= 4.9) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFD48B41),
                                    Color(0xFFE8A85C)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'TOP',
                                style: GoogleFonts.outfit(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        barber['specialty'] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Tags row
                      Row(
                        children: [
                          // Rating
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: widget.isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 13,
                                  color: Color(0xFFFFD56B),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '$rating',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: widget.isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Experience
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: widget.isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              barber['experience'] as String,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: widget.isDark
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Status
                          Text(
                            barber['status'] as String,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isAvailable
                                  ? const Color(0xFF50C878)
                                  : Colors.red.shade300,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Arrow
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: widget.isDark
                        ? Colors.white.withOpacity(0.4)
                        : Colors.black38,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
