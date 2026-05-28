import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pe_attendance/core/theme/app_theme.dart';
import 'package:pe_attendance/data/models/user_model.dart';
import 'package:pe_attendance/data/providers/api_config_provider.dart';
import 'package:pe_attendance/data/providers/auth_provider.dart';
import 'package:pe_attendance/data/providers/settings_provider.dart';
import 'package:pe_attendance/presentation/screens/admin/settings_screen.dart';

void main() {
  testWidgets('admin settings exposes admin-only management sections',
      (tester) async {
    await tester.pumpWidget(
      _buildSettingsApp(
        user: _user(role: 'admin'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('HR Configuration'), findsOneWidget);
    expect(find.text('Branch Settings'), findsOneWidget);
    expect(find.text('Shift Management'), findsOneWidget);
    expect(find.text('Salary & Payroll'), findsOneWidget);
  });

  testWidgets('supervisor settings hides admin-only management sections',
      (tester) async {
    await tester.pumpWidget(
      _buildSettingsApp(
        user: _user(role: 'supervisor'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('HR Configuration'), findsNothing);
    expect(find.text('Branch Settings'), findsNothing);
    expect(find.text('Shift Management'), findsNothing);
    expect(find.text('Salary & Payroll'), findsNothing);
    expect(find.text('Backend Configuration'), findsOneWidget);
    expect(find.text('Security'), findsOneWidget);
  });
}

Widget _buildSettingsApp({required UserModel user}) {
  return ProviderScope(
    overrides: [
      currentUserProvider.overrideWith((ref) => user),
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
      theme: AppTheme.lightTheme,
      home: const SettingsScreen(),
    ),
  );
}

UserModel _user({required String role}) {
  return UserModel(
    id: 'u-$role',
    name: 'Test $role',
    email: '$role@example.com',
    mobile: '+96890000000',
    role: role,
    status: 'Active',
    createdAt: DateTime(2024, 1, 1),
  );
}
