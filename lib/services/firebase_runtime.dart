import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

class FirebaseRuntime {
  static bool _initialized = false;
  static bool _available = false;

  static bool get isAvailable => _available;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _available = true;
    } catch (e) {
      final errorText = e.toString().toLowerCase();
      if (errorText.contains('duplicate-app') ||
          errorText.contains('already exists')) {
        _available = true;
        return;
      }
      _available = false;
      debugPrint('Firebase unavailable, using local fallback: $e');
    }
  }
}
