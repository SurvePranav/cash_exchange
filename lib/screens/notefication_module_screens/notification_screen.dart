import 'dart:developer';

import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/model/notification_model.dart';
import 'package:cashxchange/utils/date_util.dart';
import 'package:cashxchange/utils/notification_services.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool markedAll = false;
  @override
  Widget build(BuildContext context) {
    List<String> notificationIds = [];
    List<String> allNotifications = [];
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
        title: Row(
          children: [
            const Text(
              "Notifications",
              style: TextStyle(color: Colors.white),
            ),
            const Expanded(
              child: SizedBox(),
            ),
            TextButton(
                onPressed: () async {
                  log('total notifications ${allNotifications.length}');
                  for (String uid in allNotifications) {
                    NotificationServics.deleteInAppNotification(uid);
                  }
                },
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ),
        backgroundColor: AppColors.deepGreen,
      ),
      body: StreamBuilder(
        stream: NotificationServics.getMyInAppNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('You don\'t have any notifications.'));
          } else {
            // Display the list of notifications
            List<MyNotification> notifications = snapshot.data!.docs
                .map((e) => MyNotification.fromJson(e.data()))
                .toList();

            return Container(
              margin: const EdgeInsets.only(bottom: 20.0),
              child: ListView.separated(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  MyNotification notification = notifications[index];
                  if (!notification.isSeen) {
                    notificationIds.add(notification.id);
                  }
                  allNotifications.add(notification.id);
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
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        notification.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          notification.body,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      trailing: Column(
                        children: [
                          !notification.isSeen
                              ? Container(
                                  height: 16,
                                  width: 16,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green,
                                  ),
                                )
                              : const SizedBox(
                                  height: 16,
                                  width: 16,
                                ),
                          Text(
                            MyDateUtil.formatTimeAgo(notification.timeStamp),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.deepGreen,
        onPressed: () async {
          for (String id in notificationIds) {
            NotificationServics.updateNotificationSeenStatus(id);
          }
        },
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check,
              color: Colors.white,
            ),
            Text(
              'read all',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final String title;
  final String message;
  final String time;

  const NotificationTile({
    super.key,
    required this.title,
    required this.message,
    required this.time,
  });

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
