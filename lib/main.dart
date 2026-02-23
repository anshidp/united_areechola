import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:united_areechola/authentication/screens/splash_screen.dart';
import 'package:united_areechola/firebase_options.dart';
import 'package:united_areechola/launch/app_launcher.dart';
import 'package:united_areechola/notification_service/background_handler.dart';
import 'package:united_areechola/notification_service/notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background message: ${message.messageId}');
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      // ✅ Web Firebase init
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyAJbPzgyaa98sDmYoujVS-v5Nxj8b03ink",
          authDomain: "unitedareechola.firebaseapp.com",
          projectId: "unitedareechola",
          storageBucket: "unitedareechola.appspot.com",
          messagingSenderId: "1016786265689",
          appId: "1:1016786265689:web:b078345a011b94e89c7348",
        ),
      );

      // 🔥 IMPORTANT: disable persistence for iOS Safari stability
      await FirebaseAuth.instance.setPersistence(Persistence.NONE);
    } else {
      // ✅ Mobile (Android + iOS)
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Mobile persistence is safe
      await FirebaseAuth.instance.setPersistence(Persistence.NONE);
    }
  } catch (e) {
    debugPrint('Error Initializing Firebase: $e');
  }

  // ❌ Firebase Messaging background handler NOT for web

  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    FirebaseNotificationService.initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'United areechola',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xffF5F6F7),
        useMaterial3: true,
        fontFamily: "PublicSans",
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 57, // Example size, adjust as needed
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          displayMedium: TextStyle(
            fontSize: 45,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          displaySmall: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          headlineSmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          titleSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),

      // const SplashScreen()
      home: AppLauncher(
        mainApp: const SplashScreen(),
      ),
    );
  }
}
