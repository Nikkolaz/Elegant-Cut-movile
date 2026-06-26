import 'dart:convert';
import 'api_middleware.dart';
import '../constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingApiService {
  final ApiInterceptor _api = ApiInterceptor();

  Future<bool> createAppointment({
    required int barberId,
    required List<int> serviceIds,
    required DateTime date,
    required int idHorario,
    required String observaciones,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id_usuario') ?? 1;

      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final body = {
        'id_empleado': barberId,
        'id_usuario': userId,
        'fecha': dateStr,
        'observaciones': observaciones,
        'id_horarios': idHorario,
        'id_estado_cita': 1,
        'id_servicio': serviceIds.isNotEmpty ? serviceIds.first : 1,
      };

      final response = await _api.post(
        Uri.parse('${ApiConstants.baseUrl}/appointments'),
        body: json.encode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
      print('Error en createAppointment: ${response.statusCode} - ${response.body}');
      return false;
    } catch (e) {
      print('BookingApiService error: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableSlots(DateTime date, int barberId) async {
    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final url = '${ApiConstants.baseUrl}/appointments/availability?date=$dateStr&barberId=$barberId';
      print('DEBUG getAvailableSlots URL: $url');

      final response = await _api.get(Uri.parse(url));
      print('DEBUG getAvailableSlots response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      print('Error en getAvailableSlots: ${response.statusCode} - ${response.body}');
      return [];
    } catch (e) {
      print('BookingApiService error getAvailableSlots: $e');
      return [];
    }
  }
  Future<bool> rescheduleAppointment({
    required int appointmentId,
    required DateTime fecha,
    required int idHorarios,
    int? idEmpleado,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id_usuario') ?? 1;

      final dateStr = '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';

      final body = {
        'userId': userId,
        'fecha': dateStr,
        'id_horarios': idHorarios,
      };

      if (idEmpleado != null) {
        body['id_empleado'] = idEmpleado;
      }

      final response = await _api.patch(
        Uri.parse('${ApiConstants.baseUrl}/appointments/$appointmentId/reschedule'),
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return true;
      }
      print('Error en rescheduleAppointment: ${response.statusCode} - ${response.body}');
      return false;
    } catch (e) {
      print('BookingApiService error rescheduleAppointment: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getUserAppointments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id_usuario') ?? 1;

      final url = '${ApiConstants.baseUrl}/appointments/user/$userId';
      final response = await _api.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> data = responseData['data'];
          return data.cast<Map<String, dynamic>>();
        }
      }
      print('Error en getUserAppointments: ${response.statusCode} - ${response.body}');
      return [];
    } catch (e) {
      print('BookingApiService error getUserAppointments: $e');
      return [];
    }
  }
}
