import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_driver/main.dart';

void main() {
  testWidgets('Fleet app opens dashboard and navigates to drivers', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('Dashboard'), findsWidgets);

    await tester.tap(find.text('Drivers'));
    await tester.pumpAndSettle();

    expect(find.text('Kouame Yao'), findsOneWidget);
  });
}
