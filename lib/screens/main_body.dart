import 'dart:developer';

import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/provider/messaging_provider.dart';
import 'package:cashxchange/screens/chat_module_screens/chat_screen.dart';
import 'package:cashxchange/screens/home_screen.dart';
import 'package:cashxchange/screens/request_module_screens/request_screen.dart';
import 'package:cashxchange/utils/notification_services.dart';
import 'package:cashxchange/widgets/custom_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

class MainBody extends StatefulWidget {
  final int currentIndex;
  const MainBody({super.key, this.currentIndex = 0});
  @override
  State<MainBody> createState() => _MainBodyState();
}

class _MainBodyState extends State<MainBody> {
  int _currentPage = 0;

  @override
  void initState() {
    _currentPage = widget.currentIndex;
    initializeNotifications();
    final ap = Provider.of<AuthProvider>(context, listen: false);
    NotificationServics.getFirebaseMessagingToken(getMyToken: true)
        .then((value) {
      log('setting user online for first time');
      ap.updateUserActiveStatus(true);
    });
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('My message: $message');
      if (ap.isSignedIn) {
        if (message.toString().contains('pause')) {
          log("setting online false");
          ap.updateUserActiveStatus(false);
        }
        if (message.toString().contains('resume')) {
          log("setting online true");
          ap.updateUserActiveStatus(true);
        }
      }

      return Future.value(message);
    });
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
        ?.createNotificationChannel(channel2);

    log('channels are created!!!');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentPage == 0 ? true : false,
      onPopInvoked: (myval) async {
        _currentPage = 0;
        setState(() {});
      },
      child: Scaffold(
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
            child: IndexedStack(index: _currentPage, children: const [
              HomeScreen(),
              RaiseRequestScreen(),
              ChatScreen(),
            ]),
          ),
        ),
        bottomNavigationBar: MyCustomBottomNaviationBar(
          selectedIndex: _currentPage,
          onTabChange: (int index) {
            _currentPage = index;
            setState(() {});
          },
        ),
      ),
    );
  }
}
