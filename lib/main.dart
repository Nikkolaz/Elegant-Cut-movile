import 'package:flutter/material.dart';
// Puente de la pantalla de login de la primera pantalla uwu
import 'package:elegant_cut_mobile/src/pages/login_page.dart';


void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Elegant Cut',
      //aca definimos el fondo
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFD48B41),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD48B41),
          surface: Color(0xFF121212),
        ),
        fontFamily: 'Roboto',
      ),

      home: const LoginPage(),
    );
  }
}
