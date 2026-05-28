import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/utils/tap_effects.dart';
import 'data/providers/app_providers.dart';
import 'data/providers/locale_provider.dart';

class PEAttendanceApp extends ConsumerStatefulWidget {
  const PEAttendanceApp({super.key});

  @override
  ConsumerState<PEAttendanceApp> createState() => _PEAttendanceAppState();
}

class _PEAttendanceAppState extends ConsumerState<PEAttendanceApp> {
  @override
  void initState() {
    super.initState();
    ref.read(localeProvider.notifier).init();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(autoRefreshProvider);
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Parcel Express',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => AppSoundScope(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
