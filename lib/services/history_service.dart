import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/history_item.dart';

class HistoryService {
  static const String key =
      "analysis_history";

  Future<void> saveHistory(
      HistoryItem item) async {
    final prefs =
    await SharedPreferences.getInstance();

    List<String> history =
        prefs.getStringList(key) ?? [];

    history.insert(
      0,
      jsonEncode(item.toJson()),
    );

    await prefs.setStringList(
      key,
      history,
    );
  }

  Future<List<HistoryItem>>
  getHistory() async {
    final prefs =
    await SharedPreferences.getInstance();

    List<String> history =
        prefs.getStringList(key) ?? [];

    return history
        .map(
          (e) => HistoryItem.fromJson(
        jsonDecode(e),
      ),
    )
        .toList();
  }

  Future<void> clearHistory()
  async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.remove(key);
  }
}