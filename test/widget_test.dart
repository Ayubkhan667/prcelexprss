import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pe_attendance/app.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PEAttendanceApp()));
    await tester.pump(const Duration(seconds: 3));
    expect(find.byType(PEAttendanceApp), findsOneWidget);
  });
}
