import 'package:flutter_test/flutter_test.dart';

import 'package:tread_pro_fit/main.dart';

void main() {
  testWidgets('App renders main navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Tread Pro Fit'), findsOneWidget);
    expect(find.text('Live'), findsOneWidget);
    expect(find.text('Clusters'), findsOneWidget);
    expect(find.text('Detail'), findsOneWidget);
    expect(find.text('Connect Upstox'), findsOneWidget);
  });
}