import 'package:flutter/material.dart';

class AppTheme {
  // Hacemos el constructor privado para que no se pueda instanciar
  AppTheme._();

  // Colores principales del diseño
  static const Color primaryBlue = Color(0xFF0A2C52); // Azul oscuro del fondo
  static const Color primaryOrange = Color(0xFFD97938); // Naranja para botones y acentos
  static const Color lightGray = Color(0xFFB8C5D6); // Gris claro para figuras
  static const Color white = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFF6B7280);
  static const Color subtitleBlue = Color(0xFF5A7BA6);

  static ThemeData getTheme() {
    return ThemeData(
      // --- COLORES PRINCIPALES ---
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: primaryBlue,
      colorScheme: ColorScheme.light(primary: primaryBlue, secondary: primaryOrange, error: const Color(0xFFEF4444)),

      // --- TEMA PARA CAMPOS DE TEXTO ---
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: primaryBlue, width: 2.0),
        ),
        labelStyle: const TextStyle(color: textGray, fontSize: 14),
        hintStyle: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 14),
      ),

      // --- TEMA PARA BOTONES ELEVADOS ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),

      // --- TEMA PARA TEXTO ---
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryBlue),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: subtitleBlue),
      ),
    );
  }
}
