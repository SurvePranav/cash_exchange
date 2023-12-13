import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  late String reqId;
  late String uid;
  late DateTime createdAt;
  late String amount;
  late String type;
  late String info;
  late double locationLat;
  late double locationLon;
  late int views;
  late bool isAccepted;

  // Initialization constructor
  RequestModel({
    required this.reqId,
    required this.uid,
    required this.createdAt,
    required this.amount,
    required this.type,
    required this.info,
    required this.locationLat,
    required this.locationLon,
    required this.views,
    required this.isAccepted,
  });

  // from json
  RequestModel.fromJson(Map<String, dynamic> map) {
    reqId = map['reqId'] ?? '';
    uid = map['uid'] ?? '';
    createdAt = (map['createdAt'] as Timestamp).toDate();
    amount = map['amount'] ?? '';
    type = map['type'] ?? '';
    info = map['info'] ?? '';
    locationLat = map['locationLat'] ?? '';
    locationLon = map['locationLon'] ?? '';
    views = map['views'] ?? '';
    isAccepted = map['isAccepted'] ?? '';
  }

  // to json
  Map<String, dynamic> toJson() {
    return {
      "reqId": reqId,
      "uid": uid,
      // Convert Dart DateTime to Firebase Timestamp
      "createdAt": createdAt,
      "amount": amount,
      "type": type,
      "info": info,
      "locationLat": locationLat,
      "locationLon": locationLon,
      "views": views,
      "isAccepted": isAccepted,
    };
  }
}
