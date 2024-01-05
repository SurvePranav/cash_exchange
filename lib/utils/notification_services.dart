import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cashxchange/model/connection_model.dart';
import 'package:cashxchange/model/message_model.dart';
import 'package:cashxchange/model/notification_model.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';

class NotificationServics {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FirebaseFirestore _firebaseFirestore =
      FirebaseFirestore.instance;

  // get firebase messaging token
  static Future<void> getFirebaseMessagingToken(
      {bool getMyToken = false}) async {
    // requesting notification permission
    await _firebaseMessaging.requestPermission();

    // getting notification token
    final msgToken = await _firebaseMessaging.getToken();
    if (msgToken != null) {
      if (getMyToken) {
        UserModel.instance.pushToken = msgToken;
        return;
      }
    } else {
      log("token is null!!!!");
    }
  }

  // for sending push notification for chat
  static Future<void> sendPushNotification(
      Connection connection, String msg, MsgType msgType,
      {title = ''}) async {
    try {
      final body = {
        "to": connection.pushToken,
        "notification": {
          "title": title == ''
              ? UserModel.instance.name
              : title, //our name should be send
          "body": msg,
          "android_channel_id": msgType == MsgType.custom ? "requests" : "chats"
        },
        "data": {
          "uid": UserModel.instance.uid,
        },
      };

      await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAAUrs3Zmc:APA91bEs4bscRbP7eCmQHgTlhygsxH-FgIbgXpbYmAJQAuTiA8SWse3sgPF3bKSePuvDrfC6wDAgrk_olFItrU4raMu4truofjO8nlG8IooSaauAGChknSCXodriNmngz8JpC9v7udrC'
          },
          body: jsonEncode(body));
    } catch (e) {
      log('could not send Push Notification: $e');
    }
  }

  // send inApp notification
  static void sendInAppNotification({
    required String uid,
    required String title,
    required String body,
  }) {
    int timeStamp = DateTime.now().millisecondsSinceEpoch;
    MyNotification notification = MyNotification(
      id: timeStamp.toString(),
      uid: uid,
      title: title,
      body: body,
      timeStamp: timeStamp,
      isSeen: false,
    );
    _firebaseFirestore
        .collection('notifications')
        .doc(notification.id)
        .set(notification.toJson());
  }

  static void updateNotificationSeenStatus(String id) async {
    try {
      _firebaseFirestore
          .collection('notifications')
          .doc(id)
          .update({'isSeen': true});
    } catch (error) {
      log('Error updating notifications: $error');
    }
  }

  // read user's inApp notifications
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyInAppNotifications() {
    return _firebaseFirestore
        .collection('notifications')
        .where('uid', isEqualTo: UserModel.instance.uid)
        .orderBy('timeStamp', descending: true)
        .snapshots();
  }

  // UnreadNotification Count
  static Stream<int> getUnreadNotificationCount() {
    return FirebaseFirestore.instance
        .collection('notifications') // Replace with your collection name
        .where('uid', isEqualTo: UserModel.instance.uid)
        .where('isSeen', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // delete a notification by id
  static void deleteInAppNotification(String id) {
    _firebaseFirestore.collection('notifications').doc(id).delete();
  }
}
