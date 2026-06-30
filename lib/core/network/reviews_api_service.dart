import 'dart:convert';
import 'api_middleware.dart';
import '../constants/app_constants.dart';

class ReviewsApiService {
  final ApiInterceptor _api = ApiInterceptor(timeout: const Duration(seconds: 10));

  Future<List<Map<String, dynamic>>> getReviews() async {
    try {
      final response = await _api.get(Uri.parse('${ApiConstants.baseUrl}/reviews'));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> data = decoded is Map && decoded.containsKey('data') ? decoded['data'] : decoded;

        return data.map((r) {
          final client = r['usuarios_resenas_id_clienteTousuarios'];
          final fullName = client != null ? '${client['prim_nombre']} ${client['apellido1']}' : 'Cliente Anónimo';

          return {
            'id': r['id_resena'],
            'name': fullName,
            'rating': r['calificacion'] ?? 5,
            'comment': r['comentario'] ?? 'Sin comentario',
            'time': _formatDate(r['fecha_resena']),
          };
        }).toList();
      } else {
        throw Exception('Error al cargar reseñas: ${response.statusCode}');
      }
    } catch (e) {
      print('ReviewsApiService error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> createReview({
    required int rating,
    required String comment,
    int? idBarbero,
    required int idCliente,
  }) async {
    try {
      final response = await _api.post(
        Uri.parse('${ApiConstants.baseUrl}/reviews'),
        body: jsonEncode({
          'calificacion': rating,
          'comentario': comment,
          'id_barbero': idBarbero,
          'id_cliente': idCliente,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'message': 'Reseña enviada con éxito'};
      }
      return {'success': false, 'message': 'Error al enviar reseña: ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: ${e.toString().replaceAll("Exception: ", "")}'};
    }
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return 'Recientemente';
    try {
      final date = DateTime.parse(isoDate);
      final difference = DateTime.now().difference(date);
      if (difference.inDays == 0) return 'Hoy';
      if (difference.inDays == 1) return 'Hace 1 día';
      if (difference.inDays < 7) return 'Hace ${difference.inDays} días';
      if (difference.inDays < 30) return 'Hace ${difference.inDays ~/ 7} semanas';
      return 'Hace ${difference.inDays ~/ 30} meses';
    } catch (e) {
      return 'Recientemente';
    }
  }
}
