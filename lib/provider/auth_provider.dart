import 'dart:convert';
import 'dart:io';

import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/screens/otp_screen.dart';
import 'package:cashxchange/utils/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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

  Future<void> checkSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool("is_signedin") ?? false;
    notifyListeners();
  }

  void setSignedIn() async {
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
          print("Verification Failed: ${error.message.toString()}");
          throw Exception(error.message.toString());
        },
        codeSent: (verificationId, forceResendingToken) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OTPScreen(verificationId: verificationId),
            ),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      showSlackBar(context, e.message.toString());
    } catch (e) {
      showSlackBar(context, e.toString());
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
    required BuildContext context,
    required String verificationId,
    required String userOtp,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      PhoneAuthCredential creds = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userOtp,
      );

      User? user = (await _firebaseAuth.signInWithCredential(creds)).user;

      if (user != null) {
        // carry out logic
        _uid = user.uid;
        onSuccess();
      }

      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      showSlackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  // database operations

  Future<bool> checkIfUserExists() async {
    DocumentSnapshot snapshot =
        await _firebaseFirestore.collection("users").doc(_uid).get();

    if (snapshot.exists) {
      print("User Exisit!");
      return true;
    } else {
      print("New User");
      return false;
    }
  }

  // Upload User data to firebase database

  Future<void> saveUserDataToFirebase({
    required BuildContext context,
    required File profilePic,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Uploading Image To Fierebase Storage
      await storeFileToStroage("profilePic/$_uid", profilePic).then((value) {
        UserModel.instance.profilePic = value;
        UserModel.instance.createdAt =
            DateTime.now().millisecondsSinceEpoch.toString();
        UserModel.instance.phoneNumber =
            _firebaseAuth.currentUser!.phoneNumber!;
        UserModel.instance.uid = _firebaseAuth.currentUser!.uid;
        notifyListeners();
      });

      // uploading all user info to database
      await _firebaseFirestore
          .collection("users")
          .doc(_uid)
          .set(UserModel.instance.toMap())
          .then((value) {
        onSuccess();
        _isLoading = false;
        notifyListeners();
      });
    } on FirebaseAuthException catch (e) {
      showSlackBar(context, e.toString());
      _isLoading = false;
      notifyListeners();
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
      );
      _uid = UserModel.instance.uid;
      notifyListeners();
    });
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
}
