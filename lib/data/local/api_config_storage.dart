import 'package:shared_preferences/shared_preferences.dart';

class ApiConfigStorage {
  static const _keyApiUrl = 'config.api_url';
  static const _keyUseRemote = 'config.use_remote';

  Future<String> readApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return _normalizeApiUrl(prefs.getString(_keyApiUrl) ?? '');
  }

  Future<void> saveApiUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyApiUrl, _normalizeApiUrl(url));
  }

  Future<bool> readUseRemote() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyUseRemote) ?? true;
  }

  Future<void> saveUseRemote(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUseRemote, value);
  }

  static String normalizeApiUrl(String url) => _normalizeApiUrl(url);

  static String _normalizeApiUrl(String url) {
    var normalized = url.trim();
    if (normalized.isEmpty) {
      return '';
    }

    normalized = normalized.replaceFirst(RegExp(r'/+$'), '');
    if (!normalized.toLowerCase().endsWith('/api')) {
      normalized = '$normalized/api';
    }

    return normalized;
  }
}
