import 'package:flutter_test/flutter_test.dart';
import 'package:cargo_rent_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CarGoRentApp());
    expect(find.byType(CarGoRentApp), findsOneWidget);
  });
}