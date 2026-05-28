class RemotePayloadParser {
  static List<Map<String, dynamic>> parseList(dynamic data) {
    final list = _extractList(data);
    if (list == null) {
      return const [];
    }

    return list
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static Map<String, dynamic> parseMap(dynamic data) {
    final map = parseOptionalMap(data);
    if (map == null) {
      throw const FormatException('Response payload is not a JSON object.');
    }

    return map;
  }

  static Map<String, dynamic>? parseOptionalMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return _extractNestedMap(data) ?? data;
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      return _extractNestedMap(map) ?? map;
    }

    return null;
  }

  static Map<String, dynamic>? nestedMap(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];
      if (value is Map<String, dynamic>) {
        return value;
      }
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
    }

    return null;
  }

  static String? readString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  static List<dynamic>? _extractList(dynamic data) {
    if (data is List) {
      return data;
    }

    final map = parseOptionalMap(data);
    if (map == null) {
      return null;
    }

    for (final key in const ['data', 'items', 'results', 'records']) {
      final value = map[key];
      if (value is List) {
        return value;
      }
    }

    for (final value in map.values) {
      if (value is List) {
        return value;
      }
    }

    return null;
  }

  static Map<String, dynamic>? _extractNestedMap(Map<String, dynamic> data) {
    for (final key in const ['data', 'item', 'result', 'record']) {
      final value = data[key];
      if (value is Map<String, dynamic>) {
        return value;
      }
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
    }

    return null;
  }
}
