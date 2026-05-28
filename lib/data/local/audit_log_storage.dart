import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/audit_log_model.dart';

class AuditLogStorage {
  static const _key = 'audit.logs';
  static const _maxLogs = 500;

  Future<List<AuditLogModel>> readLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(AuditLogModel.fromMap)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return const [];
    }
  }

  Future<void> addLog(AuditLogModel log) async {
    final prefs = await SharedPreferences.getInstance();
    final logs = [log, ...await readLogs()];
    final trimmed = logs.take(_maxLogs).map((item) => item.toMap()).toList();
    await prefs.setString(_key, jsonEncode(trimmed));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
