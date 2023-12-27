class MyNotification {
  MyNotification({
    required this.id,
    required this.uid,
    required this.title,
    required this.body,
    required this.timeStamp,
    required this.isSeen,
  });
  late final String id;
  late final String uid;
  late final String title;
  late final String body;
  late final int timeStamp;
  late final bool isSeen;

  MyNotification.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    uid = json['uid'].toString();
    title = json['title'].toString();
    body = json['body'].toString();
    timeStamp = json['timeStamp'];
    isSeen = json['isSeen'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['uid'] = uid;
    data['title'] = title;
    data['body'] = body;
    data['timeStamp'] = timeStamp;
    data['isSeen'] = isSeen;
    return data;
  }
}
