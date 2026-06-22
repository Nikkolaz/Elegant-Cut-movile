import 'dart:convert';
import 'package:elegant_cut_mobile/src/api/api_middleware.dart';
import 'package:elegant_cut_mobile/src/utils/constants.dart';

class PqrsApiService {
  final ApiInterceptor _api = ApiInterceptor();

  Future<Map<String, dynamic>> createPqrs({
    required int idUsuario,
    required String tipoSolicitud,
    required String nombreCompleto,
    required String email,
    required String asunto,
    required String descripcion,
    String? telefono,
  }) async {
    try {
      final response = await _api.post(
        Uri.parse('${ApiConstants.baseUrl}/pqrs'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_usuario': idUsuario,
          'tipo_solicitud': tipoSolicitud,
          'nombre_completo': nombreCompleto,
          'email': email,
          'asunto': asunto,
          'descripcion': descripcion,
          if (telefono != null && telefono.isNotEmpty) 'telefono': telefono,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return {'success': true, 'data': decoded};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Error al crear la PQRS'};
      }
    } catch (e) {
      print('PqrsApiService error: $e');
      return {'success': false, 'message': 'Error de conexión'};
    }
  }
}
