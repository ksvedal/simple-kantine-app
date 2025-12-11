import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

// ------------------------
// APP ROOT
// ------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MenuState(),
      child: MaterialApp(
        title: 'Kantinemeny',
        theme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: Colors.deepOrange,
            secondary: Colors.orangeAccent,
          ),
          scaffoldBackgroundColor: Colors.grey[900],
          cardColor: Colors.grey[850],
          iconTheme: IconThemeData(color: Colors.orangeAccent),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Colors.orangeAccent),
          ),
        ),
        home: MenuPage(),
      ),
    );
  }
}

// ------------------------
// MODEL
// ------------------------
class MenuItem {
  final String name;
  final List<String>? allergens;
  final int? spiceLevel;

  int likes = 0;

  MenuItem({required this.name, this.allergens, this.spiceLevel});
}

// ------------------------
// STATE (TEMP DATA)
// ------------------------
class MenuState extends ChangeNotifier {
  final Map<String, MenuItem> week1 = {
    "Måndag": MenuItem(
      name: "Kyllingpasta",
      allergens: ["Gluten", "Melk"],
      spiceLevel: 1,
    ),
    "Tysdag": MenuItem(name: "Grønsakscurry", allergens: [], spiceLevel: 2),
    "Onsdag": MenuItem(name: "Biff Taco", allergens: ["Gluten"], spiceLevel: 3),
    "Torsdag": MenuItem(
      name: "Fisk og ris",
      allergens: ["Fisk"],
      spiceLevel: 0,
    ),
    "Fredag": MenuItem(
      name: "Pizza buffet",
      allergens: ["Gluten", "Melk"],
      spiceLevel: 0,
    ),
  };

  final Map<String, MenuItem> week2 = {
    "Måndag": MenuItem(name: "Kyllingsuppe", allergens: [], spiceLevel: 1),
    "Tysdag": MenuItem(
      name: "Grønnsakslasagne",
      allergens: ["Gluten", "Melk"],
      spiceLevel: 0,
    ),
    "Onsdag": MenuItem(name: "Chili con carne", allergens: [], spiceLevel: 3),
    "Torsdag": MenuItem(name: "Laksbolle", allergens: ["Fisk"], spiceLevel: 1),
    "Fredag": MenuItem(name: "Bakt potetbar", allergens: [], spiceLevel: 0),
  };

  void like(String week, String day) {
    (week == "Veke 1" ? week1 : week2)[day]!.likes++;
    notifyListeners();
  }
}

// ------------------------
// UI
// ------------------------
class MenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var menuState = context.watch<MenuState>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Kantinemeny"),
          actions: [
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Administrator-innlogging ikkje implementert enda",
                    ),
                  ),
                );
              },
              child: Text("Admin-innlogging"),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: "Veke 1"),
              Tab(text: "Veke 2"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildWeekView("Veke 1", menuState.week1, context),
            _buildWeekView("Veke 2", menuState.week2, context),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekView(
    String weekLabel,
    Map<String, MenuItem> menu,
    BuildContext context,
  ) {
    return ListView(
      padding: EdgeInsets.all(12),
      children: menu.entries.map((entry) {
        final day = entry.key;
        final item = entry.value;

        final cardColor = item.likes > 0
            ? Colors.deepOrange.withOpacity(0.3)
            : Colors.grey[850];

        return Card(
          color: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  item.name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 6),
                if (item.allergens != null && item.allergens!.isNotEmpty)
                  Row(
                    children: [
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          "Allergen: ${item.allergens!.join(', ')}",
                          style: TextStyle(color: Colors.grey[300]),
                        ),
                      ),
                    ],
                  ),
                if (item.spiceLevel != null && item.spiceLevel! > 0)
                  Row(
                    children: [
                      SizedBox(width: 6),
                      Text(
                        "🌶️" * item.spiceLevel!,
                        style: TextStyle(color: Colors.grey[300]),
                      ),
                    ],
                  ),
                SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<MenuState>().like(weekLabel, day);
                      },
                      icon: Icon(Icons.thumb_up),
                      label: Text(item.likes.toString()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
