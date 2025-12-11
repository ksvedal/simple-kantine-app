import 'package:flutter/material.dart';

// --- Light Theme ---
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.deepOrange,
  colorScheme: ColorScheme.light(
    primary: Colors.deepOrange,
    secondary: Colors.teal,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(),
    filled: true,
    fillColor: Color(0xFFF5F5F5),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.deepOrange,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  ),
);

// --- Dark Theme ---
final ThemeData darkTheme = ThemeData.dark().copyWith(
  primaryColor: const Color.fromARGB(255, 255, 238, 212),
  scaffoldBackgroundColor: const Color.fromARGB(255, 56, 37, 52),
  colorScheme: const ColorScheme.dark(
    primary: Color.fromARGB(255, 42, 28, 39),
    secondary: Colors.orangeAccent,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color.fromARGB(255, 42, 28, 39),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Color.fromARGB(255, 254, 229, 86),
        width: 2,
      ),
    ),
    floatingLabelStyle: const TextStyle(
      color: Color.fromARGB(255, 254, 229, 86),
      fontWeight: FontWeight.bold,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 254, 229, 86),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  ),
);
