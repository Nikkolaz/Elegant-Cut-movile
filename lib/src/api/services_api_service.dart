import 'dart:convert';
import 'package:elegant_cut_mobile/src/api/api_middleware.dart';
import 'package:elegant_cut_mobile/src/utils/constants.dart';

class ServicesApiService {
  final ApiInterceptor _api = ApiInterceptor();

  Future<List<Map<String, dynamic>>> getServices() async {
    try {
      final response = await _api.get(Uri.parse('${ApiConstants.baseUrl}/services/public'));
      
      // Si el backend no tiene /services/public, usar /services si es permitido para usuarios no logueados.
      // Ajustaremos si da 401/404.
      final res = response.statusCode == 404 || response.statusCode == 401 
          ? await _api.get(Uri.parse('${ApiConstants.baseUrl}/services'))
          : response;

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        final List<dynamic> data = decoded is Map && decoded.containsKey('data') ? decoded['data'] : decoded;
        
        return data.map((s) {
          return {
            'id': s['id_servicio'],
            'title': s['nombre'],
            'duration': '${s['duracion']} min',
            'price': s['precio']?.toString() ?? '0',
            'category': s['categorias']?['nombre'] ?? 'Servicio',
            'category_id': s['id_categoria'],
            'description': s['descripcion'],
            'image': s['imagen'],
          };
        }).toList();
      } else {
        throw Exception('Error al cargar servicios: ${res.statusCode}');
      }
    } catch (e) {
      print('ServicesApiService error: \$e');
      return [];
    }
  }
}
