import 'package:flutter/material.dart';
import 'themes.dart';
import 'pages/weekly_dish_form.dart';
import 'widgets/app_drawer.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark, // Change to ThemeMode.light if needed
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget _currentPage = const WeeklyDishForm();

  void _selectPage(Widget page) {
    setState(() {
      _currentPage = page;
    });
    Navigator.pop(context); // Close drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kantinao"),
      ),
      drawer: AppDrawer(
        onSelectPage: _selectPage,
      ),
      body: _currentPage,
    );
  }
}
