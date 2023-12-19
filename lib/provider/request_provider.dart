import 'dart:developer';
import 'package:cashxchange/model/request_model.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
      // request exists
      return true;
    } else {
      // request is new
      return false;
    }
  }

  // upload request to firestore database

  Future<bool> uploadRequestToDatabase({
    required BuildContext context,
    required RequestModel request,
  }) async {
    try {
      await _firebaseFirestore
          .collection("request")
          .doc(request.reqId)
          .set(request.toJson())
          .then((value) async {
        _isLoading = false;
        notifyListeners();
      });
      return true;
    } catch (e) {
      log('error while uploading request: $e');
      return false;
    }
  }

  // update previous request
  Future<bool> updateRequestById({
    required String reqId,
    required String type,
    required String amount,
    required String info,
  }) async {
    try {
      await _firebaseFirestore.collection("request").doc(reqId).update({
        'type': type,
        'amount': amount,
        'info': info,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // delete request by id
  Future<void> deleteRequestById({required String reqId}) async {
    await _firebaseFirestore.collection("request").doc(reqId).delete();
  }

  // get active requests from firestore
  Future<List<RequestModel>> getActiveRequests({onlyMyRequests = false}) async {
    try {
      DateTime exp = DateTime.now().subtract(const Duration(hours: 90));
      QuerySnapshot querySnapshot;
      if (onlyMyRequests) {
        querySnapshot = await _firebaseFirestore
            .collection('request')
            .where('uid', isEqualTo: UserModel.instance.uid)
            .where('createdAt', isGreaterThan: exp)
            .get();
      } else {
        querySnapshot = await _firebaseFirestore
            .collection('request')
            .where('createdAt', isGreaterThan: exp)
            .get();
      }
      log('snapshot requests: ${querySnapshot.docs.length}');
      final List<RequestModel> documents = querySnapshot.docs
          .map((doc) =>
              RequestModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      // for (int i = 0; i < querySnapshot.docs.length; i++) {
      //   documents.add(RequestModel.fromJson(
      //       querySnapshot.docs[i].data() as Map<String, dynamic>));
      //   log('data: ${querySnapshot.docs[i].data()}');
      // }
      return documents;
    } catch (e) {
      return [];
    }
  }

  // get active requests from firestore
  Future<List<RequestModel>> getAllRequests(
    BuildContext context,
  ) async {
    try {
      QuerySnapshot querySnapshot;
      querySnapshot = await _firebaseFirestore
          .collection('request')
          .where('uid', isEqualTo: UserModel.instance.uid)
          .get();

      List<RequestModel> documents = querySnapshot.docs
          .map((doc) =>
              RequestModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return documents;
    } catch (e) {
      log('error while getting my requests: $e');
      return [];
    }
  }

  // get request using request id
  Stream<QuerySnapshot<Map<String, dynamic>>> getRequestById(
      BuildContext context, RequestModel request) {
    return _firebaseFirestore
        .collection('request')
        .where('uid', isEqualTo: request.reqId)
        .snapshots();
  }
}
