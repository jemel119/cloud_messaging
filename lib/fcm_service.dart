import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
 
class FCMService {
  final _msg = FirebaseMessaging.instance;
 
  /// Call once from initState. [onData] fires for all three app states.
  Future<void> initialize({required void Function(RemoteMessage) onData}) async {
    // 1. Request permission (Android 13+, iOS prompt)
    final settings = await _msg.requestPermission(
      alert: true, badge: true, sound: true,
    );
    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');
 
    // 2. Log token for Firebase Console testing
    final token = await _msg.getToken();
    debugPrint('[FCM] Token: $token');
 
    // 3. Foreground — app open and visible
    FirebaseMessaging.onMessage.listen(onData);
 
    // 4. Background — user taps notification to resume app
    FirebaseMessaging.onMessageOpenedApp.listen(onData);
 
    // 5. Terminated — app launched via notification tap
    final initial = await _msg.getInitialMessage();
    if (initial != null) onData(initial);
  }
 
  Future<String?> getToken() => _msg.getToken();
}