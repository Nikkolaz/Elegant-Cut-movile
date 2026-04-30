import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class AuthService {
  final String _baseUrl = ApiConstants.baseUrl;

  /// Método para iniciar sesión conectando con el backend NestJS
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final url = Uri.parse('$_baseUrl${ApiConstants.login}');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'contrasena': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'token': data['token'],
          'user': data['user'],
          'message': data['message'] ?? 'Inicio de sesión exitoso'
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al iniciar sesión',
        };
      }
    } catch (e) {
      print('Error en login: $e');
      return {
        'success': false,
        'message': 'No se pudo conectar con el servidor',
      };
    }
  }

  /// Método para registrar un nuevo usuario
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String firstName,
    String? secondName,
    required String lastName1,
    String? lastName2,
    String? phone,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl${ApiConstants.register}');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'prim_nombre': firstName,
          'seg_nombre': secondName ?? '',
          'apellido1': lastName1,
          'apellido2': lastName2 ?? '',
          'telefono': phone ?? '',
          'password_hash':
              password, // El backend espera password_hash según React
          'id_rol': 2,
          'estado': true,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'message': 'Registro exitoso', 'user': data};
      } else {
        return {
          'success': false,
          'message': data['message'] is List
              ? (data['message'] as List).join(', ')
              : data['message'] ?? 'Error al registrarse',
        };
      }
    } catch (e) {
      print('Error en registro: $e');
      return {
        'success': false,
        'message': 'No se pudo conectar con el servidor',
      };
    }
  }
}
