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

  // update previous request type amount and info
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

  // update location of the request
  Future<void> updateRequestLocation({
    required String reqId,
    required String lat,
    required String lng,
  }) async {
    try {
      await _firebaseFirestore.collection("request").doc(reqId).update({
        'type': lat,
        'amount': lng,
      });
    } catch (e) {
      log('could not update location');
    }
  }

  // update request acceptedBy field
  Future<void> updateRequestAcceptedBy(
      {required String reqId, bool remove = false, required String uid}) async {
    try {
      if (remove) {
        await _firebaseFirestore.collection("request").doc(reqId).update({
          'acceptedBy': FieldValue.arrayRemove([uid]),
        });
      } else {
        log('updating array...');
        await _firebaseFirestore.collection("request").doc(reqId).update({
          'acceptedBy': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      log('could not add user array');
    }
  }

  // update request confirm status
  Future<void> confirmRequest({
    required String reqId,
    required String uid,
  }) async {
    try {
      await _firebaseFirestore
          .collection("request")
          .doc(reqId)
          .update({'confirmedTo': uid});
    } catch (e) {
      log('could not confirmed');
    }
  }

  // delete request by id
  Future<void> deleteRequestById({required String reqId}) async {
    await _firebaseFirestore.collection("request").doc(reqId).delete();
  }

  // add user to accepted request of any request
  Future<void> addUserToAcceptedRequest(
      {required String reqId,
      required String uid,
      required String msg,
      required double lat,
      required double lng}) async {
    try {
      await _firebaseFirestore
          .collection("request")
          .doc(reqId)
          .collection('accepted_users')
          .doc(uid)
          .set({
        'uid': uid,
        'date': DateTime.now().millisecondsSinceEpoch,
        'msg': msg,
        'isConfirmed': false,
        'lat': lat,
        'lng': lng,
      });
      await updateRequestAcceptedBy(reqId: reqId, uid: uid);
    } catch (e) {
      log('could not add user to accepted request');
    }
  }

  // get active requests from firestore
  Future<List<RequestModel>> getActiveRequests({onlyMyRequests = false}) async {
    try {
      int exp = DateTime.now().millisecondsSinceEpoch;
      int sevenDaysAgo = exp - (7 * 24 * 60 * 60 * 1000);
      QuerySnapshot querySnapshot;
      if (onlyMyRequests) {
        querySnapshot = await _firebaseFirestore
            .collection('request')
            .where('uid', isEqualTo: UserModel.instance.uid)
            .where('createdAt', isGreaterThan: sevenDaysAgo)
            .get();
      } else {
        querySnapshot = await _firebaseFirestore
            .collection('request')
            .where('createdAt', isGreaterThan: sevenDaysAgo)
            .get();
      }
      log('snapshot requests: ${querySnapshot.docs.length}');
      final List<RequestModel> documents = querySnapshot.docs
          .map((doc) =>
              RequestModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      return documents;
    } catch (e) {
      return [];
    }
  }

  // get active requests stream from firestore
  Stream<QuerySnapshot<Map<String, dynamic>>> getActiveRequestsAsStream(
      {onlyMyRequests = false}) {
    try {
      int exp = DateTime.now().millisecondsSinceEpoch;
      int sevenDaysAgo = exp - (7 * 24 * 60 * 60 * 1000);
      if (onlyMyRequests) {
        return _firebaseFirestore
            .collection('request')
            .where('uid', isEqualTo: UserModel.instance.uid)
            .where('createdAt', isGreaterThan: sevenDaysAgo)
            .snapshots();
      } else {
        return _firebaseFirestore
            .collection('request')
            .where('createdAt', isGreaterThan: sevenDaysAgo)
            .where('confirmedTo', isEqualTo: '')
            .snapshots();
      }
    } catch (e) {
      return const Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    }
  }

  Future<List<RequestModel>> getRequestsConfirmedToMe(
    BuildContext context,
  ) async {
    try {
      QuerySnapshot querySnapshot;
      querySnapshot = await _firebaseFirestore
          .collection('request')
          .where('confirmedTo', isEqualTo: UserModel.instance.uid)
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

  // get my active requests from firestore
  Future<List<RequestModel>> getMyRequests(
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
  Stream<DocumentSnapshot<Map<String, dynamic>>> getRequestById(
      BuildContext context, String reqId) {
    return _firebaseFirestore.collection('request').doc(reqId).snapshots();
  }

  // get request meta data using userId and reqId
  Future<DocumentSnapshot<Map<String, dynamic>>> getRequestMetaData(
      {required reqId, required uid}) {
    return _firebaseFirestore
        .collection('request')
        .doc(reqId)
        .collection('accepted_users')
        .doc(uid)
        .get();
  }
}
