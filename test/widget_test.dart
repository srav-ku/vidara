import 'package:flutter_test/flutter_test.dart';
import 'package:vidara/main.dart';

void main() {
  testWidgets('Video player screen loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the branding text is present.
    expect(find.text('VIDARA PLAYER'), findsOneWidget);
  });
}
