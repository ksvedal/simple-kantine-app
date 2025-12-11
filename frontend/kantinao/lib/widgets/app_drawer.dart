import 'package:flutter/material.dart';
import '../pages/weekly_dish_form.dart';
import '../pages/another_page.dart';

class AppDrawer extends StatelessWidget {
  final void Function(Widget) onSelectPage;

  const AppDrawer({super.key, required this.onSelectPage});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepOrange),
            child: Center(
              child: Text("Menu", style: TextStyle(fontSize: 24, color: Colors.white)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: const Text("Weekly Dish Form"),
            onTap: () => onSelectPage(const WeeklyDishForm()),
          ),
          ListTile(
            leading: const Icon(Icons.pages),
            title: const Text("Another Page"),
            onTap: () => onSelectPage(const AnotherPage()),
          ),
        ],
      ),
    );
  }
}
