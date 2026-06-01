import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; //mini base de datos para guardar el token cadavez que entra el usuario

// Este es tu Middleware/Interceptor para Flutter
class ApiInterceptor extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    
    // 1. Obtenemos el token de la memoria del celular
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // 2. Si el usuario está logueado y tiene token, se lo pegamos a la petición
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Aseguramos que siempre lleve el content-type correcto
    request.headers['Content-Type'] = 'application/json';

    // 3. Dejamos que la petición viaje al servidor
    final response = await _inner.send(request);

    // 4. (Opcional) Si quisieras manejar el error 401 globalmente:
    if (response.statusCode == 401) {
      print('Token expirado, deberíamos mandar al usuario al Login');
      // Aquí podrías borrar el token o redirigir al login
    }

    return response;
  }
}
