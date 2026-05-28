import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HrSettingsStorage {
  static const _key = 'hr.settings';

  Future<Map<String, dynamic>?> readSettingsMap() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  Future<void> saveSettingsMap(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(settings));
  }
}
