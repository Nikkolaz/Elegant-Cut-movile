import 'dart:convert';
import 'package:elegant_cut_mobile/src/api/api_middleware.dart';
import 'package:elegant_cut_mobile/src/utils/constants.dart';

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
      final body = {
        'id_empleado': barberId,
        'fecha': date.toIso8601String(),
        'observaciones': observaciones,
        'id_horarios': 1, // Simulando un horario fijo o podríamos buscar el horario correcto
        'servicios': serviceIds,
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
