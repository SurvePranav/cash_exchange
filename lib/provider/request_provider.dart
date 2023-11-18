import 'dart:convert';

import 'package:cashxchange/model/request_model.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/utils/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _reqid;
  String get reqid => _reqid!;

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  // set loading value while async processes
  void setLoading(bool loading) {
    if (loading) {
      _isLoading = true;
      notifyListeners();
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

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
    setLoading(true);
    try {
      // uploading new request info to database
      RequestModel.instance.createdAt = DateTime.now();

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
      setLoading(false);
      return true;
    } catch (e) {
      showSlackBar(context, e.toString());
      setLoading(false);
      return false;
    }
  }

  // get active requests from firestore
  Future<List<Map<String, dynamic>>> getActiveRequests(
      BuildContext context) async {
    try {
      DateTime exp = DateTime.now().subtract(const Duration(hours: 12));
      QuerySnapshot querySnapshot = await _firebaseFirestore
          .collection('request')
          .where('uid',
              isEqualTo: Provider.of<AuthProvider>(context, listen: false).uid)
          .where('createdAt', isGreaterThan: exp)
          .get();
      List<Map<String, dynamic>> documents = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      return documents;
    } catch (e) {
      showSlackBar(context, e.toString());
      return [];
    }
  }

  // get request using request id
  Future<void> getRequestById(BuildContext context, String reqId) async {
    try {
      await _firebaseFirestore
          .collection('request')
          .doc(reqId)
          .get()
          .then((DocumentSnapshot doc) {
        RequestModel.instance.initializeRequest(
          reqId: doc['reqId'],
          uid: doc['uid'],
          createdAt: doc['createdAt'].toDate(),
          amount: doc['amount'],
          type: doc['type'],
          info: doc['info'],
          locationLat: doc['locationLat'],
          locationLon: doc['locationLon'],
          views: doc['views'],
          isAccepted: doc['isAccepted'],
        );
      });
    } catch (e) {
      print("Exception Cought by me!!!!!!!!!!!!");
      showSlackBar(context, e.toString());
    }
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
