class AISuggestion {
  final int? id;
  final String type;
  final String title;
  final String content;
  final int priority;
  final bool isRead;
  final String? triggerConditions;
  final DateTime createdAt;

  AISuggestion({
    this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.priority,
    required this.isRead,
    this.triggerConditions,
    required this.createdAt,
  });

  factory AISuggestion.fromMap(Map<String, dynamic> map) {
    return AISuggestion(
      id: map['id'],
      type: map['type'],
      title: map['title'],
      content: map['content'],
      priority: map['priority'],
      isRead: map['is_read'] == 1,
      triggerConditions: map['trigger_conditions'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'content': content,
      'priority': priority,
      'is_read': isRead ? 1 : 0,
      'trigger_conditions': triggerConditions,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

