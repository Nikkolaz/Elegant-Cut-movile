import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Widget reutilizable para mostrar imágenes de Cloudinary.
///
/// Principio SOLID: SRP (solo renderiza imágenes de red)
/// + OCP (extensible via shape, placeholder, errorWidget sin modificar el código)
class CloudinaryImage extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final BoxShape shape;
  final double borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BoxFit fit;
  final double? width;
  final double? height;

  const CloudinaryImage({
    super.key,
    required this.imageUrl,
    this.size = 60,
    this.shape = BoxShape.circle,
    this.borderRadius = 20,
    this.placeholder,
    this.errorWidget,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveWidth = width ?? size;
    final effectiveHeight = height ?? size;

    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildFallback(isDark, effectiveWidth, effectiveHeight);
    }

    return ClipRRect(
      borderRadius: shape == BoxShape.circle
          ? BorderRadius.circular(effectiveWidth / 2)
          : BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: effectiveWidth,
        height: effectiveHeight,
        fit: fit,
        placeholder: (context, url) =>
            placeholder ??
            _buildLoadingPlaceholder(isDark, effectiveWidth, effectiveHeight),
        errorWidget: (context, url, error) =>
            errorWidget ??
            _buildFallback(isDark, effectiveWidth, effectiveHeight),
      ),
    );
  }

  Widget _buildLoadingPlaceholder(
      bool isDark, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE8E8E8),
        shape: shape,
        borderRadius:
            shape == BoxShape.rectangle ? BorderRadius.circular(borderRadius) : null,
      ),
      child: Center(
        child: SizedBox(
          width: width * 0.3,
          height: height * 0.3,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFFD48B41),
          ),
        ),
      ),
    );
  }

  Widget _buildFallback(bool isDark, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE8E8E8),
        shape: shape,
        borderRadius:
            shape == BoxShape.rectangle ? BorderRadius.circular(borderRadius) : null,
      ),
      child: Icon(
        Icons.image_not_supported_outlined,
        color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
        size: width * 0.4,
      ),
    );
  }
}
