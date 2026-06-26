import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elegant_cut_mobile/core/theme/app_theme.dart';
import 'package:elegant_cut_mobile/core/constants/app_constants.dart';
import 'package:elegant_cut_mobile/features/splash/splash_screen.dart';
import 'package:elegant_cut_mobile/state/theme_provider.dart';
import 'package:elegant_cut_mobile/state/auth/auth_provider.dart';
import 'package:elegant_cut_mobile/state/profile/profile_provider.dart';
import 'package:elegant_cut_mobile/state/booking/booking_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppConstants.appName,
            builder: (context, child) {
              return GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: child,
              );
            },
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
