class Message {
  Message({
    required this.toId,
    required this.msg,
    required this.read,
    required this.type,
    required this.sent,
    required this.fromId,
  });
  late final String toId;
  late final String msg;
  late final String read;
  late final MsgType type;
  late final String sent;
  late final String fromId;

  Message.fromJson(Map<String, dynamic> json) {
    toId = json['toId'].toString();
    msg = json['msg'].toString();
    read = json['read'].toString();
    type = json['type'].toString() == MsgType.text.name
        ? MsgType.text
        : json['type'].toString() == MsgType.image.name
            ? MsgType.image
            : MsgType.custom;
    sent = json['sent'].toString();
    fromId = json['fromId'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['toId'] = toId;
    data['msg'] = msg;
    data['read'] = read;
    data['type'] = type.name;
    data['sent'] = sent;
    data['fromId'] = fromId;
    return data;
  }
}

enum MsgType { text, image, custom }
