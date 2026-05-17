import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final double total;
  final bool isServiceBooking;

  const CheckoutPage({
    super.key,
    required this.products,
    required this.total,
    this.isServiceBooking = false,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> with SingleTickerProviderStateMixin {
  int _selectedPaymentMethod = 0;
  bool _isProcessing = false;

  late List<Map<String, dynamic>> _cartItems;
  late double _currentTotal;

  @override
  void initState() {
    super.initState();
    _cartItems = List<Map<String, dynamic>>.from(widget.products);
    _currentTotal = widget.total;
  }

  void _addSuggestion(Map<String, dynamic> item) {
    setState(() {
      _cartItems.add({
        'title': item['title'],
        'price': item['price'],
        'bgColor': item['bgColor'],
        'iconData': item['iconData'],
        'iconColor': item['iconColor'],
      });
      String priceStr = item['price'].toString().replaceAll('\$', '');
      _currentTotal += double.tryParse(priceStr) ?? 0;
    });
  }

  void _showAddMoreModal(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AddMoreModalContent(
          isDark: isDark,
          onAdd: (item) {
            _addSuggestion(item);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'name': 'Tarjeta de Crédito',
      'icon': Icons.credit_card_rounded,
      'color': const Color(0xFF1E1E1E),
      'textColor': Colors.white,
      'details': '**** **** **** 4242'
    },
    {
      'name': 'Apple Pay',
      'icon': Icons.apple_rounded,
      'color': Colors.black,
      'textColor': Colors.white,
      'details': 'Conectado'
    },
    {
      'name': 'Google Pay',
      'icon': Icons.g_mobiledata_rounded,
      'color': Colors.white,
      'textColor': Colors.black87,
      'details': 'Conectado'
    },
    {
      'name': 'PayPal',
      'icon': Icons.paypal_rounded,
      'color': const Color(0xFF0079C1),
      'textColor': Colors.white,
      'details': 'usuario@email.com'
    },
    {
      'name': 'Efectivo en el Local',
      'icon': Icons.payments_rounded,
      'color': const Color(0xFF50C878),
      'textColor': Colors.white,
      'details': 'Pagas al llegar'
    },
  ];

  int _selectedDeliveryMethod = 0;

  final List<Map<String, dynamic>> _deliveryMethods = [
    {
      'title': 'Recoger en Sucursal',
      'desc': 'Pasa por tus productos en nuestra barbería.',
      'icon': Icons.storefront_rounded,
    },
    {
      'title': 'Añadir a mi cita',
      'desc': 'Te entregaremos tus productos el día de tu cita.',
      'icon': Icons.calendar_today_rounded,
    },
  ];

  void _simulatePayment() {
    setState(() => _isProcessing = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isProcessing = false);

      _showSuccessDialog();
    });
  }

  void _showSuccessDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            color: const Color(0xFF1E1E1E),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        padding: const EdgeInsets.all(35),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD48B41).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(25),
                          decoration: const BoxDecoration(
                            color: Color(0xFFD48B41),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 70,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                Text(
                  '¡Muchas Gracias!',
                  style: GoogleFonts.outfit(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    widget.isServiceBooking 
                      ? 'Tu cita se ha reservado y pagado con éxito. Te esperamos en la barbería a la hora acordada.'
                      : (_selectedDeliveryMethod == 0
                          ? 'Tu pago se ha procesado con éxito. Tus productos te estarán esperando en la recepción de la barbería.'
                          : 'Tu pago se ha procesado con éxito. Te entregaremos tus productos el día de tu próxima cita.'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: Colors.grey.shade400,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Cierra diálogo
                    Navigator.pop(context); // Cierra checkout
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Volver al Inicio',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Checkout',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 130),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resumen de la Orden
                Text(
                  'Resumen de Orden',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                    ],
                  ),
                  child: Column(
                    children: _cartItems.map((p) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: p['bgColor'] ?? const Color(0xFF2C2C2E),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(
                                p['iconData'] ?? Icons.stars_rounded,
                                color: p['iconColor'] ?? Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p['title'] ?? '',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Cant: 1',
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              p['price'] ?? '',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 15),
                OutlinedButton.icon(
                  onPressed: () => _showAddMoreModal(context, isDark),
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                  label: Text(
                    'Añadir productos o servicios',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white : Colors.black87,
                    side: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                const SizedBox(height: 35),

                if (!widget.isServiceBooking) ...[
                  // Opciones de Retiro
                  Text(
                    'Método de Entrega',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: _deliveryMethods.asMap().entries.map((entry) {
                      int idx = entry.key;
                      var method = entry.value;
                      bool isSelected = _selectedDeliveryMethod == idx;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedDeliveryMethod = idx),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.only(right: idx == 0 ? 15 : 0),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFD48B41).withOpacity(0.1) : (isDark ? const Color(0xFF1C1C1E) : Colors.white),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: isSelected ? const Color(0xFFD48B41) : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  method['icon'],
                                  color: isSelected ? const Color(0xFFD48B41) : Colors.grey.shade500,
                                  size: 28,
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  method['title'],
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  method['desc'],
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 35),
                ],

                // Método de Pago
                Text(
                  'Método de Pago',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  children: _paymentMethods.asMap().entries.map((entry) {
                    int idx = entry.key;
                    var method = entry.value;
                    bool isSelected = _selectedPaymentMethod == idx;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedPaymentMethod = idx),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected ? method['color'] : (isDark ? const Color(0xFF1C1C1E) : Colors.white),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected ? Colors.transparent : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: (method['color'] as Color).withOpacity(0.4),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  )
                                ]
                              : [],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              method['icon'],
                              color: isSelected ? method['textColor'] : (isDark ? Colors.white : Colors.black87),
                              size: 28,
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    method['name'],
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isSelected ? method['textColor'] : (isDark ? Colors.white : Colors.black87),
                                    ),
                                  ),
                                  Text(
                                    method['details'],
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      color: isSelected ? (method['textColor'] as Color).withOpacity(0.7) : Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check_rounded,
                                  color: method['color'],
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Botón Inferior Fijo
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FB),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : Colors.grey.shade300).withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _simulatePayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD48B41),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Text(
                            'Pagar \$${_currentTotal.toStringAsFixed(2)}',
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddMoreModalContent extends StatefulWidget {
  final bool isDark;
  final Function(Map<String, dynamic>) onAdd;

  const _AddMoreModalContent({required this.isDark, required this.onAdd});

  @override
  State<_AddMoreModalContent> createState() => _AddMoreModalContentState();
}

class _AddMoreModalContentState extends State<_AddMoreModalContent> {
  int _selectedCategory = 0; // 0 = Productos, 1 = Servicios

  final List<Map<String, dynamic>> _productos = [
    {
      'title': 'Pomada Mate Premium',
      'price': '\$25',
      'bgColor': const Color(0xFF2C2C2E),
      'iconData': Icons.opacity_rounded,
      'iconColor': const Color(0xFFD48B41),
    },
    {
      'title': 'Aceite de Sándalo',
      'price': '\$18',
      'bgColor': const Color(0xFF88C9F9),
      'iconData': Icons.water_drop_rounded,
      'iconColor': const Color(0xFF1E1E1E),
    },
    {
      'title': 'Peine de Madera',
      'price': '\$12',
      'bgColor': const Color(0xFFFFB2D1),
      'iconData': Icons.brush_rounded,
      'iconColor': const Color(0xFF1E1E1E),
    },
  ];

  final List<Map<String, dynamic>> _servicios = [
    {
      'title': 'Corte Clásico',
      'price': '\$35',
      'bgColor': const Color(0xFFFFD56B),
      'iconData': Icons.content_cut_rounded,
      'iconColor': const Color(0xFF1E1E1E),
    },
    {
      'title': 'Mascarilla Facial',
      'price': '\$15',
      'bgColor': const Color(0xFF98E68E),
      'iconData': Icons.spa_rounded,
      'iconColor': const Color(0xFF1E1E1E),
    },
    {
      'title': 'Tinte / Coloración',
      'price': '\$85',
      'bgColor': const Color(0xFFB4B0FE),
      'iconData': Icons.color_lens_rounded,
      'iconColor': const Color(0xFF1E1E1E),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final items = _selectedCategory == 0 ? _productos : _servicios;

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 25),
          Text(
            '¿Qué te gustaría añadir?',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: widget.isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildCategoryTab('Productos', 0),
              const SizedBox(width: 15),
              _buildCategoryTab('Servicios', 1),
            ],
          ),
          const SizedBox(height: 25),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return GestureDetector(
                  onTap: () => widget.onAdd(item),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: widget.isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: widget.isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: item['bgColor'],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(item['iconData'], color: item['iconColor'], size: 24),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'],
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: widget.isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '+ ${item['price']}',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: const Color(0xFFD48B41),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD48B41).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add_rounded, color: Color(0xFFD48B41), size: 20),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(String title, int index) {
    bool isSelected = _selectedCategory == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD48B41) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFFD48B41) : Colors.grey.shade300,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isSelected 
                  ? Colors.white 
                  : (widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
          ),
        ),
      ),
    );
  }
}
