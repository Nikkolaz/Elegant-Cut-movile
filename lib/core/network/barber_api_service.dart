import 'dart:convert';
import 'api_middleware.dart';
import '../constants/app_constants.dart';

class BarberApiService {
  final ApiInterceptor _api = ApiInterceptor(timeout: const Duration(seconds: 10));

  Future<List<Map<String, dynamic>>> getBarbers() async {
    try {
      final response = await _api.get(Uri.parse('${ApiConstants.baseUrl}/barbers/public'));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> data = decoded is Map && decoded.containsKey('data') ? decoded['data'] : decoded;

        return data.map((b) {
          return {
            'id': b['id_usuario'],
            'name': '${b['prim_nombre']} ${b['apellido1']}',
            'specialty': b['portafolios']?['especialidades'] ?? 'Barbero Profesional',
            'specialties': (b['portafolios']?['especialidades'] ?? 'Cortes').toString().split(','),
            'rating': double.tryParse(b['portafolios']?['calificacion']?.toString() ?? '5.0') ?? 5.0,
            'reviews': b['portafolios']?['rese_as_count'] ?? 0,
            'experience': b['portafolios']?['experiencia'] ?? '5 años',
            'price': 'Desde \$25',
            'expression': 0,
            'isAvailable': b['estado'] == true,
            'status': b['estado'] == true ? 'Disponible' : 'Inactivo',
            // --- Campos de imagen de Cloudinary ---
            'photoUrl': b['foto_perfil_url'],
            'portfolioPhotos': b['portafolios']?['fotos_portafolio_urls'] ?? [],
          };
        }).toList();
      } else {
        throw Exception('Error al cargar barberos: ${response.statusCode}');
      }
    } catch (e) {
      print('BarberApiService error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getBarberById(int id) async {
    try {
      final response = await _api.get(Uri.parse('${ApiConstants.baseUrl}/barbers/$id'));

      if (response.statusCode == 200) {
        final b = json.decode(response.body);
        return {
          'id': b['id_usuario'],
          'name': '${b['prim_nombre']} ${b['apellido1']}',
          'specialty': b['portafolios']?['especialidades'] ?? 'Barbero Profesional',
          'rating': double.tryParse(b['portafolios']?['calificacion']?.toString() ?? '5.0') ?? 5.0,
          'reviews': b['portafolios']?['rese_as_count'] ?? 0,
          'experience': b['portafolios']?['experiencia'] ?? '5 años',
          'biography': b['portafolios']?['biografia'] ?? 'Sin biografía.',
          'services': b['barberos_servicios'] ?? [],
          // --- Campos de imagen de Cloudinary ---
          'photoUrl': b['foto_perfil_url'],
          'portfolioPhotos': b['portafolios']?['fotos_portafolio_urls'] ?? [],
        };
      }
      return null;
    } catch (e) {
      print('Error getBarberById: $e');
      return null;
    }
  }
}

