import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'carita_widget.dart';

/// Widget especializado para avatares de barberos.
///
/// Muestra la foto de perfil del barbero desde Cloudinary.
/// Si no hay foto, muestra el CaritaWidget como fallback elegante.
///
/// Principio SOLID: SRP (solo renderiza avatar de barbero)
/// + LSP (sustituible por cualquier widget de avatar)
class BarberAvatar extends StatelessWidget {
  final String? photoUrl;
  final double size;
  final Color? borderColor;
  final double borderWidth;
  final int expressionType;
  final Color caritaColor;
  final bool showAvailabilityBadge;
  final bool isAvailable;

  const BarberAvatar({
    super.key,
    this.photoUrl,
    this.size = 65,
    this.borderColor,
    this.borderWidth = 2.5,
    this.expressionType = 0,
    this.caritaColor = const Color(0xFF88C9F9),
    this.showAvailabilityBadge = false,
    this.isAvailable = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasBorder = borderColor != null;

    Widget avatarContent;

    if (photoUrl != null && photoUrl!.isNotEmpty) {
      avatarContent = ClipOval(
        child: CachedNetworkImage(
          imageUrl: photoUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildShimmer(isDark),
          errorWidget: (context, url, error) => _buildCaritaFallback(),
        ),
      );
    } else {
      avatarContent = _buildCaritaFallback();
    }

    return SizedBox(
      width: size + (hasBorder ? borderWidth * 2 : 0),
      height: size + (hasBorder ? borderWidth * 2 : 0),
      child: Stack(
        children: [
          Container(
            width: size + (hasBorder ? borderWidth * 2 : 0),
            height: size + (hasBorder ? borderWidth * 2 : 0),
            decoration: hasBorder
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: borderColor!,
                      width: borderWidth,
                    ),
                  )
                : null,
            child: Center(child: avatarContent),
          ),

          // Badge de disponibilidad
          if (showAvailabilityBadge)
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: size * 0.22,
                height: size * 0.22,
                decoration: BoxDecoration(
                  color: isAvailable
                      ? const Color(0xFF50C878)
                      : Colors.grey.shade500,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCaritaFallback() {
    return CaritaWidget(
      size: size,
      color: caritaColor,
      expressionType: expressionType,
    );
  }

  Widget _buildShimmer(bool isDark) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE8E8E8),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.3,
          height: size * 0.3,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFFD48B41),
          ),
        ),
      ),
    );
  }
}
