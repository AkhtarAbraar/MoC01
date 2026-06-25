import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Movie Catalog app initialization smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that AppBar title 'Movie Lists' is displayed.
    expect(find.text('Movie Lists'), findsOneWidget);
  });
}
