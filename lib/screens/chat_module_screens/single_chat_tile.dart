import 'package:cached_network_image/cached_network_image.dart';
import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/model/connection_model.dart';
import 'package:cashxchange/model/message_model.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/messaging_provider.dart';
import 'package:cashxchange/utils/date_util.dart';
import 'package:cashxchange/widgets/dialogs/profile_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef MyCallBack = Function(Connection connection);

class ChatTile extends StatefulWidget {
  final Connection connection;
  final MyCallBack onTap;
  const ChatTile({super.key, required this.connection, required this.onTap});
  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  Message? _message;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Provider.of<MessagingProvider>(context, listen: false)
            .getLastMessage(widget.connection),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          if (data != null) {
            final list =
                data.map((e) => Connection.fromJson(e.data())).toList();
            if (list.isNotEmpty) {
              _message = Message.fromJson(data.first.data());
            }
          }

          return InkWell(
            onTap: () {
              widget.onTap(widget.connection);
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
                                  ProfileDialog(connection: widget.connection),
                            );
                          },
                          child: CircleAvatar(
                            backgroundColor: AppColors.deepGreen,
                            backgroundImage: const AssetImage(
                                'assets/images/profile_icon.png'),
                            foregroundImage: CachedNetworkImageProvider(
                                widget.connection.profilePic),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  widget.connection.name,
                                  maxLines: 1,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  _message != null
                                      ? _message!.type == MsgType.text
                                          ? _message!.fromId ==
                                                  UserModel.instance.uid
                                              ? "You: ${_message!.msg}"
                                              : _message!.msg
                                          : _message!.type == MsgType.image
                                              ? _message!.fromId ==
                                                      UserModel.instance.uid
                                                  ? "You: 📷 Photo"
                                                  : "📷 Photo"
                                              : "Request"
                                      : "✍️ ${widget.connection.bio}",
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
                          ),
                        ),
                      ],
                    ),
                  ),
                  _message == null
                      ? const SizedBox()
                      : _message!.fromId != UserModel.instance.uid &&
                              _message!.read.isEmpty
                          ? Container(
                              height: 12,
                              width: 12,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.green,
                              ),
                            )
                          : Text(
                              MyDateUtil.getLastMessageTime(
                                  context: context, time: _message!.sent),
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                ],
              ),
            ),
          );
        });
  }
}
