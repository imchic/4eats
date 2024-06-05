import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/notification_model.dart';
import 'logger.dart';

class FirebaseMessageApi {

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final _logger = AppLog.to;

  Future<void> initNotifications() async {
    _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // 플랫폼 별 토큰 가져오기
    String? token = '';
    token = await _firebaseMessaging.getToken();

    _logger.i('initNotifications token = $token');

    // shared_preferences에 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcmToken', token!);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {

      var title = message.notification?.title;
      var body = message.notification?.body;
      var data = message.data;

      _logger.i('onMessage title = $title');
      _logger.i('onMessage body = $body');

      final notification = NotificationModel.fromJson(message.data);

      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      final initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      );

      await flutterLocalNotificationsPlugin.initialize(initializationSettings);

      final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '댓글',
        '댓글 알림',
        importance: Importance.defaultImportance,
        priority: Priority.high,
      );

      final iOSPlatformChannelSpecifics = DarwinNotificationDetails();

      final platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      _logger.i('onMessage notification = ${notification.toJson()}');

      await flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        platformChannelSpecifics,
        payload: notification.deepLink,
      );

    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final notification = NotificationModel.fromJson(message.data);
      _logger.i('onMessageOpenedApp notification = $notification');
      // fcm 누르고 화면 이동
    });

    FirebaseMessaging.onBackgroundMessage(onBackgroundHandler);

  }

  Future<void> onBackgroundHandler(RemoteMessage message) async {
    if (message.data.isNotEmpty) {
      _logger.i('onBackgroundHandler message = $message');
      final notification = NotificationModel.fromJson(message.data);
      _logger.i('onBackgroundHandler notification = $notification');
    }
  }

  Future<void> removeNotifications() async {
    await _firebaseMessaging.deleteToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

}