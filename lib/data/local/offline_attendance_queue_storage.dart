import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/offline_attendance_queue_item.dart';

class OfflineAttendanceQueueStorage {
  static const _key = 'attendance.offline_queue';

  Future<List<OfflineAttendanceQueueItem>> readItems() async {
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
          .map(OfflineAttendanceQueueItem.fromMap)
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } catch (_) {
      return const [];
    }
  }

  Future<void> add(OfflineAttendanceQueueItem item) async {
    final items = [...await readItems(), item];
    await _save(items);
  }

  Future<void> remove(String id) async {
    final items = (await readItems()).where((item) => item.id != id).toList();
    await _save(items);
  }

  Future<void> clear() => _save(const []);

  Future<void> _save(List<OfflineAttendanceQueueItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(items.map((item) => item.toMap()).toList()),
    );
  }
}
