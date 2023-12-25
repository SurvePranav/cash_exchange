class RequestModel {
  late String reqId;
  late String uid;
  late int createdAt;
  late String amount;
  late String type;
  late String info;
  late double locationLat;
  late double locationLon;
  late List<String> acceptedBy;
  late String confirmedTo;

  // Initialization constructor
  RequestModel({
    required this.reqId,
    required this.uid,
    required this.createdAt,
    required this.amount,
    required this.type,
    required this.info,
    required this.locationLat,
    required this.locationLon,
    required this.acceptedBy,
    required this.confirmedTo,
  });

  // from json
  RequestModel.fromJson(Map<String, dynamic> map) {
    reqId = map['reqId'] ?? '';
    uid = map['uid'] ?? '';
    createdAt = map['createdAt'];
    amount = map['amount'] ?? '';
    type = map['type'] ?? '';
    info = map['info'] ?? '';
    locationLat = map['locationLat'] ?? '';
    locationLon = map['locationLon'] ?? '';
    acceptedBy = map['acceptedBy'] == null
        ? []
        : (map['acceptedBy'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
    confirmedTo = map['confirmedTo'] ?? '';
  }

  // to json
  Map<String, dynamic> toJson() {
    return {
      "reqId": reqId,
      "uid": uid,
      "createdAt": createdAt,
      "amount": amount,
      "type": type,
      "info": info,
      "locationLat": locationLat,
      "locationLon": locationLon,
      "acceptedBy": acceptedBy,
      "confirmedTo": confirmedTo,
    };
  }
}
