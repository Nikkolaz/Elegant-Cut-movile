import 'dart:io' show Platform;

class ApiConstants {
  static String get baseUrl {
    try {
      if (Platform.isAndroid) {
        return 'http://localhost:3001/api';
      }
    } catch (_) {}
    return 'http://localhost:3001/api';
  }

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String checkToken = '/auth/check-token';
}

class CloudinaryConstants {
  static const String cloudName = 'dbuldg4dt';
  static const String baseUrl = 'https://res.cloudinary.com/$cloudName/image/upload';

  /// Construye la URL completa de Cloudinary a partir de un public_id.
  /// Si ya es una URL completa, la devuelve tal cual.
  /// Si es null/vacío, devuelve null.
  static String? buildUrl(String? publicId) {
    if (publicId == null || publicId.trim().isEmpty) return null;
    if (publicId.startsWith('http://') || publicId.startsWith('https://')) {
      return publicId;
    }
    return '$baseUrl/$publicId';
  }
}

class AppConstants {
  static const String appName = 'Elegant Cut';
}
