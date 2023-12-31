import 'package:cached_network_image/cached_network_image.dart';
import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/model/connection_model.dart';
import 'package:cashxchange/model/message_model.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/provider/messaging_provider.dart';
import 'package:cashxchange/utils/date_util.dart';
import 'package:cashxchange/widgets/dialogs/profile_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef MyCallBack = Function(Connection connection);

class ChatTile extends StatefulWidget {
  final String uid;
  final MyCallBack onTap;
  const ChatTile({super.key, required this.uid, required this.onTap});
  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  Message? _message;
  late Connection _connection;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Provider.of<AuthProvider>(context, listen: false)
          .getUserById(widget.uid),
      builder: (BuildContext context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return const SizedBox();
          case ConnectionState.active:
          case ConnectionState.done:
            final mydata = snapshot.data;
            if (mydata != null) {
              _connection = Connection.fromJson(mydata.data()!);
            }
            return StreamBuilder(
              stream: Provider.of<MessagingProvider>(context, listen: false)
                  .getLastMessage(widget.uid),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                if (data != null && data.first.exists) {
                  _message = Message.fromJson(data.first.data());
                }
                return InkWell(
                  onTap: () {
                    widget.onTap(_connection);
                  },
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 10, bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        ProfileDialog(connection: _connection),
                                  );
                                },
                                child: CircleAvatar(
                                  backgroundColor: AppColors.deepGreen,
                                  backgroundImage: const AssetImage(
                                      'assets/images/profile_icon.png'),
                                  foregroundImage: CachedNetworkImageProvider(
                                      _connection.profilePic),
                                  maxRadius: 30,
                                ),
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              Expanded(
                                child: Container(
                                  color: Colors.transparent,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        _connection.name,
                                        maxLines: 1,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      Row(
                                        children: [
                                          if (_message != null &&
                                              _message!.fromId ==
                                                  UserModel.instance.uid)
                                            _message!.read.isNotEmpty
                                                ? const Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 5),
                                                    child: Icon(
                                                      Icons.done_all_rounded,
                                                      color: Colors.blue,
                                                      size: 20,
                                                    ),
                                                  )
                                                : const Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 5),
                                                    child: Icon(
                                                      Icons.done,
                                                      color: Colors.grey,
                                                      size: 20,
                                                    ),
                                                  ),
                                          Text(
                                            _message != null
                                                ? _message!.type == MsgType.text
                                                    ? _message!.fromId ==
                                                            UserModel
                                                                .instance.uid
                                                        ? "You: ${_message!.msg}"
                                                        : _message!.msg
                                                    : _message!.type ==
                                                            MsgType.image
                                                        ? _message!.fromId ==
                                                                UserModel
                                                                    .instance
                                                                    .uid
                                                            ? "You: 📷 Photo"
                                                            : "📷 Photo"
                                                        : _message!.fromId ==
                                                                UserModel
                                                                    .instance
                                                                    .uid
                                                            ? "You: Accepted Request"
                                                            : "Accepted Request"
                                                : "✍️ ${_connection.bio}",
                                            maxLines: 1,
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _message == null
                            ? const SizedBox()
                            : Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    MyDateUtil.getLastMessageTime(
                                        context: context, time: _message!.sent),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: _message!.read.isEmpty ? 11 : 25,
                                  ),
                                  if (_message!.fromId !=
                                          UserModel.instance.uid &&
                                      _message!.read.isEmpty)
                                    Container(
                                      height: 14,
                                      width: 14,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(7),
                                        color: Colors.green,
                                      ),
                                    ),
                                ],
                              )
                      ],
                    ),
                  ),
                );
              },
            );
        }
      },
    );
  }
}
