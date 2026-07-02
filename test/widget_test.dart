import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Movie Catalog app initialization smoke test', (WidgetTester tester) async {
    // Inisialisasi mock SharedPreferences agar widget test tidak error saat mengakses DB lokal
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Memverifikasi bahwa judul AppBar yang ditampilkan adalah 'Movie Catalog'
    expect(find.text('Movie Catalog'), findsOneWidget);
  });
}
