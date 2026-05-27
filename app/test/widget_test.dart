import 'package:flutter_test/flutter_test.dart';
import 'package:campus_tour_app/main.dart';

void main() {
  testWidgets('App renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusTourApp());
    expect(find.text('西南大学校园导览'), findsOneWidget);
    expect(find.text('登录'), findsOneWidget);
  });
}
