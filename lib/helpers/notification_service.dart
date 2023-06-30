import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();



  final _notificationId = 0;

  Future init() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.input != null) {
          print('User replied ${details.input}');
        }
      },
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
  }

  final AndroidNotificationDetails _androidNotificationDetails = const AndroidNotificationDetails(
    'notif-001',
    'sangu-notif',
    channelDescription: 'display notifications for sangu',
    playSound: true,
    priority: Priority.high,
    importance: Importance.high,
  );

  Future<void> showNotifications({
    required String notificationTitle,
    required String notificationBody,
    String? notificationPayload,
  }) async {
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: _androidNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      _notificationId,
      notificationTitle,
      notificationBody,
      platformChannelSpecifics,
      payload: notificationPayload,
    );
  }

  Future<void> cancelNotifications() async {
    await flutterLocalNotificationsPlugin.cancel(_notificationId);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}