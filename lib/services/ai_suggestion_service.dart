import '../db/db_init.dart';
import '../models/ai_suggestion.dart';

class AISuggestionService {
  static Future<int> insert(AISuggestion suggestion) async {
    final db = await AppDatabase.database;
    return await db.insert('ai_suggestions', suggestion.toMap());
  }

  static Future<List<AISuggestion>> getAll() async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ai_suggestions',
      orderBy: 'priority DESC, created_at DESC',
    );
    return List.generate(maps.length, (i) => AISuggestion.fromMap(maps[i]));
  }

  static Future<List<AISuggestion>> getUnread() async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ai_suggestions',
      where: 'is_read = ?',
      whereArgs: [0],
      orderBy: 'priority DESC, created_at DESC',
    );
    return List.generate(maps.length, (i) => AISuggestion.fromMap(maps[i]));
  }

  static Future<List<AISuggestion>> getByType(String type) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ai_suggestions',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'priority DESC, created_at DESC',
    );
    return List.generate(maps.length, (i) => AISuggestion.fromMap(maps[i]));
  }

  static Future<AISuggestion?> getById(int id) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ai_suggestions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return AISuggestion.fromMap(maps.first);
    }
    return null;
  }

  static Future<int> update(AISuggestion suggestion) async {
    final db = await AppDatabase.database;
    return await db.update(
      'ai_suggestions',
      suggestion.toMap(),
      where: 'id = ?',
      whereArgs: [suggestion.id],
    );
  }

  static Future<int> delete(int id) async {
    final db = await AppDatabase.database;
    return await db.delete('ai_suggestions', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> markAsRead(int id) async {
    final db = await AppDatabase.database;
    return await db.update(
      'ai_suggestions',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> markAllAsRead() async {
    final db = await AppDatabase.database;
    return await db.update(
      'ai_suggestions',
      {'is_read': 1},
      where: 'is_read = ?',
      whereArgs: [0],
    );
  }

  static Future<int> getUnreadCount() async {
    final db = await AppDatabase.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ai_suggestions WHERE is_read = 0',
    );
    return result.first['count'] as int;
  }

  static Future<List<AISuggestion>> getHighPriority() async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ai_suggestions',
      where: 'priority >= ?',
      whereArgs: [4],
      orderBy: 'priority DESC, created_at DESC',
    );
    return List.generate(maps.length, (i) => AISuggestion.fromMap(maps[i]));
  }

  static Future<int> deleteOldSuggestions(int daysToKeep) async {
    final db = await AppDatabase.database;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    return await db.delete(
      'ai_suggestions',
      where: 'created_at < ? AND is_read = 1',
      whereArgs: [cutoffDate.toIso8601String()],
    );
  }
}

