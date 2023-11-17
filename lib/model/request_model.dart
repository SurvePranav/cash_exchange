class RequestModel {
  late String reqId;
  late String uid;
  late String createdAt;
  late String amount;
  late String type;
  late String info;
  late String locationLat;
  late String locationLon;
  late String views;
  late String expiration;
  late bool isAccepted;
  // late String

  // Private constructor
  RequestModel._privateConstructor() {
    reqId = "";
    uid = "";
    createdAt = "";
    amount = "";
    type = "";
    info = "";
    locationLat = "";
    locationLon = "";
    views = "";
    expiration = "";
    isAccepted = false;
  }

  // Static instance of UserModel
  static final RequestModel _instance = RequestModel._privateConstructor();

  // Getter for the singleton instance
  static RequestModel get instance => _instance;

  // Initialization method
  void initializeRequest({
    required String reqId,
    required String uid,
    required String createdAt,
    required String amount,
    required String type,
    required String info,
    required String locationLat,
    required String locationLon,
    required String views,
    required String expiration,
    required bool isAccepted,
  }) {
    this.reqId = reqId;
    this.uid = uid;
    this.amount = amount;
    this.createdAt = createdAt;
    this.type = type;
    this.info = info;
    this.locationLat = locationLat;
    this.locationLon = locationLon;
    this.views = views;
    this.expiration = expiration;
    this.isAccepted = isAccepted;
  }

  // from Map
  factory RequestModel.fromMap(Map<String, dynamic> map) {
    _instance.initializeRequest(
      reqId: map['reqId'] ?? '',
      uid: map['uid'] ?? '',
      createdAt: map['createdAt'] ?? '',
      amount: map['amount'] ?? '',
      type: map['type'] ?? '',
      info: map['info'] ?? '',
      locationLat: map['locationLat'] ?? '',
      locationLon: map['locationLon'] ?? '',
      views: map['views'] ?? '',
      expiration: map['expiration'] ?? '',
      isAccepted: map['isAccepted'] ?? '',
    );
    return _instance;
  }

  // to map
  Map<String, dynamic> toMap() {
    return {
      "reqId": reqId,
      "uid": uid,
      "createdAt": createdAt,
      "amount": amount,
      "type": type,
      "info": info,
      "locationLat": locationLat,
      "locationLon": locationLon,
      "views": views,
      "expiration": expiration,
      "isAccepted": isAccepted,
    };
  }
}
