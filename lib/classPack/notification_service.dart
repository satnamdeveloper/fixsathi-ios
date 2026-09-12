import 'dart:async';

import 'dart:io';
import 'package:fixsathi/clients/notification_dash.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:googleapis_auth/auth_io.dart';
// ignore: library_prefixes
import 'package:permission_handler/permission_handler.dart' as AppSettings;

class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationPlugin =
      FlutterLocalNotificationsPlugin();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> requestNotificationPermission() async {
    NotificationSettings settings;

    if (Platform.isIOS) {
      // iOS-specific permissions
      settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: true,
        announcement: true,
        criticalAlert: true,
        carPlay: true,
      );
    } else {
      // Android-specific permissions (only alert, badge, sound matter)
      settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
        debugPrint("✅ User granted notification permission");
        break;

      case AuthorizationStatus.provisional:
        debugPrint("⚠️ Provisional permission granted (iOS only)");
        break;

      case AuthorizationStatus.denied:
        debugPrint("❌ Notification permission denied");
        // Optionally guide user to settings
        AppSettings.openAppSettings();
        break;

      default:
        debugPrint(
          "ℹ️ Notification permission status: ${settings.authorizationStatus}",
        );
    }
  }

  void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) async {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
    // navigatorKey.currentState?.push(
    //   MaterialPageRoute(builder: (_) => SecondScreen(payload)),
    // );
  }

  Future<void> init(BuildContext context) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );
    await _flutterLocalNotificationPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        // ignore: use_build_context_synchronously
        handleMessage(context, message);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // if (kDebugMode) {
      //   print("Notification Title: ${message.notification!.title}");
      //   print("Notification body: ${message.notification!.body}");
      //   print("Notification data: ${message.data}");
      //   print("Notification data: ${message.data['screen']}");
      // }
      if (Platform.isIOS) {
        // ignore: use_build_context_synchronously
        iosForegroundMessage(context, message);
      }
      if (Platform.isAndroid) {
        showNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // ignore: use_build_context_synchronously
      handleMessage(context, message);
    });
  }

  // iOS foreground handling
  Future<void> iosForegroundMessage(
    BuildContext context,
    RemoteMessage message,
  ) async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          sound: true,
          badge: true,
        );

    // ignore: unnecessary_null_comparison
    if (message != null) {
      // ignore: use_build_context_synchronously
      handleMessage(context, message);
    }
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      message.notification!.android!.channelId.toString(),
      "High Importance Notification",
      showBadge: true,
      importance: Importance.max, // importance
      playSound: true,
    );
    await _flutterLocalNotificationPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()!
        .createNotificationChannel(channel);

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          channel.id.toString(),
          channel.name.toString(),
          channelDescription: "Channel for custom sound notifications",
          channelShowBadge: true,
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('old_tel_ring'),
          playSound: true,
        );
    DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          presentBanner: true,
        );
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    await _flutterLocalNotificationPlugin.show(
      id: message.hashCode,
      title: message.notification!.title.toString(),
      body: message.notification!.body.toString(),
      notificationDetails: notificationDetails,
      payload: message.data['screen'],
    );
  }

  void handleMessage(BuildContext context, RemoteMessage message) {
    final screen = message.data['screen'];
    debugPrint('➡️ Navigate to screen: $screen');
    if (screen != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => NotificationDashboard()),
      );
    }
  }

  Future<String?> setupToken() async {
    // Request notification permissions for iOS
    // ignore: unused_local_variable
    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(
          provisional: true,
          alert: true,
          badge: true,
          sound: true,
        );

    // Get the token
    String? token = await FirebaseMessaging.instance.getToken();
    return token;
  }

  // static Future<void> sendNotificationsId({
  //   required String? appid,
  //   required String? title,
  //   required String? body,
  //   required String? userdata,
  // }) async {
  //   String accessToken = await getServerKeyToken();
  //   String url =
  //       "https://fcm.googleapis.com/v1/projects/webclick-1689483681529/messages:send";
  //   var header = <String, String>{
  //     'Content-Type': 'application/json',
  //     'Authorization': 'Bearer $accessToken',
  //   };
  //   Map<String, dynamic> message = {
  //     "message": {
  //       "token": appid,
  //       "notification": {"title": title, "body": body},
  //       "data": {"screen": userdata},
  //     },
  //   };
  //   final http.Response response = await http.post(
  //     Uri.parse(url),
  //     headers: header,
  //     body: jsonEncode(message),
  //   );
  //   if (response.statusCode == 200) {
  //     debugPrint('Sent successful notification.');
  //   } else {
  //     debugPrint('unsuccessful notification.');
  //   }
  // }

  // static Future<void> sendNotificationsTopics({
  //   required String? topic,
  //   required String? title,
  //   required String? body,
  //   required String? userdata,
  // }) async {
  //   String accessToken = await getServerKeyToken();
  //   String url =
  //       "https://fcm.googleapis.com/v1/projects/fixsathi-80116/messages:send";
  //   var header = <String, String>{
  //     'Content-Type': 'application/json',
  //     'Authorization': 'Bearer $accessToken',
  //   };
  //   Map<String, dynamic> message = {
  //     "message": {
  //       "topic": topic,
  //       "notification": {"title": title, "body": body},
  //       "data": {"screen": userdata},
  //     },
  //   };
  //   final http.Response response = await http.post(
  //     Uri.parse(url),
  //     headers: header,
  //     body: jsonEncode(message),
  //   );
  //   if (response.statusCode == 200) {
  //     debugPrint('Sent successful notification.');
  //   } else {
  //     debugPrint('unsuccessful notification.');
  //   }
  // }

  // static Future<String> getServerKeyToken() async {
  //   final scopes = [
  //     'https://www.googleapis.com/auth/userinfo.email',
  //     'https://www.googleapis.com/auth/firebase.database',
  //     'https://www.googleapis.com/auth/firebase.messaging',
  //   ];
  //   final client = await clientViaServiceAccount(
  //     ServiceAccountCredentials.fromJson({
  //       "type": "service_account",
  //       "project_id": "fixsathi-80116",
  //       "private_key_id": "2eb72e8e154543d5cfcd6527efec9b6f0a8ce9bd",
  //       "private_key":
  //           "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDC0LqJgvHtUBp4\naA+RrgF+NwD7RDL00h1NiGsSveLYFoPRVTheQBVBO+79ANFEDBY9RNPt1hVL9RYy\nPoYQ8kZrZQl9lq0q5HuxG8Zly2+nD5IxR31sj8xBI+S1+qrh2Gr2LfDTV/4jVJOd\nSW5MKYs3U8eyimfEnxn7qvlhzKIlWGL2Q55P4IXHp4xUQVMTWxo0TxlqPLo+1DAQ\n2J/g4kLyg578mPnL517h7ucXXM7dTSLdJF3BrYWz0QDo7UqWvu9PabBq2kD02XmZ\nep8YzONdLS6CCxWCtR2qXpDX8TQAkg/xPWt/nIJ4O7jcDG5BT6+BjTZerjGQ4rBO\n9LL/nTqFAgMBAAECggEAWIH5BYl6vTzT0dlBHYfnAL8fkIhi+CxPiM6OCsU/Pro3\n6A5mHhfSMEF46fQJnvc40VwoRpkpMsml7GzQfvl7OcZ9AdRHV0HX2laKk+vRjZ46\n5m2a04wfGYcjnPPF1/Z5Xd/wVixXdxixOdfHJw4GxDupcfmEfGVmKhr60s5j6j/J\nxOJZSzrwkmdpwru+DcgaYruuYfSZ1FAvQ9WWhmlJTWVBeL5TgrKuEu1xX5QUjVyp\ngUhBCckgvDpebNwIr48+NOgR+LUDeTpet+7nMsswvsBgem+7/+/jQYYidZDyJ/w5\nOqRkE0HZJ4oIShqitP9BzBdnu1OvsiZcUDnNhlpPnwKBgQD8PXSgDz58k+Uoxbgm\naI2JYBa5So9SRe0lPIE5zHb+SiB9VguI/icv349Mks3kw2TKCOky/m8sz6oTRfAF\nvrA6V7/biZFSIeGLgclsUX6NVrUxiyRsQEv/CE2Er1ghZNg/HPPlE3+A3P8fnkAc\n+XIzkK57b+GJQGQsAa3lw4CW0wKBgQDFuCQmcExMfKPcRD/aV21dssTvGAD67NFl\ncXY5QRmV8hRxrRa0dOFrx1td0xndb9jAXbxwXfviguzobKIknjYCnCuM0FakC6kV\nOTtWHDQGpArgxxPL9ZWiSkT6tRFlGzjEYFI4VZiNF5MUD+YG64yWcyCeLvviyUlW\ntvhmJwtCRwKBgQDBVnWjDawunsnCc7KPtgnupzkjszOhszlvFi5S2BbJGJZIm4Bh\n87SjrC7RWaD5XI9PkH72eDFM3quU9EFilePMBGBpbMt3ccLIRKXYIarnuPNPU0CK\nvMnDZGDOd/wMNJjP32hOSKCtbDcczBaGXuia/6XNtVbg9fsSBAN/nldcwwKBgDyX\nddyhxYAbIkw6Ticna8ivJFLxVDuRn4oq/0QEg0bEbSd5F+AtgXd6HLHgI6kMwawS\nDdGRu8NqxBdmUzpNkdey7FW28xZKzIJIi7qT4g227+56k8KJfFXD1OfP3YjSks77\nhbbl5F44v0YCqUetn+PrXC+dzmttrB/66pzDklu5AoGAAq7weV94NgtyBZyReJIy\n2sV8nowPG9cwSt+a3430VjND9qU8u1G6Km0y+C2b3S+kYSf2h9739g4KC9jFg+8W\nFRXHYlXMIkp+yvAShlSQGNVf2zFspg1QJB5Wo10LmiSKZ7d08j71Ctom49jHoeOK\nvbOsU2PCghHKzH7fkbpFANo=\n-----END PRIVATE KEY-----\n",
  //       "client_email":
  //           "firebase-adminsdk-fbsvc@fixsathi-80116.iam.gserviceaccount.com",
  //       "client_id": "106276207556114377477",
  //       "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  //       "token_uri": "https://oauth2.googleapis.com/token",
  //       "auth_provider_x509_cert_url":
  //           "https://www.googleapis.com/oauth2/v1/certs",
  //       "client_x509_cert_url":
  //           "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40fixsathi-80116.iam.gserviceaccount.com",
  //       "universe_domain": "googleapis.com",
  //     }),
  //     scopes,
  //   );
  //   final accessServerKey = client.credentials.accessToken.data;
  //   // debugPrint(accessServerKey);
  //   return accessServerKey;
  // }

  Future<String?> getDeviceToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // स्टेप A: यूजर से नोटिफिकेशन की परमिशन मांगें (iOS के लिए बहुत ज़रूरी है)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');

      // स्टेप B: Apple के नियमों के अनुसार पहले APNS टोकन मिलने का इंतज़ार करें
      // अगर आप सीधे getToken() कॉल करेंगे तो iOS पर कई बार null रिटर्न आता है।

      String? apnsToken = await messaging.getAPNSToken();
      if (apnsToken == null) {
        debugPrint('APNS token has not been generated yet. Retrying...');
        // एक छोटा सा डिले देकर दोबारा चेक कर सकते हैं
        await Future.delayed(const Duration(seconds: 2));
        apnsToken = await messaging.getAPNSToken();
      }

      // स्टेप C: अब फाइनल Firebase FCM टोकन (Device ID) निकालें
      String? fcmToken = await messaging.getToken();
      debugPrint("=== YOUR iOS DEVICE FCM TOKEN ===");
      debugPrint(fcmToken);
      debugPrint("=================================");

      return fcmToken;
    } else {
      debugPrint('User declined or has not accepted notification permission');
      return null;
    }
  }
}
