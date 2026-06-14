import 'dart:convert';
import 'package:elegant_cut_mobile/src/api/api_middleware.dart';
import 'package:elegant_cut_mobile/src/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingApiService {
  final ApiInterceptor _api = ApiInterceptor();

  Future<bool> createAppointment({
    required int barberId,
    required List<int> serviceIds,
    required DateTime date,
    required int horaInicio,
    required int horaFin,
    required String observaciones,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id_usuario') ?? 1;

      final body = {
        'id_empleado': barberId,
        'id_usuario': userId, // Real logged-in user
        'fecha': "\${date.year}-\${date.month.toString().padLeft(2, '0')}-\${date.day.toString().padLeft(2, '0')}", // YYYY-MM-DD
        'observaciones': observaciones,
        'id_horarios': horaInicio + 1, // Map time slot index to ID
        'id_estado_cita': 1, // Pending
        'id_servicio': serviceIds.isNotEmpty ? serviceIds.first : 1, // DTO expects single id_servicio
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
      print('BookingApiService error: \$e');
      return false;
    }
  }
}
