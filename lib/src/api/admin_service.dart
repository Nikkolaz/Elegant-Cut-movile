import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AdminService {
  final String _baseUrl = ApiConstants.baseUrl;

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // --- DASHBOARD ---

  Future<Map<String, dynamic>> getStats() async {
    try {
      final url = Uri.parse('$_baseUrl/dashboard/stats');
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'message': 'Error al cargar estadísticas'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  Future<Map<String, dynamic>> getActivity() async {
    try {
      final url = Uri.parse('$_baseUrl/dashboard/activity');
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'message': 'Error al cargar actividad'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  // --- USERS ---

  Future<Map<String, dynamic>> getAllUsers() async {
    try {
      final url = Uri.parse('$_baseUrl/users');
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 10));

      print('GET /users -> Status: ${response.statusCode}');
      print('GET /users -> Body: ${response.body}');

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'message': 'Error al cargar usuarios'};
    } catch (e) {
      print('GET /users -> Exception: $e');
      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  Future<Map<String, dynamic>> updateUserStatus(int id, bool estado) async {
    try {
      final url = Uri.parse('$_baseUrl/users/$id');
      final headers = await _getHeaders();
      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode({'estado': estado}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Usuario actualizado'};
      }
      return {'success': false, 'message': 'Error al actualizar usuario'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  // --- APPOINTMENTS ---

  Future<Map<String, dynamic>> getAllAppointments() async {
    try {
      final url = Uri.parse('$_baseUrl/appointments/admin/all');
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'message': 'Error al cargar citas'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  Future<Map<String, dynamic>> updateAppointmentStatus(int id, int statusId) async {
    try {
      final url = Uri.parse('$_baseUrl/appointments/admin/$id/status');
      final headers = await _getHeaders();
      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode({'nuevoEstado': statusId}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Cita actualizada'};
      }
      return {'success': false, 'message': 'Error al actualizar cita'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión'};
    }
  }
}
