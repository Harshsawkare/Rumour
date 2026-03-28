import 'package:flutter/material.dart';

import 'package:room_chat/app/room_chat_app.dart';
import 'package:room_chat/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Bootstrap.initialize();
  runApp(const RoomChatApp());
}
