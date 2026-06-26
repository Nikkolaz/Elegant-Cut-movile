import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiInterceptor extends http.BaseClient {
  final http.Client _inner = http.Client();
  final Duration timeout;

  ApiInterceptor({this.timeout = const Duration(seconds: 15)});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.headers['Content-Type'] = 'application/json';

    try {
      final response = await _inner
          .send(request)
          .timeout(timeout);

      if (response.statusCode == 401) {
        await prefs.remove('token');
        await prefs.remove('username');
        await prefs.remove('firstName');
        await prefs.remove('id_usuario');
        await prefs.remove('id_rol');
        await prefs.remove('email');
        print('Token expirado o inválido — sesión limpiada');
      }

      return response;
    } on TimeoutException {
      throw Exception('La conexión está tardando demasiado. Verifica tu red.');
    }
  }
}
