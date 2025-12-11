import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      home: const WeeklyDishForm(),
    );
  }
}

class WeeklyDishForm extends StatefulWidget {
  const WeeklyDishForm({super.key});

  @override
  State<WeeklyDishForm> createState() => _WeeklyDishFormState();
}

class _WeeklyDishFormState extends State<WeeklyDishForm> {
  final List<String> _days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

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
    final weekday = now.weekday; // Monday = 1, Sunday = 7
    _currentWeekStart = now.subtract(Duration(days: weekday - 1));
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  int _weekNumber(DateTime date) {
    return int.parse(DateFormat("w").format(date));
  }

  void _nextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    });
  }

  void _previousWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    });
  }

  void _submitAll() {
    final data = {
      for (int i = 0; i < 7; i++) _days[i]: _controllers[i].text
    };

    // TODO: send to backend or save

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Weekly menu submitted")),
    );
  }

  @override
  Widget build(BuildContext context) {
final weekNum = getIsoWeekNumber(_currentWeekStart);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_left),
              onPressed: _previousWeek,
            ),
            Text("Week $weekNum"),
            IconButton(
              icon: const Icon(Icons.arrow_right),
              onPressed: _nextWeek,
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            for (int i = 0; i < 7; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: TextField(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: "${_days[i]} (${DateFormat('dd MMM').format(_currentWeekStart.add(Duration(days: i)))})",
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) {
                    if (i < 6) {
                      FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
                    } else {
                      _focusNodes[i].unfocus();
                    }
                  },
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitAll,
              child: const Text("Submit Weekly Menu"),
            ),
          ],
        ),
      ),
    );
  }
}

int getIsoWeekNumber(DateTime date) {
  // Adjust to Thursday in the same week
  final thursday = date.add(Duration(days: 4 - (date.weekday % 7)));
  final firstJan = DateTime(thursday.year, 1, 1);
  final diff = thursday.difference(firstJan).inDays;
  return ((diff / 7).floor() + 1);
}

