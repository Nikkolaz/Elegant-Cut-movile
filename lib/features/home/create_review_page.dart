import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/barber_api_service.dart';
import '../../core/network/reviews_api_service.dart';
import '../../shared/widgets/barber_avatar.dart';
import '../../shared/widgets/custom_toast.dart';

class CreateReviewPage extends StatefulWidget {
  final int? initialBarberId;
  final String? initialBarberName;

  const CreateReviewPage({
    super.key,
    this.initialBarberId,
    this.initialBarberName,
  });

  @override
  State<CreateReviewPage> createState() => _CreateReviewPageState();
}

class _CreateReviewPageState extends State<CreateReviewPage> {
  final ReviewsApiService _reviewsApi = ReviewsApiService();
  final BarberApiService _barberApi = BarberApiService();

  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  bool _isSaving = false;

  // Review target: 'establishment' or 'barber'
  String _reviewTarget = 'establishment';

  // List of barbers for selection
  List<Map<String, dynamic>> _barbers = [];
  bool _isLoadingBarbers = false;
  Map<String, dynamic>? _selectedBarber;

  @override
  void initState() {
    super.initState();
    if (widget.initialBarberId != null) {
      _reviewTarget = 'barber';
      _selectedBarber = {
        'id': widget.initialBarberId,
        'name': widget.initialBarberName ?? 'Barbero',
      };
    }
    _loadBarbers();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadBarbers() async {
    setState(() => _isLoadingBarbers = true);
    try {
      final list = await _barberApi.getBarbers();
      setState(() {
        _barbers = list;
        // If we have an initial barber id, try to match it with the loaded barbers to get complete details
        if (widget.initialBarberId != null) {
          final matched = list.firstWhere(
            (b) => b['id'] == widget.initialBarberId,
            orElse: () => _selectedBarber!,
          );
          _selectedBarber = matched;
        }
      });
    } catch (e) {
      print('Error loading barbers: $e');
    } finally {
      setState(() => _isLoadingBarbers = false);
    }
  }

  Future<void> _submitReview() async {
    if (_commentController.text.trim().isEmpty) {
      CustomToast.show(context, 'Por favor, escribe un comentario', ToastType.error);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id_usuario');

      if (userId == null) {
        if (mounted) {
          CustomToast.show(context, 'Debes iniciar sesión para dejar una reseña', ToastType.error);
        }
        setState(() => _isSaving = false);
        return;
      }

      int? idBarbero;
      if (_reviewTarget == 'barber' && _selectedBarber != null) {
        idBarbero = int.tryParse(_selectedBarber!['id'].toString());
      }

      final response = await _reviewsApi.createReview(
        rating: _rating,
        comment: _commentController.text.trim(),
        idBarbero: idBarbero,
        idCliente: userId,
      );

      if (mounted) {
        if (response['success'] == true) {
          CustomToast.show(context, 'Reseña creada con éxito', ToastType.success);
          Navigator.pop(context, true);
        } else {
          CustomToast.show(context, response['message'] ?? 'Error al crear reseña', ToastType.error);
        }
      }
    } catch (e) {
      if (mounted) {
        CustomToast.show(context, 'Error de conexión: $e', ToastType.error);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = const Color(0xFFD48B41);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Crear Reseña',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿A quién va dirigida tu reseña?',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 15),

              // Target selectors (Segmented row style)
              Row(
                children: [
                  Expanded(
                    child: _buildTargetButton(
                      label: 'Establecimiento',
                      value: 'establishment',
                      icon: Icons.storefront_rounded,
                      isActive: _reviewTarget == 'establishment',
                      isDark: isDark,
                      primaryGold: primaryGold,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildTargetButton(
                      label: 'Barbero',
                      value: 'barber',
                      icon: Icons.person_outline_rounded,
                      isActive: _reviewTarget == 'barber',
                      isDark: isDark,
                      primaryGold: primaryGold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Barbero selection section (only if reviewTarget is 'barber')
              if (_reviewTarget == 'barber') ...[
                Text(
                  'Selecciona un Barbero',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                _isLoadingBarbers
                    ? const Center(child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(color: Color(0xFFD48B41)),
                      ))
                    : _barbers.isEmpty
                        ? Text(
                            'No hay barberos disponibles',
                            style: GoogleFonts.outfit(color: Colors.grey),
                          )
                        : SizedBox(
                            height: 110,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: _barbers.length,
                              itemBuilder: (context, index) {
                                final barber = _barbers[index];
                                final isSelected = _selectedBarber?['id'] == barber['id'];
                                final colorHex = [0xFF98E68E, 0xFFFFB2D1, 0xFF88C9F9, 0xFFFFD56B];
                                final avatarColor = Color(colorHex[index % colorHex.length]);

                                return Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() => _selectedBarber = barber);
                                    },
                                    child: Column(
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected ? primaryGold : Colors.transparent,
                                              width: 2.5,
                                            ),
                                          ),
                                          child: BarberAvatar(
                                            photoUrl: barber['photoUrl'],
                                            size: 56,
                                            caritaColor: avatarColor,
                                            expressionType: index % 4,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          barber['name'].toString().split(' ')[0],
                                          style: GoogleFonts.outfit(
                                            fontSize: 12,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            color: isSelected
                                                ? primaryGold
                                                : (isDark ? Colors.white70 : Colors.black87),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                const SizedBox(height: 25),
              ],

              // Rating Stars section
              Center(
                child: Column(
                  children: [
                    Text(
                      'Calificación',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starValue = index + 1;
                        return IconButton(
                          icon: Icon(
                            _rating >= starValue ? Icons.star_rounded : Icons.star_border_rounded,
                            size: 42,
                            color: primaryGold,
                          ),
                          onPressed: () {
                            setState(() => _rating = starValue);
                          },
                        );
                      }),
                    ),
                    Text(
                      _getRatingDescription(),
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: primaryGold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Comment section
              Text(
                'Comentario',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1C1E) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                  ),
                ),
                child: TextField(
                  controller: _commentController,
                  maxLines: 5,
                  style: GoogleFonts.outfit(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Cuéntanos cómo fue tu experiencia con nosotros...',
                    hintStyle: GoogleFonts.outfit(color: Colors.grey.shade500, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(18),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGold,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          'Enviar Reseña',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTargetButton({
    required String label,
    required String value,
    required IconData icon,
    required bool isActive,
    required bool isDark,
    required Color primaryGold,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() => _reviewTarget = value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isActive
              ? primaryGold.withOpacity(0.1)
              : (isDark ? const Color(0xFF1C1C1E) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? primaryGold.withOpacity(0.5)
                : (isDark ? Colors.grey.shade900 : Colors.grey.shade200),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isActive ? primaryGold : Colors.grey.shade500,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? primaryGold : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingDescription() {
    switch (_rating) {
      case 1:
        return 'Muy malo ⭐️';
      case 2:
        return 'Malo ⭐️⭐️';
      case 3:
        return 'Regular ⭐️⭐️⭐️';
      case 4:
        return 'Bueno ⭐️⭐️⭐️⭐️';
      default:
        return 'Excelente ⭐️⭐️⭐️⭐️⭐️';
    }
  }
}
