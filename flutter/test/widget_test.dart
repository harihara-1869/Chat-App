// Basic Flutter widget test for Chat App.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/main.dart';

void main() {
  testWidgets('ChatApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: ChatApp(),
      ),
    );

    // Verify that the app renders
    expect(find.byType(ChatApp), findsOneWidget);
  });
}