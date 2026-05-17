import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/carita_widget.dart';
import 'checkout_page.dart';

class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({super.key});

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  int _selectedTab = 0;
  final List<Map<String, dynamic>> _selectedServices = [];

  // Función para alternar selección
  void _toggleService(Map<String, dynamic> service) {
    setState(() {
      if (_selectedServices.contains(service)) {
        _selectedServices.remove(service);
      } else {
        _selectedServices.add(service);
      }
    });
  }

  double _calculateTotal() {
    double total = 0;
    for (var s in _selectedServices) {
      String priceStr = s['price'].toString().replaceAll('\$', '');
      total += double.tryParse(priceStr) ?? 0;
    }
    return total;
  }

  // secciones de los servicios uwu
  final List<Map<String, dynamic>> _tabsInfo = [
    {'name': 'Todos', 'icon': Icons.grid_view_rounded},
    {'name': 'Cortes', 'icon': Icons.content_cut_rounded},
    {'name': 'Barba', 'icon': Icons.face_retouching_natural_rounded},
    {'name': 'Facial', 'icon': Icons.spa_rounded},
    {'name': 'Damas', 'icon': Icons.face_3_rounded},
  ];

  final List<Map<String, dynamic>> _allServices = [
    {
      'category': 1, // Cortes
      'bgColor': const Color(0xFF2C2C2E),
      'tagText': 'ESTILO PREMIUM',
      'tagColor': const Color(0xFFD48B41),
      'title': 'Corte Clásico y Perfilado',
      'titleColor': Colors.white,
      'iconData': Icons.content_cut_rounded,
      'iconBgColor': Colors.white.withOpacity(0.1),
      'iconColor': const Color(0xFFD48B41),
      'price': '\$35',
    },
    {
      'category': 1, // Cortes
      'bgColor': const Color(0xFF88C9F9),
      'tagText': 'MODERNO',
      'tagColor': const Color(0xFF2C2C2E).withOpacity(0.6),
      'title': 'Degradado Fade y diseño',
      'titleColor': const Color(0xFF1E1E1E),
      'iconData': Icons.cut_rounded,
      'iconBgColor': Colors.white.withOpacity(0.4),
      'iconColor': const Color(0xFF1E1E1E),
      'price': '\$20',
    },
    {
      'category': 2, // Barba
      'bgColor': const Color(0xFFB4B0FE),
      'tagText': 'MANTENIMIENTO',
      'tagColor': const Color(0xFF2C2C2E).withOpacity(0.6),
      'title': 'Perfilado y toalla caliente',
      'titleColor': const Color(0xFF1E1E1E),
      'iconData': Icons.water_drop_outlined,
      'iconBgColor': Colors.white.withOpacity(0.3),
      'iconColor': const Color(0xFF1E1E1E),
      'price': '\$25',
    },
    {
      'category': 3, // Facial
      'bgColor': const Color(0xFFFFD56B),
      'tagText': 'RELAJACIÓN TOTAL',
      'tagColor': const Color(0xFF2C2C2E).withOpacity(0.6),
      'title': 'Limpieza facial profunda',
      'titleColor': const Color(0xFF1E1E1E),
      'iconData': Icons.face_retouching_natural_rounded,
      'iconBgColor': Colors.white.withOpacity(0.4),
      'iconColor': const Color(0xFF1E1E1E),
      'price': '\$15',
    },
    {
      'category': 4, // Damas
      'bgColor': const Color(0xFF98E68E),
      'tagText': 'CAMBIO DE LOOK',
      'tagColor': const Color(0xFF2C2C2E).withOpacity(0.6),
      'title': 'Corte de puntas y secado',
      'titleColor': const Color(0xFF1E1E1E),
      'iconData': Icons.face_3_rounded,
      'iconBgColor': Colors.white.withOpacity(0.4),
      'iconColor': const Color(0xFF1E1E1E),
      'price': '\$40',
    },
    {
      'category': 4, // Damas
      'bgColor': const Color(0xFFFFB2D1),
      'tagText': 'COLORACIÓN',
      'tagColor': const Color(0xFF2C2C2E).withOpacity(0.6),
      'title': 'Balayage e Iluminación',
      'titleColor': const Color(0xFF1E1E1E),
      'iconData': Icons.brush_rounded,
      'iconBgColor': Colors.white.withOpacity(0.4),
      'iconColor': const Color(0xFF1E1E1E),
      'price': '\$85',
    },
    {
      'category': 4, // Damas
      'bgColor': const Color(0xFFB4B0FE),
      'tagText': 'CUIDADO CAPILAR',
      'tagColor': const Color(0xFF2C2C2E).withOpacity(0.6),
      'title': 'Tratamiento de Keratina',
      'titleColor': const Color(0xFF1E1E1E),
      'iconData': Icons.waves_rounded,
      'iconBgColor': Colors.white.withOpacity(0.3),
      'iconColor': const Color(0xFF1E1E1E),
      'price': '\$120',
    },
  ];


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Si selectedTab es 0 ('Todos'), mostramos todos, sino filtramos
    final filteredServices = _selectedTab == 0
        ? _allServices
        : _allServices.where((s) => s['category'] == _selectedTab).toList();

    return Scaffold(
      backgroundColor: const Color(
        0xFFFFB28A,
      ), // Color naranja pastel similar a la imagen
      body: Stack(
        children: [
          // --- 1. FONDO Y CABECERA (Top Section) ---
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
                vertical: 10.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Botón de atrás
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black12, width: 1),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Título principal e Ilustración
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
                      // Ilustración (Usamos la carita amarilla como elemento gráfico decorativo grande)
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

                  // Píldoras de información
                  Row(
                    children: [
                      // Píldora Oscura
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF2C2C2E,
                          ), // Gris oscuro casi negro
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.menu_book_rounded,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '15 Servicios',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      // Píldora Clara
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3), // Translúcido
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.people_alt_rounded,
                              color: Color(0xFF1E1E1E),
                              size: 16,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '4 Expertos',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF1E1E1E),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
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

          // --- 2. CONTENIDO DESLIZABLE (Bottom Section) ---
          DraggableScrollableSheet(
            initialChildSize: 0.60, // Empieza a esta altura
            minChildSize: 0.60,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF121212)
                      : const Color(0xFFF8F9FB),
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
                      // Pestañas (Tabs)
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

                      // Tarjetas filtradas
                      ...filteredServices.map((service) {
                        final isSelected = _selectedServices.contains(service);
                        return Padding(
                          padding: const EdgeInsets.only(
                            left: 25,
                            right: 25,
                            bottom: 20,
                          ),
                          child: _buildServiceCard(
                            context: context,
                            service: service,
                            isSelected: isSelected,
                            onTap: () => _toggleService(service),
                          ),
                        );
                      }),

                      if (filteredServices.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Text(
                              'Próximamente más servicios',
                              style: GoogleFonts.outfit(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          // --- 3. BARRA DE CARRITO (Apple Style) ---
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
    final total = _calculateTotal();
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
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              Text(
                '\$$total',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
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
                    total: total,
                    isServiceBooking: true,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD48B41),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: Row(
              children: [
                Text(
                  'Continuar',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tarjeta de Servicio gigante y redondeada inspirada en la imagen
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila superior (Icono circular y Botón compartir)
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
                // Indicador de selección (Checkmark animado)
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
  
            // Textos centrales
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
  
            // Fila inferior (Avatares y Botón de precio)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Avatares superpuestos
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
                        style: GoogleFonts.outfit(
                          color: titleColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
  
                // Botón circular decorativo
                AnimatedRotation(
                  duration: const Duration(milliseconds: 500),
                  turns: isSelected ? 0.125 : 0, // Pequeño giro al seleccionar
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
        border: Border.all(
          color: Colors.white,
          width: 2,
        ), // Borde blanco para separar visualmente
      ),
      child: ClipOval(
        child: CaritaWidget(
          size: 40,
          color: color,
          expressionType: expressionType,
        ),
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
              // El ícono rota y rebota cuando está seleccionado
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
                tween: Tween(begin: 1.0, end: widget.isSelected ? 1.3 : 1.0),
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Transform.rotate(
                      angle: widget.isSelected
                          ? (scale - 1.0) * 0.5
                          : 0, // Pequeño giro al seleccionarse
                      child: Icon(
                        widget.tab['icon'],
                        size: 18,
                        color: widget.isSelected
                            ? Colors.black87
                            : Colors.grey.shade400,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              Text(
                widget.tab['name'],
                style: GoogleFonts.outfit(
                  color: widget.isSelected
                      ? Colors.black87
                      : Colors.grey.shade500,
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
