import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:elegant_cut_mobile/src/theme/app_theme.dart';
import 'package:elegant_cut_mobile/src/pages/splash_screen.dart';
import 'package:elegant_cut_mobile/src/utils/constants.dart';
import 'package:elegant_cut_mobile/src/services/notification_service.dart';

// Notificador global para el tema de la aplicación (Por defecto claro como pidió el usuario)
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase (con try/catch por si falta google-services.json)
  try {
    await Firebase.initializeApp();
    await NotificationService().initialize();
  } catch (e) {
    print('Firebase no configurado aún: $e');
  }

  // Cargar preferencia de tema guardada
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false; // Default: light (false)
  themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppConstants.appName,

          // Builder para ocultar el teclado en toda la app al tocar afuera
          builder: (context, child) {
            return GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: child,
            );
          },

          // Temas centralizados
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,

          // Página de inicio
          home: const SplashScreen(),
        );
      },
    );
  }
}
