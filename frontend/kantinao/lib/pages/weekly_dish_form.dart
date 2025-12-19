import 'package:flutter/material.dart';
import '../models/week_menu.dart';
import '../services/menu_service.dart';
import 'package:uuid/uuid.dart';

class WeeklyDishForm extends StatefulWidget {
  const WeeklyDishForm({super.key});

  @override
  State<WeeklyDishForm> createState() => _WeeklyDishFormState();
}

class _WeeklyDishFormState extends State<WeeklyDishForm> {
  final MenuService service = MenuService();

  late int _selectedWeek;
  final List<String> _days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];
  late WeekMenu _weekMenu;

  List<WeekMenu> _allMenus = [];
  bool _loadingMenus = true;
  bool _loading = false;

  final Map<String, TextEditingController> _controllers = {};

@override
void initState() {
  super.initState();
  final now = DateTime.now();
  _selectedWeek = _getIsoWeekNumber(now);

  _initEmptyMenu();
  _fetchMenus();
}

  Future<void> _fetchMenus() async {
    try {
      final menus = await service.getAllMenus();
      setState(() {
        _allMenus = menus;
        _loadingMenus = false;
      });
    } catch (e) {
      setState(() => _loadingMenus = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load menus: $e')),
      );
    }
  }

Future<void> _initEmptyMenu() async {
  setState(() => _loading = true);

  try {
    final menu = await service.getMenuByWeek(_selectedWeek);
    _weekMenu = menu;

    for (var day in _days) {
      final item = menu.dayMenuItems.firstWhere(
        (item) => item.dayOfWeek == day,
        orElse: () => DayMenuItem(dayOfWeek: day),
      );

      final dishName = item.dish?.name ?? '';

      if (_controllers.containsKey(day)) {
        _controllers[day]!.text = dishName;
      } else {
        _controllers[day] = TextEditingController(text: dishName);
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to fetch menu for week $_selectedWeek: $e')),
    );
  } finally {
    setState(() => _loading = false);
  }
}

  Future<void> _submitMenu() async {
    setState(() => _loading = true);

    for (var item in _weekMenu.dayMenuItems) {
      final name = _controllers[item.dayOfWeek]?.text ?? '';
      if (name.isNotEmpty) {
        item.dish = Dish(
          id: const Uuid().v4(),
          name: name,
        );
      }
    }

    try {
      await service.createMenu(_weekMenu);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu submitted successfully')),
      );

      // Refresh menus list
      _fetchMenus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit menu: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  int _getIsoWeekNumber(DateTime date) {
    final thursday = date.add(Duration(days: 4 - (date.weekday % 7)));
    final firstJan = DateTime(thursday.year, 1, 1);
    final diff = thursday.difference(firstJan).inDays;
    return ((diff / 7).floor() + 1);
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ListView(
                  children: [
                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_left),
                          onPressed: () {
                            setState(() {
                              _selectedWeek = (_selectedWeek - 2) % 52 + 1;
                            });
                            _initEmptyMenu();
                          },
                        ),

                        const SizedBox(width: 12), // 👈 gap
                        Text(
                          'Week $_selectedWeek',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12), // 👈 gap
                        IconButton(
                          icon: const Icon(Icons.arrow_right),
                          onPressed: () {
                            setState(() {
                              _selectedWeek = _selectedWeek % 52 + 1;
                            });
                            _initEmptyMenu();
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // INPUT FIELDS
                    for (var day in _days)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: TextField(
                          controller: _controllers[day],
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: day,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            filled: true,
                          ),
                        ),
                      ),

                    const SizedBox(height: 30),

                    const SizedBox(height: 30),

                    ElevatedButton(
                      onPressed: _submitMenu,
                      child: const Text('Submit Weekly Menu'),
                    ),

                    // EXISTING MENUS SECTION
                    const Divider(height: 40),

                    const Text(
                      "Existing Menus",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),


                    if (_loadingMenus)
                      const Center(child: CircularProgressIndicator())
                    else if (_allMenus.isEmpty)
                      const Text("No menus found.")
                    else
                      _buildMenusList(),

                    
                  ],
                ),
              ),
            ),
          );
  }

  Widget _buildMenusList() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var menu in _allMenus)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Week ${menu.week} – ${menu.name}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),

                    for (var item in menu.dayMenuItems)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item.dayOfWeek),
                          Text(item.dish?.name ?? "—"),
                        ],
                      ),

                    const Divider(height: 30),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
