import 'package:flutter/material.dart';

abstract final class MauSac {
  static const cam = Color(0xFFDA4E16);
  static const camnhat = Color(0xFFFFF0E6);
  static const chu = Color(0xFF26251F);
  static const chuphu = Color(0xFF706D63);
  static const nen = Color(0xFFFAF9F6);
  static const vien = Color(0xFFE9E5DD);
  static const xanh = Color(0xFF23664B);
  static const xanhnhat = Color(0xFFEAF4EC);

  static ThemeData get chude => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: nen,
    colorScheme: ColorScheme.fromSeed(
      seedColor: cam,
    ).copyWith(primary: cam, surface: nen),
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: chu),
      bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: chu),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: nen,
      foregroundColor: chu,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: chu,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: vien),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: vien),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: cam, width: 1.5),
      ),
      labelStyle: const TextStyle(color: Color(0xFF706D63), fontSize: 14),
      floatingLabelStyle: const TextStyle(color: cam),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: cam,
        textStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
