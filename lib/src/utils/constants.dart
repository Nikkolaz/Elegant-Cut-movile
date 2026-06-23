class ApiConstants {
  // Para Web/Windows usa localhost. Para Emulador Android usa 10.0.2.2. Dispositivo físico: IP local (ej: 10.1.219.126)
  static const String baseUrl = 'http://127.0.0.1:3001/api';
  // Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String checkToken = '/auth/check-token';
}

class AppConstants {
  static const String appName = 'Elegant Cut';
}
