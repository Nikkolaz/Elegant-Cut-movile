import 'dart:convert';
import 'api_middleware.dart';
import '../constants/app_constants.dart';

class ProfileApiService {
  final ApiInterceptor _api = ApiInterceptor(timeout: const Duration(seconds: 15));
  final String _baseUrl = ApiConstants.baseUrl;

  /// GET /users/me — obtiene perfil completo del usuario autenticado
  Future<Map<String, dynamic>> getMyProfile() async {
    try {
      final url = Uri.parse('$_baseUrl/users/me');
      final response = await _api.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return {'success': true, 'data': decoded};
      }
      return {'success': false, 'message': 'Error al cargar perfil'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: ${e.toString().replaceAll("Exception: ", "")}'};
    }
  }

  /// PATCH /users/profile — actualiza datos del usuario autenticado
  Future<Map<String, dynamic>> updateMyProfile(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$_baseUrl/users/profile');
      final response = await _api.patch(url, body: jsonEncode(data));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return {'success': true, 'data': decoded, 'message': 'Perfil actualizado'};
      }

      // Try to parse error message
      try {
        final body = jsonDecode(response.body);
        final msg = body['message'];
        if (msg is String) return {'success': false, 'message': msg};
        if (msg is List) return {'success': false, 'message': msg.join(', ')};
      } catch (_) {}

      return {'success': false, 'message': 'Error al actualizar perfil'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: ${e.toString().replaceAll("Exception: ", "")}'};
    }
  }

  /// GET /portabarbero/:id — obtiene el portafolio del barbero
  Future<Map<String, dynamic>> getBarberPortfolio(int barberId) async {
    try {
      final url = Uri.parse('$_baseUrl/portabarbero/$barberId');
      final response = await _api.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return {'success': true, 'data': decoded};
      }
      return {'success': false, 'message': 'Sin portafolio registrado'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: ${e.toString().replaceAll("Exception: ", "")}'};
    }
  }

  /// POST /portabarbero — crea/guarda portafolio
  Future<Map<String, dynamic>> saveBarberPortfolio(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$_baseUrl/portabarbero');
      final response = await _api.post(url, body: jsonEncode(data));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return {'success': true, 'data': decoded, 'message': 'Portafolio guardado con éxito'};
      }
      return {'success': false, 'message': 'Error al guardar portafolio'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: ${e.toString().replaceAll("Exception: ", "")}'};
    }
  }
}
