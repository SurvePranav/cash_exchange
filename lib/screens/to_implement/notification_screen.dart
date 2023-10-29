import 'package:cashxchange/constants/color_constants.dart';
import 'package:flutter/material.dart';

class NofificationScreen extends StatelessWidget {
  final List<NotificationTile> notifications = [
    const NotificationTile(
      title: 'New Message',
      message: 'You have a new message from John Doe.',
      time: '10:30 AM',
    ),
    const NotificationTile(
      title: 'Accepted Request',
      message: 'John Doe is ready to accept cash.',
      time: '11:50 PM',
    ),
    const NotificationTile(
      title: 'Cash request in your area',
      message: 'Aman Want 50 RS cash',
      time: '2 days ago',
    ),
    const NotificationTile(
      title: 'Cash request in your area',
      message: 'Sangita Want 1000 RS cash',
      time: '10:30 PM',
    ),
    // Add more notification tiles here
  ];

  NofificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications", style: TextStyle(color: Colors.white)),
        backgroundColor: blue_10,
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return notifications[index];
        },
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final String title;
  final String message;
  final String time;

  const NotificationTile(
      {super.key, required this.title, required this.message, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: blue_6, // Blue background color
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            time,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }
}
