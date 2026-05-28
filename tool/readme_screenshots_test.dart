import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pe_attendance/core/theme/app_theme.dart';
import 'package:pe_attendance/data/models/user_model.dart';
import 'package:pe_attendance/data/providers/api_config_provider.dart';
import 'package:pe_attendance/data/providers/auth_provider.dart';
import 'package:pe_attendance/data/providers/settings_provider.dart';
import 'package:pe_attendance/presentation/screens/admin/admin_dashboard_screen.dart';
import 'package:pe_attendance/presentation/screens/admin/backup_export_screen.dart';
import 'package:pe_attendance/presentation/screens/admin/settings_screen.dart';
import 'package:pe_attendance/presentation/screens/admin/task_management_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('captures README screenshots', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));

    await _capture(
      tester,
      const AdminDashboardScreen(),
      '../docs/screenshots/admin-dashboard.png',
    );
    await _capture(
      tester,
      const TaskManagementScreen(),
      '../docs/screenshots/task-cards.png',
    );
    await _capture(
      tester,
      const BackupExportScreen(),
      '../docs/screenshots/backup-export.png',
    );
    await _capture(
      tester,
      const SettingsScreen(),
      '../docs/screenshots/settings.png',
    );
  });
}

Future<void> _capture(
  WidgetTester tester,
  Widget screen,
  String goldenPath,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentUserProvider.overrideWith((ref) => _adminUser()),
        hrSettingsProvider.overrideWith(
          () => HrSettingsNotifier(initial: const HrSettings()),
        ),
        apiConfigProvider.overrideWith(
          () => ApiConfigNotifier(
            initial: const ApiConfig(
              apiUrl: 'https://api.example.com/api',
              useRemote: true,
            ),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: screen,
      ),
    ),
  );
  await tester.pump(const Duration(seconds: 1));
  await expectLater(find.byType(MaterialApp), matchesGoldenFile(goldenPath));
}

UserModel _adminUser() {
  return UserModel(
    id: 'u001',
    name: 'Saif Al-Bulushi',
    email: 'admin@smarthr.com',
    mobile: '+968 9512 3456',
    role: 'admin',
    status: 'Active',
    createdAt: DateTime(2023, 1, 1),
  );
}
