import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Singleton access to Firestore. Configures offline persistence; no query helpers yet.
final class FirestoreService {
  FirestoreService._();

  static final FirestoreService instance = FirestoreService._();

  /// Throws if Firebase failed to start — callers in data layer should handle errors later.
  FirebaseFirestore get db {
    if (Firebase.apps.isEmpty) {
      throw StateError(
        'Firebase is not initialized. Configure Firebase before using FirestoreService.db.',
      );
    }
    return FirebaseFirestore.instance;
  }

  /// Enables client persistence and an unlimited cache (mobile + desktop SDKs).
  void applyOfflinePersistenceSettings() {
    if (Firebase.apps.isEmpty) {
      return;
    }

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }
}
