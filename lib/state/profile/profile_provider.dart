import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/profile_api_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileApiService _profileApi = ProfileApiService();

  String _firstName = '';
  String _secondName = '';
  String _lastName1 = '';
  String _lastName2 = '';
  String _username = '';
  String _email = '';
  String _phone = '';
  String _profilePhoto = '';
  int? _idRol;
  int? _idUsuario;
  bool _estado = true;
  String _createdAt = '';
  String _updatedAt = '';
  bool _isLoading = false;
  String? _error;

  // Full profile data from API
  Map<String, dynamic>? _fullData;

  // Getters
  String get firstName => _firstName;
  String get secondName => _secondName;
  String get lastName1 => _lastName1;
  String get lastName2 => _lastName2;
  String get username => _username;
  String get email => _email;
  String get phone => _phone;
  String get profilePhoto => _profilePhoto;
  int? get idRol => _idRol;
  int? get idUsuario => _idUsuario;
  bool get estado => _estado;
  String get createdAt => _createdAt;
  String get updatedAt => _updatedAt;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get fullData => _fullData;

  String get fullName {
    final parts = [_firstName, _secondName, _lastName1, _lastName2]
        .where((s) => s.trim().isNotEmpty)
        .toList();
    return parts.isEmpty ? 'Usuario' : parts.join(' ');
  }

  String get displayName {
    final parts = [_firstName, _lastName1]
        .where((s) => s.trim().isNotEmpty)
        .toList();
    return parts.isEmpty ? 'Usuario' : parts.join(' ');
  }

  String get roleName {
    switch (_idRol) {
      case 1: return 'Administrador';
      case 3: return 'Barbero';
      default: return 'Cliente';
    }
  }

  /// Load profile from SharedPreferences (for initial fast load)
  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _firstName = prefs.getString('firstName') ?? '';
    _username = prefs.getString('username') ?? '';
    _email = prefs.getString('email') ?? '';
    _idRol = prefs.getInt('id_rol');
    _idUsuario = prefs.getInt('id_usuario');
    notifyListeners();

    // Then fetch full profile from API
    await fetchFullProfile();
  }

  /// Fetch complete profile from API endpoint GET /users/me
  Future<void> fetchFullProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _profileApi.getMyProfile();

      if (response['success'] == true) {
        final data = response['data'];
        _fullData = data;
        _idUsuario = data['id_usuario'];
        _username = data['username'] ?? '';
        _firstName = data['prim_nombre'] ?? '';
        _secondName = data['seg_nombre'] ?? '';
        _lastName1 = data['apellido1'] ?? '';
        _lastName2 = data['apellido2'] ?? '';
        _email = data['email'] ?? '';
        _phone = data['telefono'] ?? '';
        _profilePhoto = data['foto_perfil'] ?? '';
        _idRol = data['id_rol'];
        _estado = data['estado'] == true;
        _createdAt = data['created_at'] ?? '';
        _updatedAt = data['updated_at'] ?? '';

        // Sync to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('firstName', _firstName);
        await prefs.setString('username', _username);
        await prefs.setString('email', _email);
        if (_idRol != null) await prefs.setInt('id_rol', _idRol!);
        if (_idUsuario != null) await prefs.setInt('id_usuario', _idUsuario!);
      } else {
        _error = response['message'];
      }
    } catch (e) {
      _error = 'Error al cargar perfil: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update profile via PATCH /users/profile
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _profileApi.updateMyProfile(data);

      if (response['success'] == true) {
        // Refresh data from server
        await fetchFullProfile();
        return {'success': true, 'message': response['message']};
      } else {
        _error = response['message'];
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'message': response['message']};
      }
    } catch (e) {
      _error = 'Error de conexión';
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  Future<void> updateFirstName(String name) async {
    _firstName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', name);
    notifyListeners();
  }
}
