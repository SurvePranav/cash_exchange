import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cashxchange/model/connection_model.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/screens/auth_module_screens/otp_screen.dart';
import 'package:cashxchange/utils/location_services.dart';
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

  ////////////////////////////////////***************** Authentication Module Database operations  ****************///////////////////////////////// */

// check if user is signed in or not
  Future<void> checkSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool("is_signedin") ?? false;
    notifyListeners();
  }

// set user as signed in
  Future<void> setSignedIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.setBool("is_signedin", true);
    _isSignedIn = true;
    notifyListeners();
  }

  // sign in using phone number
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
      MyAppServices.showSnackBar(context, e.message.toString());
    } catch (e) {
      // hide progress dialog
      Navigator.of(context).pop();
      MyAppServices.showSnackBar(context, e.toString());
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

      // User? user =
      await _firebaseAuth
          .signInWithCredential(creds)
          .then((userCredential) async {
        User? user = userCredential.user;
        if (user != null) {
          // carry out logic
          _uid = user.uid;
          await onSuccess();
        } else {
          MyAppServices.showSnackBar(context, 'something went wrong');
          throw Exception("something went wrong");
        }
      });
    } catch (e) {
      // when otp verification failed
      log('verification failed: $e');
    }
  }

  // //////////////////////////                  database operations on user data for profile module  ///////////////******************** */

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
        final ext = profilePic.path.split('.').last;
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
        await storeFileToStroage("profilePic/$_uid.$ext", profilePic)
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
      log('error while uploading user data: $e');
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
  Future<void> updateUserActiveStatus(bool isOnline,
      {bool removePushToken = false}) async {
    _firebaseFirestore.collection('users').doc(UserModel.instance.uid).update({
      'isOnline': isOnline,
      'pushToken': removePushToken ? "" : UserModel.instance.pushToken,
    });
  }

  ////////////////////////////////////*********** Chatting Module and Connections Operations */ *******/////////////////

  // add new connection to my connections
  Future<void> addToMyConnection({
    required Connection user,
  }) async {
    _firebaseFirestore
        .collection('users')
        .doc(UserModel.instance.uid)
        .collection('my_connections')
        .doc(user.uid)
        .set({
      'uid': user.uid,
      'canMessage': true,
      'primary': true,
      'lastMessage': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': user.name,
      'hasUnreadMessage': false,
    });
    if (!UserModel.instance.connections.contains(user.uid)) {
      UserModel.instance.connections.add(user.uid);
      _firebaseFirestore.collection('users').doc(UserModel.instance.uid).update(
        {
          'connections': UserModel.instance.connections,
        },
      );
      saveDataToSP();
    }
  }

  // add new connection to senders connections(sedondary)
  Future<void> addToReceiversConnection({required Connection user}) async {
    _firebaseFirestore
        .collection('users')
        .doc(user.uid)
        .collection('my_connections')
        .doc(UserModel.instance.uid)
        .set({
      'uid': UserModel.instance.uid,
      'canMessage': true,
      'primary': false,
      'lastMessage': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': UserModel.instance.name,
      'hasUnreadMessage': true,
    });
  }

  // update last message time for my_connections collection
  void updateLastMessageTime({required String fromId, required String toId}) {
    _firebaseFirestore
        .collection('users')
        .doc(fromId)
        .collection('my_connections')
        .doc(toId)
        .update({
      'lastMessage': DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }

// update connections has message status
  void updateHasUnreadMessage(
      {required String uid,
      required bool hasUnreadMessage,
      required bool updateInMyConnections}) {
    _firebaseFirestore
        .collection('users')
        .doc(updateInMyConnections ? UserModel.instance.uid : uid)
        .collection('my_connections')
        .doc(updateInMyConnections ? uid : UserModel.instance.uid)
        .update({
      'hasUnreadMessage': hasUnreadMessage,
    });
  }

  // get unread chats count to display badge on chat icon
  static Stream<List<int>> getUnreadChatsCount() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(UserModel.instance.uid)
        .collection('my_connections')
        .where('hasUnreadMessage', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      int totalUnread = snapshot.docs.length;
      int primaryUnread =
          snapshot.docs.where((doc) => doc.data()['primary'] == false).length;
      return [totalUnread, primaryUnread];
    });
  }

  // update connection to priority primary or secondary
  Future<void> updateConnectionPriority({
    required String senderUid,
    required bool primary,
  }) async {
    if (primary) {
      _firebaseFirestore
          .collection('users')
          .doc(UserModel.instance.uid)
          .collection('my_connections')
          .doc(senderUid)
          .update({
        'primary': true,
      });
      if (!UserModel.instance.connections.contains(senderUid)) {
        UserModel.instance.connections.add(senderUid);
        _firebaseFirestore
            .collection('users')
            .doc(UserModel.instance.uid)
            .update(
          {
            'connections': UserModel.instance.connections,
          },
        );
        saveDataToSP();
      }
    } else {
      _firebaseFirestore
          .collection('users')
          .doc(UserModel.instance.uid)
          .collection('my_connections')
          .doc(senderUid)
          .update({
        'primary': false,
      });
      if (UserModel.instance.connections.contains(senderUid)) {
        UserModel.instance.connections.remove(senderUid);
        _firebaseFirestore
            .collection('users')
            .doc(UserModel.instance.uid)
            .update(
          {
            'connections': UserModel.instance.connections,
          },
        );
        saveDataToSP();
      }
    }
  }

// remove connection from both users
  Future<void> removeConnection({
    required Connection connection,
  }) async {
    _firebaseFirestore
        .collection('users')
        .doc(UserModel.instance.uid)
        .collection('my_connections')
        .doc(connection.uid)
        .delete();
    _firebaseFirestore
        .collection('users')
        .doc(connection.uid)
        .collection('my_connections')
        .doc(UserModel.instance.uid)
        .delete();

    if (UserModel.instance.connections.contains(connection.uid)) {
      UserModel.instance.connections.remove(connection.uid);
      _firebaseFirestore.collection('users').doc(UserModel.instance.uid).update(
        {
          'connections': UserModel.instance.connections,
        },
      );
      saveDataToSP();
    }
    if (connection.connections.contains(UserModel.instance.uid)) {
      var updatedConnections = connection.connections;
      updatedConnections.remove(UserModel.instance.uid);
      _firebaseFirestore.collection('users').doc(connection.uid).update(
        {
          'connections': updatedConnections,
        },
      );
    }
  }

  // get my connections info by id as stream
  Stream<DocumentSnapshot<Map<String, dynamic>>> getConnectionInfo(
      {required String userId}) {
    return _firebaseFirestore
        .collection('users')
        .doc(UserModel.instance.uid)
        .collection('my_connections')
        .doc(userId)
        .snapshots();
  }

  // get my connections (primary or secondary) as stream
  Stream<QuerySnapshot<Map<String, dynamic>>> getMyConnections(
      {required bool primary}) {
    return _firebaseFirestore
        .collection('users')
        .doc(UserModel.instance.uid)
        .collection('my_connections')
        .where('primary', isEqualTo: primary)
        .orderBy('lastMessage', descending: true)
        .snapshots();
  }

// check if user is connected or not
  Future<bool> checkIfUsersConnectedBefore(String userId) async {
    final querySnapshot = await _firebaseFirestore
        .collection('users')
        .doc(UserModel.instance.uid)
        .collection('my_connections')
        .where('uid', isEqualTo: userId)
        .limit(1)
        .get();

    // Check if there are any documents that match the query
    return querySnapshot.docs.isNotEmpty;
  }

  ////////////////////////////////////  ***********    retriving other users information **********    ///////////////
  // get nearby users
  Future<List<Connection>> getNearbyUsers(double lat, double lng) async {
    try {
      QuerySnapshot querySnapshot;
      querySnapshot = await _firebaseFirestore
          .collection('users')
          .where('uid', isNotEqualTo: UserModel.instance.uid)
          .get();

      final List<Connection> documents = [];
      List<Connection> allUsers = querySnapshot.docs
          .map((doc) => Connection.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      for (int i = 0; i < allUsers.length; i++) {
        double distance = LocationServices.findDistanceBetweenCoordinates(
            double.parse(allUsers[i].locationLat),
            double.parse(allUsers[i].locationLon),
            lat,
            lng);
        log('distance from me: $distance');
        if (distance < 2000) {
          documents.add(allUsers[i]);
        }
      }
      return documents;
    } catch (e) {
      log('error while getting my requests: $e');
      return [];
    }
  }

  // get all users stream accept me
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('uid', isNotEqualTo: UserModel.instance.uid)
        .snapshots();
  }

  /// get single user stream by id
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserById(String uid) {
    return _firebaseFirestore.collection('users').doc(uid).snapshots();
  }
}
