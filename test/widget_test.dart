import 'package:flutter_test/flutter_test.dart';
import 'package:tv_paraguay/main.dart';

void main() {
  testWidgets('TV Paraguay inicia correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const TvParaguayApp());

    expect(find.text('TV PARAGUAY'), findsOneWidget);
    expect(find.text('TELEFUTURO'), findsOneWidget);
  });
}