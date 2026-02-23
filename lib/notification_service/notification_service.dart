import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'; // Required for kIsWeb
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseNotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Call this in main.dart
  static Future<void> initialize() async {
    // ❌ REMOVED: await Firebase.initializeApp();
    // (Already initialized in main.dart)

    // ✅ Request Permissions (Required for Web/iOS)
    await _requestPermissions();

    // ✅ Mobile-specific setup (Channels & Local Notifications)
    if (!kIsWeb) {
    await FirebaseMessaging.instance.requestPermission();
    }
    if (!kIsWeb) {
      
      await _setupNotificationChannels();
      await _initializeLocalNotifications();
    }

    // ✅ Print Token (Now supports Web VAPID)
    await _logToken();

    // ✅ Setup Handlers
    await _setupInteractedMessage();
    _setupForegroundMessageHandler();
  }

  static Future<void> _logToken() async {
    try {
      String? token;
      if (kIsWeb) {
        // ⚠️ REPLACE WITH YOUR VAPID KEY FROM FIREBASE CONSOLE
        token = await _firebaseMessaging.getToken(
          vapidKey:
              "BJ8Wclfm-WkXbyrTW6li67Gp4fkP69CTNBHNJOMT4lgvgkKRg",
        );
      } else {
        token = await _firebaseMessaging.getToken();
      }
      print('FCM Token: $token');
    } catch (e) {
      print('Error getting token: $e');
    }
  }

  static Future<void> _setupNotificationChannels() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload);
      },
    );
  }

  static Future<void> _setupInteractedMessage() async {
    // Get any messages which caused the application to open from a terminated state
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  static void _setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');

        // On Web, browsers usually don't show "system" notifications
        // if the tab is in focus. You might want to show a custom UI (Dialog/Snackbar).
        // For Mobile, we use Local Notifications.
        if (!kIsWeb) {
          _showNotification(message);
        } else {
          // Optional: Add Web-specific UI handling (e.g., Snackbar)
          print(
              'Web foreground notification received: ${message.notification?.title}');
        }
      }
    });
  }

  static Future<void> _showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      AndroidNotificationDetails androidPlatformChannelSpecifics =
          const AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        playSound: true,
      );

      DarwinNotificationDetails iosPlatformChannelSpecifics =
          const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iosPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        platformChannelSpecifics,
        payload: message.data.toString(),
      );
    }
  }

  static void _handleMessage(RemoteMessage message) {
    print('Handling a message: ${message.messageId}');
    _handleNotificationTap(message.data.toString());
  }

  static void _handleNotificationTap(String? payload) {
    print('Notification tapped with payload: $payload');
    // Implement navigation logic here
  }
}
