class UserModel {
  late String name;
  late String email;
  late String bio;
  late String profilePic;
  late String createdAt;
  late String phoneNumber;
  late String uid;
  late String address;
  late String locationLat;
  late String locationLon;
  late List<dynamic> connections;
  late bool isOnline;

  // Private constructor
  UserModel._privateConstructor() {
    name = "";
    email = "";
    bio = "";
    profilePic = "";
    createdAt = "";
    phoneNumber = "";
    uid = "";
    address = "";
    locationLat = "";
    locationLon = "";
    connections = [];
    isOnline = false;
  }

  // Static instance of UserModel
  static final UserModel _instance = UserModel._privateConstructor();

  // Getter for the singleton instance
  static UserModel get instance => _instance;

  // Initialization method
  void initializeUser({
    required String name,
    required String email,
    required String bio,
    required String profilePic,
    required String createdAt,
    required String phoneNumber,
    required String uid,
    required String address,
    required String locationLat,
    required String locationLon,
    required List<dynamic> connections,
    required bool isOnline,
  }) {
    this.name = name;
    this.email = email;
    this.bio = bio;
    this.profilePic = profilePic;
    this.createdAt = createdAt;
    this.phoneNumber = phoneNumber;
    this.uid = uid;
    this.address = address;
    this.locationLat = locationLat;
    this.locationLon = locationLon;
    this.connections = connections;
    this.isOnline = isOnline;
  }

  // from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    _instance.initializeUser(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      bio: map['bio'] ?? '',
      profilePic: map['profilePic'] ?? '',
      createdAt: map['createdAt'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      uid: map['uid'] ?? '',
      address: map['address'] ?? '',
      locationLat: map['locationLat'] ?? '',
      locationLon: map['locationLon'] ?? '',
      connections: map['connections'] ?? [],
      isOnline: map['isOnline'] ?? false,
    );
    return _instance;
  }

  // to map
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "email": email,
      "bio": bio,
      "profilePic": profilePic,
      "createdAt": createdAt,
      "phoneNumber": phoneNumber,
      "uid": uid,
      "address": address,
      "locationLat": locationLat,
      "locationLon": locationLon,
      "connections": connections,
      "isOnline": isOnline,
    };
  }
}
