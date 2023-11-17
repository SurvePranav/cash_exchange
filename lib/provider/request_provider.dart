import 'dart:convert';

import 'package:cashxchange/model/request_model.dart';
import 'package:cashxchange/utils/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _reqid;
  String get reqid => _reqid!;

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  // database operations

  Future<bool> checkIfRequestExists() async {
    DocumentSnapshot snapshot =
        await _firebaseFirestore.collection("requests").doc(_reqid).get();

    if (snapshot.exists) {
      print("Request Exisit!");
      return true;
    } else {
      print("New Request");
      return false;
    }
  }

  // upload request to firestore database

  Future<bool> uploadRequestToDatabase({
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // uploading new request info to database
      RequestModel.instance.createdAt = DateTime.now().toString();
      RequestModel.instance.expiration =
          DateTime.now().add(const Duration(hours: 12)).toString();

      await _firebaseFirestore
          .collection("request")
          .add(RequestModel.instance.toMap())
          .then((value) async {
        await value.update({'reqId': value.id});
        RequestModel.instance.reqId = value.id;
        _reqid = value.id;
        _isLoading = false;
        notifyListeners();
      });
      return true;
    } on FirebaseException catch (e) {
      showSlackBar(context, e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
    return false;
  }

  // get data from firestore
  Future getDataFromFireStroe() async {
    await _firebaseFirestore
        .collection("request")
        .doc(_reqid)
        .get()
        .then((DocumentSnapshot snapshot) {
      RequestModel.instance.initializeRequest(
        reqId: snapshot['reqId'],
        uid: snapshot['uid'],
        createdAt: snapshot['createdAt'],
        amount: snapshot['amount'],
        type: snapshot['type'],
        info: snapshot['info'],
        locationLat: snapshot['locationLat'],
        locationLon: snapshot['locationLon'],
        views: snapshot['views'],
        expiration: snapshot['expiration'],
        isAccepted: snapshot['isAccepted'],
      );
      _reqid = RequestModel.instance.reqId;
      notifyListeners();
    });
  }

  // Storing Data locally(shared preference)
  Future saveDataToSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await s.setString(
        "request_model", jsonEncode(RequestModel.instance.toMap()));
  }

  // Get Data From local (shared preference)
  Future getDataFromSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    String data = s.getString("request_model") ?? "";
    RequestModel.fromMap(jsonDecode(data));
    _reqid = RequestModel.instance.reqId;
    notifyListeners();
  }
}
