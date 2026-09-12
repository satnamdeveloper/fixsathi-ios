import 'dart:convert' as convert;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fixsathi/classPack/sessions_file.dart';
import 'package:fixsathi/clients/dashboard_user.dart';
import 'package:fixsathi/firebase_options.dart';
import 'package:fixsathi/frontScreen/login_number.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
// import 'firebase_options.dart';

@pragma('vm:entry-point')
// ignore: non_constant_identifier_names
Future<void> _FirebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_FirebaseMessagingBackgroundHandler);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fix Sathi',
      theme: ThemeData(
        // This is the theme of your application.
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 236, 233, 233),
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
            // borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 13, 72, 174),
              width: 1.5,
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            // borderRadius: BorderRadius.circular(4.0),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 13, 72, 174),
              width: 1.0,
            ),
          ),
          labelStyle: const TextStyle(color: Colors.black),
          // hintStyle: const TextStyle(color: Colors.grey),
          fillColor: const Color.fromARGB(255, 255, 255, 255),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15.0,
            horizontal: 20.0,
          ),
        ),

        // brightness: Brightness.light,
        appBarTheme: const AppBarTheme(elevation: 0),
      ),
      home: const MyHomePage(title: 'Fix Sathi'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    // FIX: initialization function banaya taake sequence sahi chale
    _initializeAppFlow();
  }

  Future<void> _initializeAppFlow() async {
    // 1. Pehle scale animation start karein thode delay par
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() => _scale = 3.0);
    }

    // 2. Session ka data exact fetch hone ka WAIT karein
    var sharedPreferences = await SessionUrl().getUserdata();

    // Splash screen ka feel dene ke liye total 2.5 seconds hold karenge
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return; // Context crash protection

    if (sharedPreferences != null) {
      try {
        Map<String, dynamic> usersAll = convert.jsonDecode(sharedPreferences);
        if (usersAll.isNotEmpty) {
          // User logged in hai -> Dashboard par bhejein
          _navigateToScreen(
            const MainDashboard(),
          ); // Apni sahi class name check kar lein yahan
          return;
        }
      } catch (e) {
        debugPrint("Session parsing error: $e");
      }
    }

    // Kuch data nahi mila -> Login page par bhejein
    _navigateToScreen(const SelectMobile(title: 'Fix Sathi'));
  }

  // Safe Navigation Helper method for zero context issues
  void _navigateToScreen(Widget targetScreen) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(5, 34, 129, 1),
      body: SafeArea(
        child: Center(
          child: AnimatedScale(
            scale: _scale,
            duration: const Duration(seconds: 1),
            child: Image.asset(
              'assets/images/icon.png',
              width: 120.0,
              height: 120.0,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.handyman,
                size: 60,
                color: Colors.white,
              ), // Image missing safeguard
            ),
          ),
        ),
      ),
    );
  }
}
