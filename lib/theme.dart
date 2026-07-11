import 'package:flutter/material.dart';

const navy = Color(0xFF071A33);
const navyCard = Color(0xFF0D2748);
const navySoft = Color(0xFF12345D);
const atomyBlue = Color(0xFF168BFF);
const successGreen = Color(0xFF2CD889);
const warningOrange = Color(0xFFFFB24D);
const dangerRed = Color(0xFFFF5B70);
const mutedText = Color(0xFF9CB2CD);

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: atomyBlue,
    brightness: Brightness.dark,
    surface: navy,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme.copyWith(
      primary: atomyBlue,
      surface: navy,
      error: dangerRed,
    ),
    scaffoldBackgroundColor: navy,
    cardTheme: const CardThemeData(
      color: navyCard,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        side: BorderSide(color: Color(0xFF1D416B)),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF0A2240),
      labelStyle: TextStyle(color: mutedText),
      hintStyle: TextStyle(color: Color(0xFF6F89A8)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Color(0xFF214A77)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Color(0xFF214A77)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: atomyBlue, width: 1.6),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: atomyBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
  );
}
