import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../shared/widgets/carita_widget.dart';
import '../../state/booking/booking_provider.dart';
import 'checkout_page.dart';

class BookAppointmentPage extends StatefulWidget {
  final Map<String, dynamic>? preselectedBarber;
  const BookAppointmentPage({super.key, this.preselectedBarber});

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  int _selectedTab = 0;
  final List<Map<String, dynamic>> _selectedServices = [];

  void _toggleService(Map<String, dynamic> service) {
    setState(() {
      if (_selectedServices.contains(service)) {
        _selectedServices.remove(service);
      } else {
        _selectedServices.add(service);
      }
    });
  }

  final List<Map<String, dynamic>> _tabsInfo = [
    {'name': 'Todos', 'icon': Icons.grid_view_rounded},
    {'name': 'Cortes', 'icon': Icons.content_cut_rounded},
    {'name': 'Barba', 'icon': Icons.face_retouching_natural_rounded},
    {'name': 'Facial', 'icon': Icons.spa_rounded},
    {'name': 'Damas', 'icon': Icons.face_3_rounded},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final provider = context.watch<BookingProvider>();
    final allServices = provider.services;
    final barbersCount = provider.barbers.length;
    final filteredServices = _selectedTab == 0
        ? allServices
        : allServices.where((s) {
            final tabName = _tabsInfo[_selectedTab]['name'].toString().toLowerCase();
            if (tabName == 'damas') {
              return s['gender_id'] == 2;
            } else if (tabName == 'cortes') {
              return s['category'].toString().toLowerCase().contains('cabello') || 
                     s['category'].toString().toLowerCase().contains('corte');
            }
            return s['category'].toString().toLowerCase().contains(tabName);
          }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFB28A),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black12, width: 1),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Agendar\ncita',
                        style: GoogleFonts.outfit(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E1E1E),
                          height: 1.1,
                          letterSpacing: -1.0,
                        ),
                      ),
                      Transform.rotate(
                        angle: -0.2,
                        child: CaritaWidget(
                          size: 110,
                          color: const Color(0xFF88C9F9),
                          expressionType: 3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2E),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.menu_book_rounded, color: Colors.white70, size: 16),
                            const SizedBox(width: 10),
                            Text(
                              '\$${allServices.length} Servicios',
                              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.people_alt_rounded, color: Color(0xFF1E1E1E), size: 16),
                            const SizedBox(width: 10),
                            Text(
                              '$barbersCount Expertos',
                              style: GoogleFonts.outfit(color: const Color(0xFF1E1E1E), fontWeight: FontWeight.bold, fontSize: 14),
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

          DraggableScrollableSheet(
            initialChildSize: 0.60,
            minChildSize: 0.60,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FB),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(top: 25, bottom: 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Row(
                          children: _tabsInfo.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final tab = entry.value;
                            final isSelected = _selectedTab == idx;
                            return _AnimatedTab(
                              tab: tab,
                              isSelected: isSelected,
                              onTap: () => setState(() => _selectedTab = idx),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 25),

                      if (provider.isLoading)
                        const Center(child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(color: Color(0xFFD48B41)),
                        ))
                      else
                        ...filteredServices.map((service) {
                          final isSelected = _selectedServices.contains(service);
                          return Padding(
                            padding: const EdgeInsets.only(left: 25, right: 25, bottom: 20),
                            child: _buildServiceCard(
                              context: context,
                              service: service,
                              isSelected: isSelected,
                              onTap: () => _toggleService(service),
                            ),
                          );
                        }),

                      if (!provider.isLoading && filteredServices.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Text(
                              'Próximamente más servicios',
                              style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            bottom: _selectedServices.isNotEmpty ? 50 : -120,
            left: 20,
            right: 20,
            child: _buildCartBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildCartBar() {
    final total = context.read<BookingProvider>().total;
    return Container(
      height: 85,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_selectedServices.length} servicio${_selectedServices.length > 1 ? 's' : ''}',
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
              ),
              Text(
                '\$$total',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CheckoutPage(
                    products: _selectedServices,
                    total: context.read<BookingProvider>().total,
                    isServiceBooking: true,
                    preSelectedBarberName: widget.preselectedBarber?['name'],
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD48B41),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: Row(
              children: [
                Text('Continuar', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required Map<String, dynamic> service,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final bgColor = service['bgColor'] as Color;
    final titleColor = service['titleColor'] as Color;
    final price = service['price'] as String;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(40),
          border: isSelected
            ? Border.all(color: Colors.white.withOpacity(0.5), width: 3)
            : Border.all(color: Colors.transparent, width: 3),
          boxShadow: isSelected
            ? [BoxShadow(color: bgColor.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))]
            : [],
          image: (service['imageUrl'] != null && (service['imageUrl'] as String).isNotEmpty)
              ? DecorationImage(
                  image: CachedNetworkImageProvider(service['imageUrl']),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.45),
                    BlendMode.darken,
                  ),
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: service['iconBgColor'],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(service['iconData'], color: service['iconColor'], size: 24),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : titleColor.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    isSelected ? Icons.check_rounded : Icons.add_rounded,
                    color: isSelected ? Colors.black : titleColor,
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text(
              service['tagText'],
              style: GoogleFonts.outfit(
                color: service['tagColor'],
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              service['title'],
              style: GoogleFonts.outfit(
                color: titleColor,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    _buildStackedAvatar(const Color(0xFFFFB2D1), 1),
                    Transform.translate(
                      offset: const Offset(-15, 0),
                      child: _buildStackedAvatar(const Color(0xFF98E68E), 0),
                    ),
                    Transform.translate(
                      offset: const Offset(-30, 0),
                      child: _buildStackedAvatar(const Color(0xFFFFD56B), 2),
                    ),
                    Transform.translate(
                      offset: const Offset(-20, 0),
                      child: Text(
                        '+ $price',
                        style: GoogleFonts.outfit(color: titleColor, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),

                AnimatedRotation(
                  duration: const Duration(milliseconds: 500),
                  turns: isSelected ? 0.125 : 0,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      isSelected ? Icons.shopping_bag_rounded : Icons.arrow_forward_rounded,
                      color: isSelected ? Colors.black87 : titleColor,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStackedAvatar(Color color, int expressionType) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipOval(
        child: CaritaWidget(size: 40, color: color, expressionType: expressionType),
      ),
    );
  }
}

class _AnimatedTab extends StatefulWidget {
  final Map<String, dynamic> tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedTab({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_AnimatedTab> createState() => _AnimatedTabState();
}

class _AnimatedTabState extends State<_AnimatedTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.90,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(right: 15),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
                tween: Tween(begin: 1.0, end: widget.isSelected ? 1.3 : 1.0),
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Transform.rotate(
                      angle: widget.isSelected ? (scale - 1.0) * 0.5 : 0,
                      child: Icon(
                        widget.tab['icon'],
                        size: 18,
                        color: widget.isSelected ? Colors.black87 : Colors.grey.shade400,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              Text(
                widget.tab['name'],
                style: GoogleFonts.outfit(
                  color: widget.isSelected ? Colors.black87 : Colors.grey.shade500,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
