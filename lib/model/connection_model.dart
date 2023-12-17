class Connection {
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
  late bool isOnline;
  late String pushToken;
  late List<String> connections;

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
    required this.connections,
  });

  // From JSON
  Connection.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? '',
        email = json['email'] ?? '',
        bio = json['bio'] ?? '',
        profilePic = json['profilePic'] ?? '',
        createdAt = json['createdAt'] ?? '',
        phoneNumber = json['phoneNumber'] ?? '',
        uid = json['uid'] ?? '',
        address = json['address'] ?? '',
        locationLat = json['locationLat'] ?? '',
        locationLon = json['locationLon'] ?? '',
        isOnline = json['isOnline'] ?? false,
        pushToken = json['pushToken'] ?? '',
        connections = json['connections'] == null
            ? []
            : (json['connections'] as List<dynamic>)
                .map((e) => e.toString())
                .toList();

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'bio': bio,
      'profilePic': profilePic,
      'createdAt': createdAt,
      'phoneNumber': phoneNumber,
      'uid': uid,
      'address': address,
      'locationLat': locationLat,
      'locationLon': locationLon,
      'isOnline': isOnline,
      'pushToken': pushToken,
      'connections': connections,
    };
  }
}
