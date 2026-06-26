import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _username;
  String? _firstName;
  String? _token;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get username => _username;
  String? get firstName => _firstName;
  String? get token => _token;
  String? get error => _error;

  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _username = prefs.getString('username');
    _firstName = prefs.getString('firstName');
    _isLoggedIn = _token != null;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(username, password);

      if (response['success'] == true) {
        _token = response['token'];
        final user = response['user'];
        _username = user?['username'] ?? username;
        _firstName = user?['prim_nombre'] ?? '';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('username', _username!);
        await prefs.setString('firstName', _firstName!);
        await prefs.setInt('id_usuario', user?['id_usuario'] ?? user?['id'] ?? 0);
        await prefs.setInt('id_rol', user?['id_rol'] ?? 2);
        await prefs.setString('email', user?['email'] ?? '');

        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Error al iniciar sesión';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle(String idToken) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.loginWithGoogle(idToken);

      if (response['success'] == true) {
        _token = response['token'];
        final user = response['user'];
        _username = user?['username'] ?? '';
        _firstName = user?['prim_nombre'] ?? '';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('username', _username!);
        await prefs.setString('firstName', _firstName!);
        await prefs.setInt('id_usuario', user?['id_usuario'] ?? user?['id'] ?? 0);
        await prefs.setInt('id_rol', user?['id_rol'] ?? 2);
        await prefs.setString('email', user?['email'] ?? '');

        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Error al iniciar sesión con Google';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String firstName,
    String? secondName,
    required String lastName1,
    String? lastName2,
    String? phone,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.register(
        username: username,
        email: email,
        firstName: firstName,
        secondName: secondName,
        lastName1: lastName1,
        lastName2: lastName2,
        phone: phone,
        password: password,
      );

      if (response['success'] == true) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Error al registrarse';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _clearSession();
    notifyListeners();
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('username');
    await prefs.remove('firstName');
    _token = null;
    _username = null;
    _firstName = null;
    _isLoggedIn = false;
  }
}
