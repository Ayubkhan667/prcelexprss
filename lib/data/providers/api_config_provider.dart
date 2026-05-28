import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local/api_config_storage.dart';

class ApiConfig {
  final String apiUrl;
  final bool useRemote;

  const ApiConfig({required this.apiUrl, required this.useRemote});

  bool get isConfigured => apiUrl.isNotEmpty;
  bool get canUseRemote => useRemote && isConfigured;

  String get effectiveBaseUrl => canUseRemote ? apiUrl : '';

  ApiConfig copyWith({String? apiUrl, bool? useRemote}) => ApiConfig(
        apiUrl: apiUrl ?? this.apiUrl,
        useRemote: useRemote ?? this.useRemote,
      );
}

class ApiConfigNotifier extends Notifier<ApiConfig> {
  ApiConfigNotifier({required ApiConfig initial})
      : _initial = ApiConfig(
          apiUrl: ApiConfigStorage.normalizeApiUrl(initial.apiUrl),
          useRemote: initial.useRemote,
        );

  final ApiConfig _initial;

  @override
  ApiConfig build() => _initial;

  Future<void> setApiUrl(String url) async {
    final normalized = ApiConfigStorage.normalizeApiUrl(url);
    await ApiConfigStorage().saveApiUrl(normalized);
    state = state.copyWith(apiUrl: normalized);
  }

  Future<void> setUseRemote(bool value) async {
    await ApiConfigStorage().saveUseRemote(value);
    state = state.copyWith(useRemote: value);
  }
}

// Overridden in main.dart with the actual loaded config.
final apiConfigProvider = NotifierProvider<ApiConfigNotifier, ApiConfig>(() {
  return ApiConfigNotifier(
    initial: const ApiConfig(apiUrl: '', useRemote: true),
  );
});
