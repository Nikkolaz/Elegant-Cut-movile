import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider extends ChangeNotifier {
  String _firstName = '';
  String _username = '';
  String _email = '';
  int? _idRol;

  String get firstName => _firstName;
  String get username => _username;
  String get email => _email;
  int? get idRol => _idRol;

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _firstName = prefs.getString('firstName') ?? '';
    _username = prefs.getString('username') ?? '';
    _email = prefs.getString('email') ?? '';
    _idRol = prefs.getInt('id_rol');
    notifyListeners();
  }

  Future<void> updateFirstName(String name) async {
    _firstName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', name);
    notifyListeners();
  }
}
