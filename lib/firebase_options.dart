// Replace with output from: dart run flutterfire_cli:flutterfire configure
// Placeholder values allow the project to compile; use a real Firebase project before release.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with [Firebase.initializeApp].
abstract final class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for '
          '$defaultTargetPlatform. Run FlutterFire CLI or add options.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyASlkUeFtz-3wacAfXU5D4cjRXBpvDwruQ',
    appId: '1:888411305179:web:79eb72b72b1dbae83548fe',
    messagingSenderId: '888411305179',
    projectId: 'room-chat-5a0b1',
    authDomain: 'room-chat-5a0b1.firebaseapp.com',
    storageBucket: 'room-chat-5a0b1.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBohy8K4jedqXPPi_j_Afuf1gZFSX-bmXk',
    appId: '1:888411305179:android:e295361145681e203548fe',
    messagingSenderId: '888411305179',
    projectId: 'room-chat-5a0b1',
    storageBucket: 'room-chat-5a0b1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC_xrfCg_kyzR_vN1yNVNBSdJbOYLjNXXU',
    appId: '1:888411305179:ios:401e5d9e24fdd22d3548fe',
    messagingSenderId: '888411305179',
    projectId: 'room-chat-5a0b1',
    storageBucket: 'room-chat-5a0b1.firebasestorage.app',
    iosBundleId: 'com.example.roomChat',
  );

}