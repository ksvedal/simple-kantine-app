
class Dish {
  final String id;
  final String name;
  final String? description;
  final double? price;
  final String? allergens;
  final String? spiceLevel;

  Dish({
    required this.id,
    required this.name,
    this.description,
    this.price,
    this.allergens,
    this.spiceLevel,
  });

  factory Dish.fromJson(Map<String, dynamic> json) => Dish(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        price: (json['price'] ?? 0).toDouble(),
        allergens: json['allergens'],
        spiceLevel: json['spice_level'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'allergens': allergens,
        'spice_level': spiceLevel,
      };
}

class DayMenuItem {
  final String id;
  final String dayOfWeek;
  int likes;
  Dish? dish;

  DayMenuItem({
    required this.id,
    required this.dayOfWeek,
    this.likes = 0,
    this.dish,
  });

  factory DayMenuItem.fromJson(Map<String, dynamic> json) => DayMenuItem(
        id: json['id'],
        dayOfWeek: json['day_of_week'],
        likes: json['likes'] ?? 0,
        dish: json['dish'] != null ? Dish.fromJson(json['dish']) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'day_of_week': dayOfWeek,
        'likes': likes,
        'dish': dish?.toJson(),
      };
}

class WeekMenu {
  final String id;
  final String name;
  final int week;
  final List<DayMenuItem> dayMenuItems;

  WeekMenu({
    required this.id,
    required this.name,
    required this.week,
    required this.dayMenuItems,
  });

  factory WeekMenu.fromJson(Map<String, dynamic> json) => WeekMenu(
        id: json['id'],
        name: json['name'],
        week: json['week'],
        dayMenuItems: (json['day_items'] as List)
            .map((e) => DayMenuItem.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'week': week,
        'day_items': dayMenuItems.map((e) => e.toJson()).toList(),
      };
}
