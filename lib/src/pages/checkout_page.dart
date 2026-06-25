import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../api/booking_api_service.dart';
import '../api/barber_api_service.dart';
import '../widgets/custom_toast.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final double total;
  final bool isServiceBooking;
  final String? preSelectedBarberName;

  const CheckoutPage({
    super.key,
    required this.products,
    required this.total,
    this.isServiceBooking = false,
    this.preSelectedBarberName,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage>
    with TickerProviderStateMixin {
  // ── State ──
  int _currentStep = 0; // 0=Resumen, 1=Agendar, 2=Confirmar
  bool _isProcessing = false;

  late List<Map<String, dynamic>> _cartItems;
  late double _currentTotal;

  // Scheduling state
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  int _selectedTimeSlot = -1;
  int _selectedBarber = -1;
  final TextEditingController _notesController = TextEditingController();

  // Animations
  late AnimationController _stepAnimController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  late AnimationController _progressController;

  // ── Data ──
  List<Map<String, dynamic>> _timeSlots = [];
  bool _isLoadingSlots = false;

  List<Map<String, dynamic>> _barbers = [];
  bool _isLoadingBarbers = true;

  final List<String> _stepTitles = [
    'Tu Orden',
    'Agenda tu Cita',
    'Confirmar Reserva',
  ];

  @override
  void initState() {
    super.initState();
    _cartItems = List<Map<String, dynamic>>.from(widget.products);
    _currentTotal = widget.total;

    _loadBarbers();

    _stepAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _stepAnimController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.08, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _stepAnimController, curve: Curves.easeOutCubic),
    );
    _stepAnimController.forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      value: 0.333,
    );
  }

  @override
  void dispose() {
    _stepAnimController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    if (step < 0 || step > 2) return;
    _stepAnimController.reset();
    setState(() => _currentStep = step);
    _progressController.animateTo(
      (step + 1) / 3,
      curve: Curves.easeOutCubic,
    );
    _stepAnimController.forward();
  }

  Future<void> _loadBarbers() async {
    final barbers = await BarberApiService().getBarbers();
    
    // Assign colors and emojis based on index
    final colorHex = [0xFF98E68E, 0xFFFFB2D1, 0xFF88C9F9, 0xFFFFD56B];
    final emojis = ['💈', '✂️', '🧔', '💇‍♀️'];
    
    for (int i = 0; i < barbers.length; i++) {
      barbers[i]['color'] = Color(colorHex[i % colorHex.length]);
      barbers[i]['emoji'] = emojis[i % emojis.length];
      barbers[i]['specialty'] = (barbers[i]['specialties'] as List?)?.join(', ') ?? 'Barbero';
    }

    if (mounted) {
      setState(() {
        _barbers = barbers;
        _isLoadingBarbers = false;
        
        if (widget.preSelectedBarberName != null) {
          for (int i = 0; i < _barbers.length; i++) {
            if ((_barbers[i]['name'] as String)
                .toLowerCase()
                .contains(widget.preSelectedBarberName!.toLowerCase().split(' ').first)) {
              _selectedBarber = i;
              break;
            }
          }
        }
      });
      _fetchSlots();
    }
  }

  Future<void> _fetchSlots() async {
    if (_selectedBarber < 0 || _barbers.isEmpty) {
      print('DEBUG _fetchSlots: Skipping - selectedBarber=$_selectedBarber, barbers=${_barbers.length}');
      return;
    }
    setState(() {
      _isLoadingSlots = true;
      _timeSlots = [];
      _selectedTimeSlot = -1;
    });
    
    try {
      final barberId = _barbers[_selectedBarber]['id'];
      print('DEBUG _fetchSlots: barberId=$barberId (type=${barberId.runtimeType}), date=$_selectedDate');
      final slots = await BookingApiService().getAvailableSlots(_selectedDate, barberId is int ? barberId : int.parse(barberId.toString()));
      print('DEBUG _fetchSlots: Got ${slots.length} slots');
      
      if (mounted) {
        setState(() {
          _timeSlots = slots;
          _isLoadingSlots = false;
        });
      }
    } catch (e) {
      print('DEBUG _fetchSlots ERROR: $e');
      if (mounted) {
        setState(() {
          _isLoadingSlots = false;
        });
      }
    }
  }

  bool get _canProceedFromStep0 => _cartItems.isNotEmpty;
  bool get _canProceedFromStep1 =>
      _selectedTimeSlot >= 0 && _selectedBarber >= 0;

  Future<void> _processBooking() async {
    HapticFeedback.heavyImpact();
    setState(() => _isProcessing = true);

    if (widget.isServiceBooking) {
      final success = await BookingApiService().createAppointment(
        barberId: _barbers[_selectedBarber]['id'],
        serviceIds: _cartItems.map((s) => s['id'] as int? ?? 1).toList(),
        date: _selectedDate,
        idHorario: _timeSlots[_selectedTimeSlot]['id'],
        observaciones: _notesController.text,
      );

      if (!mounted) return;
      setState(() => _isProcessing = false);

      if (success) {
        _showSuccessScreen();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al procesar la reserva, intenta de nuevo.'), backgroundColor: Colors.red),
        );
      }
    } else {
      // Simular compra de productos de tienda
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showSuccessScreen();
    }
  }

  // ══════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            _buildHeader(isDark),
            // ── Progress Bar ──
            _buildProgressBar(isDark),
            // ── Content ──
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: _buildCurrentStep(isDark),
                ),
              ),
            ),
            // ── Bottom CTA ──
            _buildBottomBar(isDark),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════
  // HEADER
  // ══════════════════════════════════════════
  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_currentStep > 0) {
                _goToStep(_currentStep - 1);
              } else {
                Navigator.pop(context);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.black.withOpacity(0.04),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paso ${_currentStep + 1} de 3',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFD48B41),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _stepTitles[_currentStep],
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          // Step Indicator Circles
          Row(
            children: List.generate(3, (i) {
              final isActive = i == _currentStep;
              final isDone = i < _currentStep;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.only(left: 6),
                width: isActive ? 32 : 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isDone
                      ? const Color(0xFFD48B41)
                      : isActive
                          ? const Color(0xFFD48B41)
                          : (isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.08)),
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // PROGRESS BAR
  // ══════════════════════════════════════════
  Widget _buildProgressBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: AnimatedBuilder(
        animation: _progressController,
        builder: (context, child) {
          return Container(
            height: 4,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _progressController.value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD48B41), Color(0xFFE8A85C)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD48B41).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentStep(bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildStep0OrderSummary(isDark);
      case 1:
        return _buildStep1Schedule(isDark);
      case 2:
        return _buildStep2Confirm(isDark);
      default:
        return const SizedBox();
    }
  }

  // ══════════════════════════════════════════
  // STEP 0: ORDER SUMMARY
  // ══════════════════════════════════════════
  Widget _buildStep0OrderSummary(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(25, 25, 25, 20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Empty state when no services yet
          if (_cartItems.isEmpty) ...[
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.9 + 0.1 * value,
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A1C) : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFFD48B41).withOpacity(0.15),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD48B41).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.content_cut_rounded,
                        color: Color(0xFFD48B41),
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '¿Qué servicio deseas?',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Añade los servicios que quieres para tu cita',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () => _showAddMoreModal(context, isDark),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD48B41),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD48B41).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Añadir Servicios',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
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
            ),
          ],

          // Services List (when items exist)
          if (_cartItems.isNotEmpty) ...[
            ...List.generate(_cartItems.length, (index) {
              final item = _cartItems[index];
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 400 + index * 100),
                curve: Curves.easeOutCubic,
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1A1C) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.04),
                    ),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: item['bgColor'] ?? const Color(0xFF2C2C2E),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          item['iconData'] ?? Icons.stars_rounded,
                          color: item['iconColor'] ?? Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'] ?? '',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD48B41).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Servicio',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFD48B41),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 13,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '30 min',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item['price'] ?? '',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 10),
          ],

          // Add more button (only when cart has items)
          if (_cartItems.isNotEmpty)
            GestureDetector(
              onTap: () => _showAddMoreModal(context, isDark),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.08),
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline_rounded,
                      color: const Color(0xFFD48B41),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Añadir más servicios',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: const Color(0xFFD48B41),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (_cartItems.isNotEmpty)
            const SizedBox(height: 30),

          // Payment Method - Cash Only (only when cart has items)
          if (_cartItems.isNotEmpty) ...[
          _buildSectionTitle('Método de Pago', isDark),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF50C878).withOpacity(0.12),
                  const Color(0xFF50C878).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF50C878).withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF50C878),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF50C878).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.payments_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Efectivo en el Local',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pagas al llegar a la barbería',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF50C878),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Pricing Breakdown
          _buildSectionTitle('Desglose', isDark),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1C) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.04),
              ),
            ),
            child: Column(
              children: [
                _buildPriceRow('Subtotal', '\$${_currentTotal.toStringAsFixed(2)}', isDark),
                const SizedBox(height: 12),
                _buildPriceRow('Descuento', '-\$0.00', isDark,
                    valueColor: const Color(0xFF50C878)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total a Pagar',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFD48B41), Color(0xFFE8A85C)],
                      ).createShader(bounds),
                      child: Text(
                        '\$${_currentTotal.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w900,
                          fontSize: 26,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ], // end if (_cartItems.isNotEmpty)
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // STEP 1: SCHEDULE
  // ══════════════════════════════════════════
  Widget _buildStep1Schedule(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(25, 25, 25, 20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Date Picker ──
          _buildSectionTitle('Selecciona el Día', isDark),
          const SizedBox(height: 15),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: 14,
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index + 1));
                final isSelected = _selectedDate.day == date.day &&
                    _selectedDate.month == date.month;
                final dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
                final monthNames = [
                  '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
                  'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
                ];

                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 300 + index * 50),
                  curve: Curves.easeOutCubic,
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 15 * (1 - value)),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedDate = date;
                      });
                      _fetchSlots();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      width: 72,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFD48B41)
                            : (isDark ? const Color(0xFF1A1A1C) : Colors.white),
                        borderRadius: BorderRadius.circular(22),
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
                                  color: const Color(0xFFD48B41).withOpacity(0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dayNames[date.weekday - 1],
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white.withOpacity(0.8)
                                  : Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${date.day}',
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white : Colors.black87),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            monthNames[date.month],
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 30),

          // ── Time Slots ──
          _buildSectionTitle('Hora Disponible', isDark),
          const SizedBox(height: 15),
          if (_isLoadingSlots)
            const Center(child: CircularProgressIndicator(color: Color(0xFFD48B41)))
          else if (_timeSlots.isEmpty)
            Text('Selecciona un barbero para ver horarios', style: GoogleFonts.outfit(color: Colors.grey))
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(_timeSlots.length, (index) {
                final isSelected = _selectedTimeSlot == index;
                final isUnavailable = !_timeSlots[index]['isAvailable'];

                return GestureDetector(
                  onTap: isUnavailable
                      ? null
                      : () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedTimeSlot = index);
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isUnavailable
                          ? (isDark
                              ? Colors.white.withOpacity(0.02)
                              : Colors.grey.shade100)
                          : isSelected
                              ? const Color(0xFFD48B41)
                              : (isDark
                                  ? const Color(0xFF1A1A1C)
                                  : Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isUnavailable
                            ? Colors.transparent
                            : isSelected
                                ? Colors.transparent
                                : (isDark
                                    ? Colors.white.withOpacity(0.06)
                                    : Colors.black.withOpacity(0.06)),
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFFD48B41).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      _timeSlots[index]['time'],
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isUnavailable
                            ? Colors.grey.shade400
                            : isSelected
                                ? Colors.white
                                : (isDark
                                    ? Colors.white.withOpacity(0.8)
                                    : Colors.black87),
                        decoration: isUnavailable
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                );
            }),
          ),

          const SizedBox(height: 30),

          // ── Barber Selection ──
          _buildSectionTitle('Elige tu Barbero', isDark),
          const SizedBox(height: 15),
          if (_isLoadingBarbers)
            const Center(child: CircularProgressIndicator(color: Color(0xFFD48B41)))
          else if (_barbers.isEmpty)
            Text('No hay barberos disponibles', style: GoogleFonts.outfit(color: Colors.grey))
          else
            ...List.generate(_barbers.length, (index) {
            final barber = _barbers[index];
            final isSelected = _selectedBarber == index;

            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 400 + index * 100),
              curve: Curves.easeOutCubic,
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(20 * (1 - value), 0),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedBarber = index);
                  _fetchSlots();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (barber['color'] as Color).withOpacity(0.12)
                        : (isDark ? const Color(0xFF1A1A1C) : Colors.white),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isSelected
                          ? (barber['color'] as Color).withOpacity(0.5)
                          : (isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.04)),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (barber['color'] as Color).withOpacity(0.15),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: barber['color'],
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Text(
                            barber['emoji'],
                            style: const TextStyle(fontSize: 26),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              barber['name'],
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              barber['specialty'],
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Rating
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.06)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: Color(0xFFFFD56B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${barber['rating']}',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: barber['color'],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 25),

          // ── Notes ──
          _buildSectionTitle('Notas para tu Barbero', isDark, isOptional: true),
          const SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1C) : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.04),
              ),
            ),
            child: TextField(
              controller: _notesController,
              maxLines: 3,
              style: GoogleFonts.outfit(
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText:
                    'Ej: Quiero el degradado alto, conservar largo arriba...',
                hintStyle: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // STEP 2: CONFIRMATION
  // ══════════════════════════════════════════
  Widget _buildStep2Confirm(bool isDark) {
    final dayNames = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    final monthNames = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Main Confirmation Card ──
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.9 + 0.1 * value,
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1E1E1E),
                    const Color(0xFF2A2520),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD48B41).withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Gold accent line
                  Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD48B41), Color(0xFFE8A85C)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    'Resumen de tu Cita',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Date & Time Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildConfirmInfoTile(
                          icon: Icons.calendar_today_rounded,
                          label: 'Fecha',
                          value:
                              '${dayNames[_selectedDate.weekday - 1]} ${_selectedDate.day} de ${monthNames[_selectedDate.month]}',
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildConfirmInfoTile(
                          icon: Icons.schedule_rounded,
                          label: 'Hora',
                          value: _selectedTimeSlot >= 0 && _timeSlots.isNotEmpty
                              ? _timeSlots[_selectedTimeSlot]['time']
                              : '--',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // Barber & Payment Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildConfirmInfoTile(
                          icon: Icons.person_rounded,
                          label: 'Barbero',
                          value: _selectedBarber >= 0 && _selectedBarber < _barbers.length
                              ? _barbers[_selectedBarber]['name']
                              : '--',
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildConfirmInfoTile(
                          icon: Icons.payments_rounded,
                          label: 'Pago',
                          value: 'Efectivo',
                        ),
                      ),
                    ],
                  ),

                  if (_notesController.text.isNotEmpty) ...[
                    const SizedBox(height: 15),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.note_alt_rounded,
                                size: 16,
                                color: const Color(0xFFD48B41),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Notas',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _notesController.text,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          // ── Services Summary ──
          _buildSectionTitle('Servicios', isDark),
          const SizedBox(height: 15),
          ..._cartItems.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD48B41),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item['title'] ?? '',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        color: isDark ? Colors.white.withOpacity(0.8) : Colors.black87,
                      ),
                    ),
                  ),
                  Text(
                    item['price'] ?? '',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total en Efectivo',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFD48B41), Color(0xFFE8A85C)],
                ).createShader(bounds),
                child: Text(
                  '\$${_currentTotal.toStringAsFixed(2)}',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // ── Info notice ──
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFD48B41).withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFD48B41).withOpacity(0.15),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: const Color(0xFFD48B41),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Al confirmar, tu cita quedará reservada. Recuerda llegar 5 min antes.',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: isDark
                          ? Colors.white.withOpacity(0.7)
                          : Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildConfirmInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFFD48B41)),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // BOTTOM BAR
  // ══════════════════════════════════════════
  Widget _buildBottomBar(bool isDark) {
    final bool canProceed = _currentStep == 0
        ? _canProceedFromStep0
        : _currentStep == 1
            ? _canProceedFromStep1
            : true;

    final String buttonText = _currentStep == 0
        ? 'Continuar al Agendamiento'
        : _currentStep == 1
            ? 'Revisar Reserva'
            : 'Confirmar y Reservar';

    return Container(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F7),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey.shade300)
                .withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Total always visible
          if (_currentStep < 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_cartItems.length} servicio${_cartItems.length > 1 ? 's' : ''} • Efectivo',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  Text(
                    '\$${_currentTotal.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (context, child) {
                return Transform.scale(
                  scale: _currentStep == 2 && !_isProcessing
                      ? _pulseAnim.value
                      : 1.0,
                  child: child,
                );
              },
              child: ElevatedButton(
                onPressed: _isProcessing
                    ? null
                    : canProceed
                        ? () {
                            HapticFeedback.mediumImpact();
                            if (_currentStep < 2) {
                              _goToStep(_currentStep + 1);
                            } else {
                              _processBooking();
                            }
                          }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canProceed
                      ? const Color(0xFFD48B41)
                      : (isDark
                          ? Colors.white.withOpacity(0.06)
                          : Colors.grey.shade200),
                  foregroundColor:
                      canProceed ? Colors.white : Colors.grey.shade400,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: _isProcessing
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'Reservando...',
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            buttonText,
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            _currentStep == 2
                                ? Icons.check_circle_rounded
                                : Icons.arrow_forward_ios_rounded,
                            size: _currentStep == 2 ? 20 : 14,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // SUCCESS SCREEN
  // ══════════════════════════════════════════
  void _showSuccessScreen() {
    final dayNames = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    final monthNames = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A0A0A), Color(0xFF1A1510)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  // Animated Check Circle
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.elasticOut,
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFD48B41).withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFD48B41).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFD48B41), Color(0xFFE8A85C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD48B41).withOpacity(0.4),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Title
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Text(
                          '¡Cita Reservada!',
                          style: GoogleFonts.outfit(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: Text(
                            'Te esperamos en la barbería. Recuerda llegar 5 minutos antes de tu cita.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.5),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Appointment Details Card
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOut,
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildSuccessDetailRow(
                            Icons.calendar_today_rounded,
                            '${dayNames[_selectedDate.weekday - 1]} ${_selectedDate.day} de ${monthNames[_selectedDate.month]}',
                          ),
                          const SizedBox(height: 16),
                          _buildSuccessDetailRow(
                            Icons.schedule_rounded,
                            _selectedTimeSlot >= 0 && _timeSlots.isNotEmpty
                                ? _timeSlots[_selectedTimeSlot]['time']
                                : '',
                          ),
                          const SizedBox(height: 16),
                          _buildSuccessDetailRow(
                            Icons.person_rounded,
                            _selectedBarber >= 0
                                ? _barbers[_selectedBarber]['name']
                                : '',
                          ),
                          const SizedBox(height: 16),
                          _buildSuccessDetailRow(
                            Icons.payments_rounded,
                            'Efectivo • \$${_currentTotal.toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Bottom Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // Close dialog
                              Navigator.pop(context); // Close checkout
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              'Volver al Inicio',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Ver mis Citas',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: const Color(0xFFD48B41),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFD48B41)),
        const SizedBox(width: 14),
        Text(
          text,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.85),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════
  Widget _buildSectionTitle(String title, bool isDark, {bool isOptional = false}) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black,
            letterSpacing: -0.3,
          ),
        ),
        if (isOptional) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Opcional',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, bool isDark,
      {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 15,
            color: Colors.grey.shade500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: valueColor ?? (isDark ? Colors.white.withOpacity(0.8) : Colors.black87),
          ),
        ),
      ],
    );
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
}

// ══════════════════════════════════════════
// ADD MORE MODAL (preserved from original)
// ══════════════════════════════════════════
class _AddMoreModalContent extends StatefulWidget {
  final bool isDark;
  final Function(Map<String, dynamic>) onAdd;

  const _AddMoreModalContent({required this.isDark, required this.onAdd});

  @override
  State<_AddMoreModalContent> createState() => _AddMoreModalContentState();
}

class _AddMoreModalContentState extends State<_AddMoreModalContent> {
  int _selectedCategory = 0;

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
                      color: widget.isDark
                          ? const Color(0xFF2C2C2E)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: widget.isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                      ),
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
                          child: Icon(item['iconData'],
                              color: item['iconColor'], size: 24),
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
                                  color: widget.isDark
                                      ? Colors.white
                                      : Colors.black87,
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
                          child: const Icon(Icons.add_rounded,
                              color: Color(0xFFD48B41), size: 20),
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
              color: isSelected
                  ? const Color(0xFFD48B41)
                  : Colors.grey.shade300,
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
                  : (widget.isDark
                      ? Colors.grey.shade400
                      : Colors.grey.shade600),
            ),
          ),
        ),
      ),
    );
  }
}
