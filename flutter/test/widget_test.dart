import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:chat_app/main.dart';

void main() {
  testWidgets('ChatApp should be a ConsumerStatefulWidget', (WidgetTester tester) async {
    expect(const ChatApp(), isA<ConsumerStatefulWidget>());
  });
}
