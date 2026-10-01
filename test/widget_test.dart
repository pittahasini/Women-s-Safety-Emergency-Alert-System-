import 'package:flutter_test/flutter_test.dart';
import 'package:guardian_ai/main.dart';

void main() {
  testWidgets('Guardian AI app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const GuardianAI());

    expect(find.text('Welcome to Guardian AI'), findsOneWidget);
    expect(find.text('QUICK SOS'), findsOneWidget);
  });
}