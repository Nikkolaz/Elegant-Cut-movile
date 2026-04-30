class ApiConstants {
  // En emulador Android, 10.0.2.2 apunta al localhost de tu PC
  // En dispositivo físico, usa tu IP local (ej: 192.168.1.50)
  static const String baseUrl = 'http://10.0.2.2:3001/api';

  // Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String checkToken = '/auth/check-token';
}

class AppConstants {
  static const String appName = 'Elegant Cut';
}
