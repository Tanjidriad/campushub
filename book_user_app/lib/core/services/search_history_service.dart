import 'package:shared_preferences/shared_preferences.dart';

/// Persists recent search queries for home chips and "because you searched" copy.
class SearchHistoryService {
  static const _key = 'search_recent_queries';
  static const _maxItems = 8;

  Future<List<String>> getRecentQueries() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  /// Most recent successful query (for personalization subtitle).
  Future<String?> getLastQuery() async {
    final list = await getRecentQueries();
    return list.isEmpty ? null : list.first;
  }

  Future<void> addQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final list = List<String>.from(prefs.getStringList(_key) ?? []);
    list.remove(trimmed);
    list.insert(0, trimmed);
    while (list.length > _maxItems) {
      list.removeLast();
    }
    await prefs.setStringList(_key, list);
  }

  Future<void> removeQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final list = List<String>.from(prefs.getStringList(_key) ?? []);
    list.remove(query);
    await prefs.setStringList(_key, list);
  }
}
