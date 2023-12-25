import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/model/notification_model.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/utils/date_util.dart';
import 'package:cashxchange/utils/notification_services.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
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

  NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        title:
            const Text("Notifications", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.deepGreen,
      ),
      body: StreamBuilder(
        stream: NotificationServics.getMyInAppNotifications(),
        builder: (context, snapshot) {
          // for (var i = 0; i < 10; i++) {
          //   MyNotification notification = MyNotification(
          //       id: i.toString(),
          //       uid: UserModel.instance.uid,
          //       title: 'title',
          //       body: 'body',
          //       timeStamp: DateTime.now().millisecondsSinceEpoch);
          //   NotificationServics.sendInAppNotification(notification);
          // }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('You don\'t have any notifications.'));
          } else {
            // Display the list of notifications
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                MyNotification notification =
                    MyNotification.fromJson(snapshot.data!.docs[index].data());
                return Dismissible(
                  key: Key(notification.id),
                  onDismissed: (direction) {
                    // Delete the document when swiped
                    NotificationServics.deleteInAppNotification(
                        notification.id);
                  },
                  background: Container(
                    color: Colors.transparent,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: Icon(
                      Icons.delete,
                      color: AppColors.deepGreen,
                    ),
                  ),
                  child: ListTile(
                    title: Text(notification.title),
                    subtitle: Text(notification.body),
                    trailing:
                        Text(MyDateUtil.formatTimeAgo(notification.timeStamp)),
                  ),
                );
              },
            );
          }
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
      {super.key,
      required this.title,
      required this.message,
      required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.blue_6, // Blue background color
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
