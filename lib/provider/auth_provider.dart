import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cashxchange/model/connection_model.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/screens/auth_module_screens/otp_screen.dart';
import 'package:cashxchange/utils/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _uid;
  String get uid => _uid!;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  AuthProvider() {
    checkSignIn();
  }

  void setLoading(bool loading) {
    if (loading) {
      _isLoading = true;
      notifyListeners();
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool("is_signedin") ?? false;
    notifyListeners();
  }

  Future<void> setSignedIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.setBool("is_signedin", true);
    _isSignedIn = true;
    notifyListeners();
  }

  // sign in
  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (phoneAuthCredential) async {
          await _firebaseAuth.signInWithCredential(phoneAuthCredential);
        },
        verificationFailed: (error) {
          throw Exception(error.message.toString());
        },
        codeSent: (verificationId, forceResendingToken) {
          // to hide progress dialog
          Navigator.of(context).pop();

          // to navigate to otp verification screen
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (context) => OTPScreen(verificationId: verificationId),
            ),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      // hide progresss dialog
      Navigator.of(context).pop();
      MyAppServices.showSlackBar(context, e.message.toString());
    } catch (e) {
      // hide progress dialog
      Navigator.of(context).pop();
      MyAppServices.showSlackBar(context, e.toString());
    }
  }

  // signout user
  Future userSignOut() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await _firebaseAuth.signOut();
    _isSignedIn = false;
    notifyListeners();
    s.clear();
  }

  // verify otp
  void verifyOtp({
    required String verificationId,
    required String userOtp,
    required Function onSuccess,
    required BuildContext context,
  }) async {
    try {
      PhoneAuthCredential creds = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userOtp,
      );

      User? user = (await _firebaseAuth.signInWithCredential(creds)).user;

      if (user != null) {
        // carry out logic
        _uid = user.uid;
        await onSuccess();
      } else {
        throw Exception("something went wrong");
      }
    } on Exception {
      // when otp verification failed
      MyAppServices.showSlackBar(context, 'something went wrong');
    }
  }

  ////////////////////////////////////***************** Authentication Functions End Here   ****************///////////////////////////////// */

  // database operations

  Future<bool> checkIfUserExists() async {
    DocumentSnapshot snapshot =
        await _firebaseFirestore.collection("users").doc(_uid).get();

    if (snapshot.exists) {
      // User Exisit!
      return true;
    } else {
      //"New User"
      return false;
    }
  }

  // Upload User data to firebase database

  Future<void> saveUserDataToFirebase({
    required BuildContext context,
    required File? profilePic,
    required Function onSuccess,
    bool updateData = false,
  }) async {
    setLoading(true);

    try {
      if (updateData && profilePic != null) {
        // update user info and profile pic both
        final ext = profilePic!.path.split('.').last;
        await storeFileToStroage("profilePic/$_uid.$ext", profilePic)
            .then((value) {
          UserModel.instance.profilePic = value;
          notifyListeners();
        });
      } else if (updateData && profilePic == null) {
        // update only user info and not profile pic
      } else {
        // creating new user --- uploading info and image
        // Uploading Image To Fierebase Storage
        final ext = profilePic!.path.split('.').last;
        await storeFileToStroage("profilePic/$_uid.$ext", profilePic!)
            .then((value) async {
          UserModel.instance.profilePic = value;
          UserModel.instance.createdAt =
              DateTime.now().millisecondsSinceEpoch.toString();
          UserModel.instance.phoneNumber =
              _firebaseAuth.currentUser!.phoneNumber!;
          UserModel.instance.uid = _firebaseAuth.currentUser!.uid;

          notifyListeners();
        });
      }

      // uploading all user info to database
      await _firebaseFirestore
          .collection("users")
          .doc(_uid)
          .set(UserModel.instance.toMap())
          .then((value) {
        onSuccess();
        setLoading(false);
      });
    } on FirebaseAuthException catch (e) {
      MyAppServices.showSlackBar(context, e.toString());
      setLoading(false);
    }
  }

  // get data from firestore
  Future getDataFromFireStroe() async {
    await _firebaseFirestore
        .collection("users")
        .doc(_firebaseAuth.currentUser!.uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      UserModel.instance.initializeUser(
        name: snapshot['name'],
        email: snapshot['email'],
        bio: snapshot['bio'],
        profilePic: snapshot['profilePic'],
        createdAt: snapshot['createdAt'],
        phoneNumber: snapshot['phoneNumber'],
        uid: snapshot['uid'],
        address: snapshot['address'],
        locationLat: snapshot['locationLat'],
        locationLon: snapshot['locationLon'],
        isOnline: snapshot['isOnline'] ?? false,
        pushToken: snapshot['pushToken'] ?? '',
        connections: (snapshot['connections'] as List<dynamic>)
            .map((e) => e.toString())
            .toList(),
      );
      _uid = UserModel.instance.uid;
      notifyListeners();
    });
  }

  // retrive user info by id
  Future<Map<String, dynamic>> getUserDataById({required String uid}) async {
    final data = await _firebaseFirestore.collection("users").doc(uid).get();
    return data.data() ?? {};
  }

  // upload image file fuc
  Future<String> storeFileToStroage(String ref, File file) async {
    UploadTask uploadTask = _firebaseStorage.ref().child(ref).putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // Storing Data locally(shared preference)
  Future saveDataToSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await s.setString("user_model", jsonEncode(UserModel.instance.toMap()));
  }

  // Get Data From local (shared preference)
  Future getDataFromSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    String data = s.getString("user_model") ?? "";
    UserModel.fromMap(jsonDecode(data));
    _uid = UserModel.instance.uid;
    notifyListeners();
  }

  // update user's active status
  Future<void> updateUserActiveStatus(bool isOnline) async {
    _firebaseFirestore.collection('users').doc(UserModel.instance.uid).update({
      'isOnline': isOnline,
      'pushToken': UserModel.instance.pushToken,
    });
  }

  // add new connection to senders connections(sedondary)
  Future<void> addToReceiversConnection({required String receiverUid}) async {
    _firebaseFirestore
        .collection('users')
        .doc(receiverUid)
        .collection('my_connections')
        .doc(UserModel.instance.uid)
        .set({
      'uid': UserModel.instance.uid,
      'canMessage': true,
      'primary': false,
    });
  }

  // add new connection to my connections
  Future<void> addToMyConnection({
    required String senderUid,
  }) async {
    _firebaseFirestore
        .collection('users')
        .doc(UserModel.instance.uid)
        .collection('my_connections')
        .doc(senderUid)
        .set({
      'uid': uid,
      'canMessage': true,
      'primary': true,
    });
    _firebaseFirestore.collection('users').doc(UserModel.instance.uid).update(
      {
        'connections': FieldValue.arrayUnion([uid]),
      },
    );
    UserModel.instance.connections.add(uid);
    saveDataToSP();
  }

  // get my connections stream (primary)
  Stream<QuerySnapshot<Map<String, dynamic>>> getMyConnections(
      List<String> users) {
    log("my connections: ${UserModel.instance.connections}");
    if (users.isNotEmpty) {
      return _firebaseFirestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: users)
          .snapshots();
    } else {
      return const Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    }
  }

  // get my secondary connections
  Stream<QuerySnapshot<Map<String, dynamic>>> getMySecondaryConnections() {
    return _firebaseFirestore
        .collection('users')
        .doc(UserModel.instance.uid)
        .collection('my_connections')
        .where('primary', isEqualTo: false)
        .snapshots();
  }

// check if user is connected or not
  Future<bool> checkIfUsersConnectedBefore(String userId) async {
    final querySnapshot = await _firebaseFirestore
        .collection('users')
        .doc(UserModel.instance.uid)
        .collection('my_connections')
        .where('uid', isEqualTo: userId)
        .get();

    // Check if there are any documents that match the query
    return querySnapshot.docs.isNotEmpty;
  }

  // get all users stream accept me
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('uid', isNotEqualTo: UserModel.instance.uid)
        .snapshots();
  }

  /// get single user stream by id
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserById(String uid) {
    return _firebaseFirestore
        .collection('users')
        .where('uid', isEqualTo: uid)
        .snapshots();
  }
}
