import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiInterceptor extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.headers['Content-Type'] = 'application/json';

    final response = await _inner.send(request);

    if (response.statusCode == 401) {
      print('Token expirado, deberíamos mandar al usuario al Login');
    }

    return response;
  }
}
