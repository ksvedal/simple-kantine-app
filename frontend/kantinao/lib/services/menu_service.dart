import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/week_menu.dart';

class MenuService {
  final String baseUrl = 'http://localhost:7420';

  Future<List<WeekMenu>> getAllMenus() async {
    final response = await http.get(Uri.parse('$baseUrl/menus'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => WeekMenu.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch menus');
    }
  }

  Future<void> createMenu(WeekMenu menu) async {
    final response = await http.post(
      Uri.parse('$baseUrl/menus'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(menu.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create menu');
    }
  }
}
