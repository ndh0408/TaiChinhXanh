class Category {
  final int? id;
  final String name;
  final String type;
  final String color;
  final String icon;
  final double budgetLimit;
  final bool isEssential;
  final int priority;

  Category({
    this.id,
    required this.name,
    required this.type,
    required this.color,
    required this.icon,
    required this.budgetLimit,
    required this.isEssential,
    required this.priority,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      color: map['color'],
      icon: map['icon'],
      budgetLimit: map['budget_limit'],
      isEssential: map['is_essential'] == 1,
      priority: map['priority'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'color': color,
      'icon': icon,
      'budget_limit': budgetLimit,
      'is_essential': isEssential ? 1 : 0,
      'priority': priority,
    };
  }
}

