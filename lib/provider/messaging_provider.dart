import 'dart:developer';
import 'dart:io';
import 'package:cashxchange/model/connection_model.dart';
import 'package:cashxchange/model/message_model.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/utils/notification_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class MessagingProvider with ChangeNotifier {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  String _getConversationId(String id) {
    if (UserModel.instance.uid.hashCode <= id.hashCode) {
      return '${UserModel.instance.uid}_$id';
    } else {
      return '${id}_${UserModel.instance.uid}';
    }
  }

  // getting all the messages for a specific conversation
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      Connection connection) {
    // chats(collection)----> conversation_id(doc) ------> messages(collection) ----> message(doc)
    return _firebaseFirestore
        .collection('chats/${_getConversationId(connection.uid)}/messages')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // get all connections
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllConnections() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('uid', isNotEqualTo: UserModel.instance.uid)
        .snapshots();
  }

  // for sending message
  Future<void> sendMessage(
      Connection connection, String msg, MsgType type) async {
    // message sending time also a doc id for a message
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = _firebaseFirestore
        .collection('chats/${_getConversationId(connection.uid)}/messages');
    await ref
        .doc(time)
        .set(
          Message(
            toId: connection.uid,
            msg: msg,
            read: '',
            type: type,
            sent: time,
            fromId: UserModel.instance.uid,
          ).toJson(),
        )
        .then(
          (value) => NotificationServics.sendChatPushNotification(
            connection,
            type == MsgType.text
                ? msg
                : type == MsgType.image
                    ? '📷 Photo'
                    : 'Accepted Request',
          ),
        );
  }

  // to update read status of the message
  Future<void> updateMessageReadStatus(Message message) async {
    await _firebaseFirestore
        .collection('chats/${_getConversationId(message.fromId)}/messages')
        .doc(message.sent)
        .update(
      {
        'read': DateTime.now().millisecondsSinceEpoch.toString(),
      },
    );
  }

  // get last message from a specific conversation
  Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      Connection connection) {
    return _firebaseFirestore
        .collection('chats/${_getConversationId(connection.uid)}/messages')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  // sending an image in chat
  Future<void> sendChatImage(Connection connection, File file) async {
    final ext = file.path.split('.').last;

    // storage file ref with path
    final ref = _firebaseStorage.ref().child(
        'chatImages/${_getConversationId(connection.uid)}/${DateTime.now().microsecondsSinceEpoch.toString()}.$ext');
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));

    final imageUrl = await ref.getDownloadURL();
    await sendMessage(connection, imageUrl, MsgType.image);
  }

  // get connection(other user) information
}
