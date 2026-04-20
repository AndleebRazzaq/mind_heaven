import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'auth_service.dart';
import 'firebase_runtime.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await FirebaseRuntime.ensureInitialized();
  if (kDebugMode) {
    debugPrint('FCM background message: ${message.messageId}');
  }
}

class NotificationService {
  static const String broadcastTopic = 'allUsers';

  final AuthService _authService;
  final FirebaseMessaging _messaging;

  NotificationService({
    required AuthService authService,
    FirebaseMessaging? messaging,
  }) : _authService = authService,
       _messaging = messaging ?? FirebaseMessaging.instance;

  Future<void> initialize() async {
    if (!FirebaseRuntime.isAvailable) return;

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    try {
      await _messaging.subscribeToTopic(broadcastTopic);
      if (kDebugMode) {
        debugPrint('Subscribed to topic: $broadcastTopic');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Topic subscribe failed: $e');
      }
    }

    final token = await _messaging.getToken();
    if (token != null) {
      if (kDebugMode) debugPrint('FCM token: $token');
      await _saveToken(token);
    }

    _messaging.onTokenRefresh.listen((newToken) async {
      await _saveToken(newToken);
    });

    FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        debugPrint(
          'FCM foreground message: ${message.notification?.title} | ${message.messageId}',
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (kDebugMode) {
        debugPrint('FCM notification tapped: ${message.messageId}');
      }
    });
  }

  Future<void> _saveToken(String token) async {
    final user = await _authService.getCurrentUser();
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fcmToken': token,
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save FCM token: $e');
      }
    }
  }
}
