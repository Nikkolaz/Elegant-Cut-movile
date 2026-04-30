import 'package:flutter/material.dart';
import 'package:elegant_cut_mobile/src/theme/app_theme.dart';
import 'package:elegant_cut_mobile/src/pages/login_page.dart';
import 'package:elegant_cut_mobile/src/utils/constants.dart';

 feature/Form_registro

void main() => runApp(const MyApp());
=======
void main() {
  runApp(const MyApp());
}
} develop

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      
      // Usamos el tema centralizado
      theme: AppTheme.darkTheme,
      
      // Página de inicio
      home: const LoginPage(),
    );
  }
}
