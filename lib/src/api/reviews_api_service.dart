import 'dart:convert';
import 'package:elegant_cut_mobile/src/api/api_middleware.dart';
import 'package:elegant_cut_mobile/src/utils/constants.dart';

class ReviewsApiService {
  final ApiInterceptor _api = ApiInterceptor();

  Future<List<Map<String, dynamic>>> getReviews() async {
    try {
      // Intentamos obtener todas las reseñas
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
      print('ReviewsApiService error: \$e');
      return [];
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
