import 'dart:developer';

import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/screens/home_screen.dart';
import 'package:cashxchange/screens/request_module_screens/request_screen.dart';
import 'package:cashxchange/utils/notification_services.dart';
import 'package:cashxchange/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class MainBody extends StatefulWidget {
  const MainBody({super.key});
  @override
  State<MainBody> createState() => _MainBodyState();
}

class _MainBodyState extends State<MainBody> with WidgetsBindingObserver {
  late final AuthProvider ap;
  @override
  void initState() {
    initializeNotifications();
    ap = Provider.of<AuthProvider>(context, listen: false);
    NotificationServics.getFirebaseMessagingToken(getMyToken: true)
        .then((value) {
      log('setting user online for first time');
      ap.updateUserActiveStatus(true);
    });
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  Future<void> initializeNotifications() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    // Create an Android Notification Channel for Chatting
    const AndroidNotificationChannel channel1 = AndroidNotificationChannel(
      'chats', // Change this to your preferred channel ID
      'Chats', // Change this to your preferred channel name
      description: 'to receive chat notifications',
      importance: Importance.high,
    );

    // Create a notification channel for request status
    const AndroidNotificationChannel channel2 = AndroidNotificationChannel(
      'requests', // Change this to your preferred channel ID
      'Requests', // Change this to your preferred channel name
      description: 'to receive request status info',
      importance: Importance.high,
    );

    // Create a Notification Channel 1 on Android
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel1);

    // Create a Notification Channel 2 on Android
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel2)
        .then((value) async {
      await MyAppServices.checkPermission(Permission.location, context);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (ap.isSignedIn) {
      switch (state) {
        case AppLifecycleState.resumed:
          ap.updateUserActiveStatus(true);
        case AppLifecycleState.detached:
          ap.updateUserActiveStatus(false);
        case AppLifecycleState.inactive:
          ap.updateUserActiveStatus(false);
        case AppLifecycleState.paused:
          ap.updateUserActiveStatus(false);
        default:
          break;
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.skyBlue,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              stops: const [
                0.5,
                1.0,
              ],
              colors: [
                AppColors.mintGreen,
                AppColors.skyBlue,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: const HomeScreen(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('request_screen');
        },
        backgroundColor: AppColors.mintGreen,
        child: Icon(
          Icons.add_circle_outline,
          size: 30,
          color: AppColors.deepGreen,
        ),
      ),
    );
  }
}
