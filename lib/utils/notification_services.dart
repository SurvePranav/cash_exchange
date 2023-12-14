import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cashxchange/model/connection_model.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';

class NotificationServics {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  // get firebase messaging token
  static Future<void> getFirebaseMessagingToken(
      {bool getMyToken = false}) async {
    // requesting notification permission
    await _firebaseMessaging.requestPermission();

    // getting notification token
    final msgToken = await _firebaseMessaging.getToken();
    if (msgToken != null) {
      log("token is not null");
      if (getMyToken) {
        UserModel.instance.pushToken = msgToken;
        log('push Token: $msgToken');
        return;
      }
    } else {
      log("token is null!!!!");
    }
  }

  // for sending push notification for chat
  static Future<void> sendChatPushNotification(
      Connection connection, String msg) async {
    try {
      final body = {
        "to": connection.pushToken,
        "notification": {
          "title": UserModel.instance.name, //our name should be send
          "body": msg,
          "android_channel_id": "chats"
        },
        "data": {
          "uid": UserModel.instance.uid,
        },
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAAUrs3Zmc:APA91bEs4bscRbP7eCmQHgTlhygsxH-FgIbgXpbYmAJQAuTiA8SWse3sgPF3bKSePuvDrfC6wDAgrk_olFItrU4raMu4truofjO8nlG8IooSaauAGChknSCXodriNmngz8JpC9v7udrC'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }
}
