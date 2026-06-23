import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:elegant_cut_mobile/src/api/api_middleware.dart';
import 'package:elegant_cut_mobile/src/utils/constants.dart';

class ServicesApiService {
  final ApiInterceptor _api = ApiInterceptor();

  Future<List<Map<String, dynamic>>> getServices() async {
    try {
      final res = await _api.get(Uri.parse('${ApiConstants.baseUrl}/services'));

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        final List<dynamic> data = decoded is Map && decoded.containsKey('data') ? decoded['data'] : decoded;
        final colorsList = [
          const Color(0xFF2C2C2E), // Oscuro
          const Color(0xFF88C9F9), // Azul claro
          const Color(0xFFB4B0FE), // Morado pastel
          const Color(0xFFFFD56B), // Amarillo pastel
          const Color(0xFF98E68E), // Verde pastel
        ];

        return data.asMap().entries.map((entry) {
          int index = entry.key;
          var s = entry.value;

          final isDarkBg = index % 5 == 0;
          final bgColor = colorsList[index % colorsList.length];

          return <String, dynamic>{
            'id': s['id_servicio'],
            'title': s['nombre'],
            'duration': '${s['duracion']} min',
            'price': s['precio']?.toString() ?? '0',
            'category': s['categorias']?['nombre'] ?? 'Servicio',
            'category_id': s['id_categoria'] ?? 1,
            'description': s['descripcion'],
            'image': s['imagen'],
            // UI Properties for Cards
            'bgColor': bgColor,
            'titleColor': isDarkBg ? Colors.white : const Color(0xFF1E1E1E),
            'iconData': Icons.content_cut_rounded,
            'iconBgColor': Colors.white.withOpacity(0.3),
            'iconColor': isDarkBg ? const Color(0xFFD48B41) : const Color(0xFF1E1E1E),
            'tagText': 'TOP',
            'tagColor': isDarkBg ? const Color(0xFFD48B41) : const Color(0xFF2C2C2E).withOpacity(0.6),
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
