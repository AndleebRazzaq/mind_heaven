import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions are not configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for desktop.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDC11Ok-ob-g_7gLmYnAJVql6IeCYmE4mQ',
    appId: '1:867065112691:android:c5fc3bf4dff775e3c52206',
    messagingSenderId: '867065112691',
    projectId: 'reframed-cd2cf',
    storageBucket: 'reframed-cd2cf.firebasestorage.app',
  );

  // Keep same project values; replace appId with your iOS app id when available.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDC11Ok-ob-g_7gLmYnAJVql6IeCYmE4mQ',
    appId: '1:867065112691:ios:replace_with_ios_app_id',
    messagingSenderId: '867065112691',
    projectId: 'reframed-cd2cf',
    storageBucket: 'reframed-cd2cf.firebasestorage.app',
    iosBundleId: 'com.example.mindHeaven',
  );
}
