import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/utils/tap_effects.dart';
import 'data/providers/app_providers.dart';

class PEAttendanceApp extends ConsumerWidget {
  const PEAttendanceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(autoRefreshProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Parcel Express',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => AppSoundScope(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
