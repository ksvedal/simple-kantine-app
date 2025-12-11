import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeeklyDishForm extends StatefulWidget {
  const WeeklyDishForm({super.key});

  @override
  State<WeeklyDishForm> createState() => _WeeklyDishFormState();
}

class _WeeklyDishFormState extends State<WeeklyDishForm> {
  final List<String> _days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];
  late DateTime _currentWeekStart;
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    _initWeekStart();
    for (int i = 0; i < 7; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
  }

  void _initWeekStart() {
    final now = DateTime.now();
    _currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _nextWeek() => setState(() => _currentWeekStart = _currentWeekStart.add(const Duration(days: 7)));
  void _previousWeek() => setState(() => _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7)));

  void _submitAll() {
    final data = {for (int i = 0; i < 5; i++) _days[i]: _controllers[i].text};
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Weekly menu submitted"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weekNum = getIsoWeekNumber(_currentWeekStart);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(iconSize: 32, icon: const Icon(Icons.arrow_left), onPressed: _previousWeek),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text("Week $weekNum", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(iconSize: 32, icon: const Icon(Icons.arrow_right), onPressed: _nextWeek),
                ],
              ),
              const SizedBox(height: 20),
              for (int i = 0; i < 5; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: TextField(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText:
                          "${_days[i]} (${DateFormat('dd MMM').format(_currentWeekStart.add(Duration(days: i)))})",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                    ),
                    onSubmitted: (_) {
                      if (i < 6) FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
                      else _focusNodes[i].unfocus();
                    },
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitAll,
                  child: const Text("Submit Weekly Menu"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

int getIsoWeekNumber(DateTime date) {
  final thursday = date.add(Duration(days: 4 - (date.weekday % 7)));
  final firstJan = DateTime(thursday.year, 1, 1);
  final diff = thursday.difference(firstJan).inDays;
  return ((diff / 7).floor() + 1);
}
