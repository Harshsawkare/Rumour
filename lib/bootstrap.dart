import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'package:room_chat/core/services/firestore_service.dart';
import 'package:room_chat/firebase_options.dart';

/// Application startup (Firebase + core services). Keeps composing [main] thin.
abstract final class Bootstrap {
  static Future<void> initialize() async {
    await _initializeFirebase();
    FirestoreService.instance.applyOfflinePersistenceSettings();
  }

  static Future<void> _initializeFirebase() async {
    if (Firebase.apps.isNotEmpty) {
      return;
    }
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e, stackTrace) {
      debugPrint('Bootstrap: Firebase.initializeApp failed: $e');
      debugPrint('$stackTrace');
    }
  }
}
