import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/carita_widget.dart';
import '../api/services_api_service.dart';
import 'checkout_page.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  int _selectedCategory = 0;
  final List<Map<String, dynamic>> _selectedProducts = [];

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Todos', 'icon': Icons.grid_view_rounded},
    {'name': 'Cabello', 'icon': Icons.brush_rounded},
    {'name': 'Barba', 'icon': Icons.face_rounded},
    {'name': 'Accesorios', 'icon': Icons.watch_rounded},
  ];

  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final services = await ServicesApiService().getServices();
    if (mounted) {
      setState(() {
        _products = services;
        _isLoading = false;
      });
    }
  }

  void _toggleProduct(Map<String, dynamic> product) {
    setState(() {
      if (_selectedProducts.contains(product)) {
        _selectedProducts.remove(product);
      } else {
        _selectedProducts.add(product);
      }
    });
  }

  double _calculateTotal() {
    double total = 0;
    for (var p in _selectedProducts) {
      String priceStr = p['price'].toString().replaceAll(r'$', '');
      total += double.tryParse(priceStr) ?? 0;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredProducts = _selectedCategory == 0
        ? _products
        : _products.where((p) => p['category'] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFB28A), // Naranja pastel consistente
      body: Stack(
        children: [
          // --- 1. FONDO Y CABECERA ---
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
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tienda\nVirtual',
                        style: GoogleFonts.outfit(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E1E1E),
                          height: 1.1,
                          letterSpacing: -1.0,
                        ),
                      ),
                      Transform.rotate(
                        angle: 0.1,
                        child: const CaritaWidget(
                          size: 110,
                          color: Color(0xFFFFB2D1),
                          expressionType: 1, // Wink
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildInfoPill(
                        Icons.shopping_bag_rounded,
                        '${_products.length} Productos',
                        const Color(0xFF2C2C2E),
                        Colors.white,
                      ),
                      const SizedBox(width: 15),
                      _buildInfoPill(
                        Icons.local_shipping_rounded,
                        'Envíos',
                        Colors.white.withOpacity(0.3),
                        const Color(0xFF1E1E1E),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- 2. CONTENIDO DESLIZABLE ---
          DraggableScrollableSheet(
            initialChildSize: 0.60,
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
                  // bottom: 220 = barra carrito (85) + nav bar (80) + margen extra (55)
                  padding: const EdgeInsets.only(top: 25, bottom: 220),
                  child: Column(
                    children: [
                      // Categorías
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Row(
                          children: _categories.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final isSelected = _selectedCategory == idx;
                            return _AnimatedCategoryTab(
                              tab: entry.value,
                              isSelected: isSelected,
                              onTap: () =>
                                  setState(() => _selectedCategory = idx),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Productos
                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: CircularProgressIndicator(color: Color(0xFFD48B41)),
                          ),
                        )
                      else if (filteredProducts.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Text(
                              'Próximamente más productos',
                              style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16),
                            ),
                          ),
                        )
                      else
                        ...filteredProducts.map((product) {
                        final isSelected = _selectedProducts.contains(product);
                        return Padding(
                          padding: const EdgeInsets.only(
                            left: 25,
                            right: 25,
                            bottom: 20,
                          ),
                          child: _buildProductCard(product, isSelected),
                        );
                      }),
                    ].animate(interval: 50.ms).fade(duration: 400.ms, curve: Curves.easeOut).slideY(begin: 0.1, curve: Curves.easeOut),
                  ),
                ),
              );
            },
          ),

          // --- 3. BARRA DE CARRITO ---
          // Se posiciona 100px desde abajo: 80px de la BottomNavBar del IndexPage + 20px de margen visual
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            bottom: _selectedProducts.isNotEmpty ? 100 : -200,
            left: 20,
            right: 20,
            child: _buildCartBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPill(
    IconData icon,
    String text,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor.withOpacity(0.7), size: 16),
          const SizedBox(width: 10),
          Text(
            text,
            style: GoogleFonts.outfit(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleProduct(product),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: product['bgColor'],
          borderRadius: BorderRadius.circular(40),
          border: isSelected
              ? Border.all(color: Colors.white.withOpacity(0.5), width: 3)
              : Border.all(color: Colors.transparent, width: 3),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (product['bgColor'] as Color).withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
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
                    color: product['iconBgColor'],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    product['iconData'],
                    color: product['iconColor'],
                    size: 24,
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Colors.white
                          : (product['titleColor'] as Color).withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    isSelected
                        ? Icons.check_rounded
                        : Icons.add_shopping_cart_rounded,
                    color: isSelected ? Colors.black : product['titleColor'],
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              product['tagText'],
              style: GoogleFonts.outfit(
                color: product['tagColor'],
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product['title'],
              style: GoogleFonts.outfit(
                color: product['titleColor'],
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
                Text(
                  product['price'],
                  style: GoogleFonts.outfit(
                    color: product['titleColor'],
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                  ),
                ),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 500),
                  turns: isSelected ? 0.125 : 0,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSelected
                          ? Icons.shopping_cart_checkout_rounded
                          : Icons.arrow_forward_rounded,
                      color: isSelected
                          ? Colors.black87
                          : product['titleColor'],
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
                '${_selectedProducts.length} producto${_selectedProducts.length > 1 ? 's' : ''}',
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
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
                    products: _selectedProducts,
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
                  'Pagar ahora',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.credit_card_rounded, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedCategoryTab extends StatelessWidget {
  final Map<String, dynamic> tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedCategoryTab({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(
              tab['icon'],
              size: 18,
              color: isSelected ? Colors.black87 : Colors.grey.shade500,
            ),
            const SizedBox(width: 10),
            Text(
              tab['name'],
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.black87 : Colors.grey.shade500,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
