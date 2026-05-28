import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'app.dart';
import 'core/constants/app_constants.dart';
import 'data/local/api_config_storage.dart';
import 'data/local/hr_settings_storage.dart';
import 'data/providers/api_config_provider.dart';
import 'data/providers/settings_provider.dart';
import 'data/services/notification_service.dart';
import 'core/utils/tap_effects.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    setUrlStrategy(const HashUrlStrategy());
  }

  await NotificationService().init();
  await NotificationService().requestPermissions();
  SoundService.instance.init();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  final storage = ApiConfigStorage();
  final storedApiUrl = await storage.readApiUrl();
  final storedUseRemote = await storage.readUseRemote();
  final storedSettings = await HrSettingsStorage().readSettingsMap();
  final apiUrl = AppConstants.hasConfiguredApiBaseUrl
      ? ApiConfigStorage.normalizeApiUrl(AppConstants.apiBaseUrl)
      : storedApiUrl;
  final useRemote = AppConstants.canUseRemoteData ? true : storedUseRemote;

  runApp(
    ProviderScope(
      overrides: [
        apiConfigProvider.overrideWith(() => ApiConfigNotifier(
              initial: ApiConfig(apiUrl: apiUrl, useRemote: useRemote),
            )),
        hrSettingsProvider.overrideWith(() => HrSettingsNotifier(
              initial: storedSettings == null
                  ? const HrSettings()
                  : HrSettings.fromMap(storedSettings),
            )),
      ],
      child: const PEAttendanceApp(),
    ),
  );
}
