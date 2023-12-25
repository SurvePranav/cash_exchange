import 'dart:io';
import 'package:cashxchange/model/connection_model.dart';
import 'package:cashxchange/model/message_model.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/utils/notification_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MessagingProvider with ChangeNotifier {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  bool _hasMessage = false;
  bool get hasMessage => _hasMessage;

  void setNewMessage(bool hasMessage) {
    _hasMessage = hasMessage;
    notifyListeners();
  }

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

  // for sending message
  Future<void> sendMessage(
    Connection connection,
    String msg,
    MsgType type,
    BuildContext context,
  ) async {
    // message sent time also a doc id for a message
    final ap = Provider.of<AuthProvider>(context, listen: false);
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
        .then((value) {
      // updating last message time for both users
      ap.updateLastMessageTime(
          fromId: UserModel.instance.uid, toId: connection.uid);
      ap.updateLastMessageTime(
          fromId: connection.uid, toId: UserModel.instance.uid);

      // sending push notification to receiver user
      NotificationServics.sendPushNotification(
        connection,
        type == MsgType.text
            ? msg
            : type == MsgType.image
                ? '📷 Photo'
                : 'Accepted Your Request',
        type,
      );
    });
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
  Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(String uid) {
    return _firebaseFirestore
        .collection('chats/${_getConversationId(uid)}/messages')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  // sending an image in chat
  Future<void> sendChatImage(
      Connection connection, File file, BuildContext context) async {
    final ext = file.path.split('.').last;

    // storage file ref with path
    final ref = _firebaseStorage.ref().child(
        'chatImages/${_getConversationId(connection.uid)}/${DateTime.now().microsecondsSinceEpoch.toString()}.$ext');
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));
    await ref.getDownloadURL().then((imageUrl) async {
      await sendMessage(
        connection,
        imageUrl,
        MsgType.image,
        context,
      );
    });
  }

  // delete chat message
  Future<void> deleteMessage(Message message) async {
    //delete message
    await _firebaseFirestore
        .collection('chats/${_getConversationId(message.toId)}/messages/')
        .doc(message.sent)
        .delete();
    // delete image from storage
    if (message.type == MsgType.image) {
      await _firebaseStorage.refFromURL(message.msg).delete();
    }
  }
}
