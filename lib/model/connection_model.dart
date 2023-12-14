class Connection {
  Connection({
    required this.name,
    required this.email,
    required this.bio,
    required this.profilePic,
    required this.createdAt,
    required this.phoneNumber,
    required this.uid,
    required this.address,
    required this.locationLat,
    required this.locationLon,
    required this.isOnline,
    required this.pushToken,
  });

  late final String name;
  late final String email;
  late final String bio;
  late final String profilePic;
  late final String createdAt;
  late final String phoneNumber;
  late final String uid;
  late final String address;
  late final String locationLat;
  late final String locationLon;
  late final bool isOnline;
  late final String pushToken;

  // from json
  Connection.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    email = json['email'] ?? '';
    bio = json['bio'] ?? '';
    profilePic = json['profilePic'] ?? '';
    createdAt = json['createdAt'] ?? '';
    phoneNumber = json['phoneNumber'] ?? '';
    uid = json['uid'] ?? '';
    address = json['address'] ?? '';
    locationLat = json['locationLat'] ?? '';
    locationLon = json['locationLon'] ?? '';
    isOnline = json['isOnline'] ?? false;
    pushToken = json['pushToken'] ?? '';
  }

  // to json
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['email'] = email;
    data['bio'] = bio;
    data['profilePic'] = profilePic;
    data['createdAt'] = createdAt;
    data['phoneNumber'] = phoneNumber;
    data['uid'] = uid;
    data['address'] = address;
    data['locationLat'] = locationLat;
    data['locationLon'] = locationLon;
    data['isOnline'] = isOnline;
    data['pushToken'] = pushToken;
    return data;
  }

  // to string override
  @override
  String toString() {
    return 'Connection {'
        'name: $name, '
        'email: $email, '
        'bio: $bio, '
        'profilePic: $profilePic, '
        'createdAt: $createdAt, '
        'phoneNumber: $phoneNumber, '
        'uid: $uid, '
        'address: $address, '
        'isOnline: $isOnline, '
        'pushToken: $pushToken, '
        'locationLat: $locationLat, '
        'locationLon: $locationLon'
        '}';
  }
}
