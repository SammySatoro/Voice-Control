import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

  factory NotificationManager() {
    return _instance;
  }

  NotificationManager._internal();

  Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Настройка уведомлений
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@drawable/voice_control_64');
    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Функция для отправки уведомления
  Future<void> showNotification(String title, String body) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'vc_notification_id',
      'vc_channel_name',
      channelDescription: 'vc-notification',
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
      enableVibration: false,
      vibrationPattern: Int64List.fromList([]),
      showProgress: false,
      ticker: 'vc-notification-ticker',
    );
    NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        platformChannelSpecifics,
        payload: 'item x'
    );
  }
}