import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/network/admin_service.dart';
import '../../shared/widgets/custom_toast.dart';

class AdminReviewsPage extends StatefulWidget {
  const AdminReviewsPage({super.key});

  @override
  State<AdminReviewsPage> createState() => _AdminReviewsPageState();
}

class _AdminReviewsPageState extends State<AdminReviewsPage> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  List<dynamic> _allReviews = [];
  List<dynamic> _filteredReviews = [];
  final TextEditingController _searchController = TextEditingController();
  String _errorMessage = '';
  String _activeFilter = 'all'; // 'all', 'approved', 'spam'

  @override
  void initState() {
    super.initState();
    _loadReviews();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await _adminService.getAllReviews();
      if (response['success'] == true) {
        setState(() {
          _allReviews = response['data'] ?? [];
          _applyFilters();
        });
      } else {
        setState(() => _errorMessage = response['message'] ?? 'Error desconocido');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error de conexión: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      var reviews = List<dynamic>.from(_allReviews);

      // Status filter
      if (_activeFilter == 'approved') {
        reviews = reviews.where((r) => r['estado'] == 1).toList();
      } else if (_activeFilter == 'spam') {
        reviews = reviews.where((r) => r['estado'] == 0).toList();
      }

      // Text search
      if (query.isNotEmpty) {
        reviews = reviews.where((r) {
          final client = r['usuarios_resenas_id_clienteTousuarios'];
          final clientName = client != null
              ? '${client['prim_nombre'] ?? ''} ${client['apellido1'] ?? ''}'.toLowerCase()
              : '';
          final barber = r['barbero'];
          final barberName = barber != null
              ? '${barber['prim_nombre'] ?? ''} ${barber['apellido1'] ?? ''}'.toLowerCase()
              : '';
          final comment = (r['comentario'] ?? '').toString().toLowerCase();

          return clientName.contains(query) ||
              barberName.contains(query) ||
              comment.contains(query);
        }).toList();
      }

      _filteredReviews = reviews;
    });
  }

  Future<void> _toggleReviewStatus(dynamic review) async {
    final id = review['id_resena'];
    if (id == null) return;

    final currentStatus = review['estado'] ?? 1;
    final newStatus = currentStatus == 1 ? 0 : 1;

    try {
      final response = await _adminService.changeReviewStatus(id, newStatus);
      if (response['success'] == true) {
        if (mounted) {
          CustomToast.show(
            context,
            newStatus == 1 ? 'Reseña visible nuevamente' : 'Reseña ocultada',
            ToastType.success,
          );
        }
        _loadReviews();
      } else {
        if (mounted) {
          CustomToast.show(
            context,
            response['message'] ?? 'Error al actualizar',
            ToastType.error,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        CustomToast.show(context, 'Error de conexión', ToastType.error);
      }
    }
  }

  Future<void> _deleteReview(dynamic review) async {
    final id = review['id_resena'];
    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Eliminar reseña',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          content: Text(
            '¿Estás seguro de eliminar esta reseña permanentemente? Esta acción no se puede deshacer.',
            style: GoogleFonts.outfit(
              color: Colors.grey.shade500,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'Cancelar',
                style: GoogleFonts.outfit(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text('Eliminar', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final response = await _adminService.deleteReview(id);
      if (response['success'] == true) {
        if (mounted) {
          CustomToast.show(context, 'Reseña eliminada', ToastType.success);
        }
        _loadReviews();
      } else {
        if (mounted) {
          CustomToast.show(
            context,
            response['message'] ?? 'Error al eliminar',
            ToastType.error,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        CustomToast.show(context, 'Error de conexión', ToastType.error);
      }
    }
  }

  void _showReviewDetails(dynamic review) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final primaryGold = const Color(0xFFD48B41);
        final isApproved = review['estado'] == 1;

        final client = review['usuarios_resenas_id_clienteTousuarios'];
        final clientName = client != null
            ? '${client['prim_nombre'] ?? ''} ${client['apellido1'] ?? ''}'.trim()
            : 'Cliente Anónimo';
        final clientEmail = client?['email'] ?? 'No disponible';
        final clientUsername = client?['username'] ?? 'No disponible';

        final barber = review['barbero'];
        final barberName = barber != null
            ? '${barber['prim_nombre'] ?? ''} ${barber['apellido1'] ?? ''}'.trim()
            : 'No asignado';

        final rating = (review['calificacion'] ?? 5) as num;
        final comment = review['comentario'] ?? 'Sin comentario';
        final dateStr = _formatDate(review['fecha_resena']);

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Header with stars
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryGold.withOpacity(0.2), primaryGold.withOpacity(0.05)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.rate_review_rounded, color: primaryGold, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          clientName,
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            ...List.generate(5, (i) {
                              return Icon(
                                i < rating.toInt() ? Icons.star_rounded : Icons.star_border_rounded,
                                color: primaryGold,
                                size: 20,
                              );
                            }),
                            const SizedBox(width: 8),
                            Text(
                              '$rating/5',
                              style: GoogleFonts.outfit(
                                color: primaryGold,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Comment
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.format_quote_rounded, color: primaryGold.withOpacity(0.5), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Comentario',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      comment,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Divider(height: 1),
              const SizedBox(height: 16),

              // Details
              _buildDetailRow('Cliente', clientName, Icons.person_outline_rounded, isDark),
              _buildDetailRow('Usuario', clientUsername, Icons.alternate_email_rounded, isDark),
              _buildDetailRow('Email', clientEmail, Icons.mail_outline_rounded, isDark),
              _buildDetailRow('Barbero', barberName, Icons.content_cut_rounded, isDark),
              _buildDetailRow('Fecha', dateStr, Icons.calendar_today_outlined, isDark),

              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Status + Actions
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Visibilidad',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          isApproved ? 'Visible para todos los usuarios' : 'Oculta del público',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: isApproved,
                    activeColor: primaryGold,
                    onChanged: (val) {
                      Navigator.pop(context);
                      _toggleReviewStatus(review);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Delete button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteReview(review);
                  },
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  label: Text('Eliminar permanentemente', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: BorderSide(color: Colors.redAccent.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String title, String value, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade500, size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return 'Sin fecha';
    try {
      final dt = DateTime.parse(isoDate);
      final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return 'Fecha inválida';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGold = const Color(0xFFD48B41);

    // Counts for filter chips
    final totalCount = _allReviews.length;
    final approvedCount = _allReviews.where((r) => r['estado'] == 1).length;
    final hiddenCount = _allReviews.where((r) => r['estado'] == 0).length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Reseñas',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: isDark ? Colors.white : Colors.black),
            onPressed: _loadReviews,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C1E) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Buscar por cliente, barbero o comentario...',
                  hintStyle: GoogleFonts.outfit(color: Colors.grey.shade500, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
          ),

          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildFilterChip('Todas', 'all', totalCount, isDark, primaryGold),
                const SizedBox(width: 8),
                _buildFilterChip('Visibles', 'approved', approvedCount, isDark, const Color(0xFF50C878)),
                const SizedBox(width: 8),
                _buildFilterChip('Ocultas', 'spam', hiddenCount, isDark, Colors.redAccent),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Reviews List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFD48B41)))
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage,
                                style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _loadReviews,
                                style: ElevatedButton.styleFrom(backgroundColor: primaryGold),
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadReviews,
                        color: primaryGold,
                        child: _filteredReviews.isEmpty
                            ? ListView(
                                children: [
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                                  Center(
                                    child: Column(
                                      children: [
                                        Icon(Icons.reviews_outlined, size: 56, color: Colors.grey.shade400),
                                        const SizedBox(height: 16),
                                        Text(
                                          _activeFilter == 'all'
                                              ? 'No hay reseñas registradas'
                                              : _activeFilter == 'approved'
                                                  ? 'No hay reseñas visibles'
                                                  : 'No hay reseñas ocultas',
                                          style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                itemCount: _filteredReviews.length,
                                itemBuilder: (context, index) {
                                  return _buildReviewCard(_filteredReviews[index], isDark, primaryGold)
                                      .animate()
                                      .fade(duration: 300.ms)
                                      .slideX(begin: 0.05, curve: Curves.easeOut);
                                },
                              ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String filterValue, int count, bool isDark, Color color) {
    final isActive = _activeFilter == filterValue;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _activeFilter = filterValue);
          _applyFilters();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.12) : (isDark ? const Color(0xFF1C1C1E) : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive ? color.withOpacity(0.4) : (isDark ? Colors.grey.shade900 : Colors.grey.shade200),
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                '$count',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isActive ? color : (isDark ? Colors.white70 : Colors.black54),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? color : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(dynamic review, bool isDark, Color primaryGold) {
    final isApproved = review['estado'] == 1;
    final rating = (review['calificacion'] ?? 5) as num;
    final comment = review['comentario'] ?? 'Sin comentario';

    final client = review['usuarios_resenas_id_clienteTousuarios'];
    final clientName = client != null
        ? '${client['prim_nombre'] ?? ''} ${client['apellido1'] ?? ''}'.trim()
        : 'Cliente Anónimo';

    final barber = review['barbero'];
    final barberName = barber != null
        ? '${barber['prim_nombre'] ?? ''} ${barber['apellido1'] ?? ''}'.trim()
        : 'Sin barbero';

    final dateStr = _formatDate(review['fecha_resena']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: !isApproved
              ? Colors.redAccent.withOpacity(0.2)
              : (isDark ? Colors.grey.shade900 : Colors.grey.shade200),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showReviewDetails(review),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: client info + status badge
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: primaryGold.withOpacity(0.1),
                      child: Text(
                        clientName.isNotEmpty ? clientName[0].toUpperCase() : 'C',
                        style: GoogleFonts.outfit(
                          color: primaryGold,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            clientName,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.content_cut_rounded, size: 12, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text(
                                barberName,
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '·',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                dateStr,
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isApproved
                            ? const Color(0xFF50C878).withOpacity(0.1)
                            : Colors.redAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isApproved ? 'Visible' : 'Oculta',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isApproved ? const Color(0xFF50C878) : Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Stars
                Row(
                  children: List.generate(5, (i) {
                    return Icon(
                      i < rating.toInt() ? Icons.star_rounded : Icons.star_border_rounded,
                      color: primaryGold,
                      size: 18,
                    );
                  }),
                ),
                const SizedBox(height: 8),

                // Comment preview
                Text(
                  comment,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: isDark ? Colors.white.withOpacity(0.75) : Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),

                // Action buttons row
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: isApproved ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        label: isApproved ? 'Ocultar' : 'Mostrar',
                        color: isApproved ? Colors.orange.shade700 : const Color(0xFF50C878),
                        isDark: isDark,
                        onTap: () => _toggleReviewStatus(review),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.delete_outline_rounded,
                        label: 'Eliminar',
                        color: Colors.redAccent,
                        isDark: isDark,
                        onTap: () => _deleteReview(review),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
