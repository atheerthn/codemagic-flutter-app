import 'package:flutter_test/flutter_test.dart';
import 'package:codemagic_flutter_app/main.dart';

void main() {
  testWidgets('App renders and shows loading state', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    // App should render with a loading indicator initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
