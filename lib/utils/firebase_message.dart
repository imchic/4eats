import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseMessageApi {

  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> _handleMessage(RemoteMessage message) async {
    // title
    final title = message.notification?.title;
    // body
    final body = message.notification?.body;
    // payload
    final payload = message.data;
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    //final fcmToken = await _firebaseMessaging.getAPNSToken();

    // 플랫폼 별 토큰 가져오기
    String? token = '';
    if(defaultTargetPlatform == TargetPlatform.iOS) {
      token = await _firebaseMessaging.getAPNSToken();
    } else if(defaultTargetPlatform == TargetPlatform.android) {
      token = await _firebaseMessaging.getToken();
    }

    // shared_preferences에 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcmToken', token!);

    // 알림 수신
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _handleMessage(message);
    });

    // 앱이 실행중일 때 알림 수신
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      await _handleMessage(message);
    });

    // 앱이 종료된 상태에서 알림 수신
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      await _handleMessage(initialMessage);
    }

    // 알림 클릭 시
    FirebaseMessaging.onBackgroundMessage((message) async {
      await _handleMessage(message);
    });

  }
}