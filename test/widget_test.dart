import 'package:flutter_test/flutter_test.dart';

import 'package:room_chat/app/room_chat_app.dart';
import 'package:room_chat/core/constants/app_strings.dart';

void main() {
  testWidgets('Splash screen renders headline', (WidgetTester tester) async {
    await tester.pumpWidget(const RoomChatApp());
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.splashHeadline), findsOneWidget);
    expect(find.text(AppStrings.navToJoinRoom), findsOneWidget);
  });
}
