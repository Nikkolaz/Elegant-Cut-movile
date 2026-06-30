import 'dart:convert';
import 'api_middleware.dart';
import '../constants/app_constants.dart';

class AdminService {
  final ApiInterceptor _api = ApiInterceptor(timeout: const Duration(seconds: 15));
  final String _baseUrl = ApiConstants.baseUrl;

  String _extractErrorMessage(dynamic body, String fallback) {
    if (body == null || body is! Map) return fallback;
    final msg = body['message'];
    if (msg == null) return fallback;
    if (msg is String) return msg;
    if (msg is List) return msg.join(', ');
    if (msg is Map) {
      if (msg['message'] is List) return (msg['message'] as List).join(', ');
      if (msg['message'] is String) return msg['message'];
      return 'Error de validación en los datos';
    }
    return msg.toString();
  }

  Future<Map<String, dynamic>> getStats() async {
    try {
      final url = Uri.parse('$_baseUrl/dashboard/stats');
      final response = await _api.get(url);

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'message': 'Error al cargar estadísticas'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: ${e.toString().replaceAll("Exception: ", "")}'};
    }
  }

  Future<Map<String, dynamic>> getActivity() async {
    try {
      final url = Uri.parse('$_baseUrl/dashboard/activity');
      final response = await _api.get(url);

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'message': 'Error al cargar actividad'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: ${e.toString().replaceAll("Exception: ", "")}'};
    }
  }

  Future<Map<String, dynamic>> getAllUsers() async {
    try {
      final url = Uri.parse('$_baseUrl/users');
      final response = await _api.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return {'success': true, 'data': decoded is List ? decoded : (decoded['data'] ?? decoded)};
      }
      return {'success': false, 'message': 'Error al cargar usuarios'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: ${e.toString().replaceAll("Exception: ", "")}'};
    }
  }

  Future<Map<String, dynamic>> updateUserStatus(int id, bool estado) async {
    try {
      final url = Uri.parse('$_baseUrl/users/$id');
      final response = await _api.patch(url, body: jsonEncode({'estado': estado}));

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Usuario actualizado'};
      }
      return {'success': false, 'message': 'Error al actualizar usuario'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: ${e.toString().replaceAll("Exception: ", "")}'};
    }
  }

  Future<Map<String, dynamic>> getAllAppointments() async {
    try {
      final url = Uri.parse('$_baseUrl/appointments/admin/all');
      final response = await _api.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return {'success': true, 'data': decoded is List ? decoded : (decoded['data'] ?? decoded)};
      }
      return {'success': false, 'message': 'Error al cargar citas'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: ${e.toString().replaceAll("Exception: ", "")}'};
    }
  }

  Future<Map<String, dynamic>> updateAppointmentStatus(int id, int statusId) async {
    try {
      final url = Uri.parse('$_baseUrl/appointments/admin/$id/status');
      final response = await _api.patch(url, body: jsonEncode({'nuevoEstado': statusId}));

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Cita actualizada'};
      }
      return {'success': false, 'message': 'Error al actualizar cita'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: ${e.toString().replaceAll("Exception: ", "")}'};
    }
  }

  Future<Map<String, dynamic>> getAllBarbers() async {
    try {
      final url = Uri.parse('$_baseUrl/barbers/all');
      final response = await _api.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return {'success': true, 'data': decoded is List ? decoded : (decoded['data'] ?? decoded)};
      }
      return {'success': false, 'message': 'Error al cargar barberos'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: ${e.toString().replaceAll("Exception: ", "")}'};
    }
  }

  Future<Map<String, dynamic>> createBarber(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$_baseUrl/barbers');
      final response = await _api.post(url, body: jsonEncode(data));

      final body = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': body, 'message': 'Barbero creado con éxito'};
      }
      return {
        'success': false,
        'message': _extractErrorMessage(body, 'Error al crear barbero')
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: ${e.toString().replaceAll("Exception: ", "")}'};
    }
  }

  Future<Map<String, dynamic>> updateBarber(int id, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$_baseUrl/barbers/$id');
      final response = await _api.patch(url, body: jsonEncode(data));

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': body, 'message': 'Barbero actualizado con éxito'};
      }
      return {
        'success': false,
        'message': _extractErrorMessage(body, 'Error al actualizar barbero')
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: ${e.toString().replaceAll("Exception: ", "")}'};
    }
  }

  Future<Map<String, dynamic>> toggleBarberStatus(int id) async {
    try {
      final url = Uri.parse('$_baseUrl/barbers/$id/toggle');
      final response = await _api.put(url);

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'message': 'Error al cambiar estado del barbero'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: ${e.toString().replaceAll("Exception: ", "")}'};
    }
  }

  Future<Map<String, dynamic>> deleteBarber(int id) async {
    try {
      final url = Uri.parse('$_baseUrl/barbers/$id');
      final response = await _api.delete(url);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Barbero eliminado/desactivado con éxito'};
      }
      return {'success': false, 'message': 'Error al eliminar barbero'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: ${e.toString().replaceAll("Exception: ", "")}'};
    }
  }

  Future<List<int>?> downloadStatsPdf() async {
    try {
      final url = Uri.parse('$_baseUrl/dashboard/stats/pdf');
      final response = await _api.get(url);

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
