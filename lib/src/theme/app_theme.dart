import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de colores personalizada
  static const Color primaryGold = Color(0xFFD48B41);
  static const Color darkSurface = Color(0xFF121212);
  static const Color inputBackground = Color(0xFF1C1C1E);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryGold,
      scaffoldBackgroundColor: Colors.black,
      
      // Configuración del esquema de colores
      colorScheme: const ColorScheme.dark(
        primary: primaryGold,
        surface: darkSurface,
        onPrimary: Colors.white,
      ),
      
      // Configuración de Tipografía
      fontFamily: 'Roboto',
      
      // Estilo global de los inputs (opcional, para centralizar más)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: Colors.grey),
        contentPadding: const EdgeInsets.all(22),
      ),

      // Estilo de botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
