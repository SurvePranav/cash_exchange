import 'package:cached_network_image/cached_network_image.dart';
import 'package:cashxchange/main.dart';
import 'package:cashxchange/model/message_model.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/provider/messaging_provider.dart';
import 'package:cashxchange/screens/profile_module_screens/profile_pic_screen.dart';
import 'package:cashxchange/utils/date_util.dart';
import 'package:cashxchange/utils/util.dart';
import 'package:cashxchange/widgets/request_stream_for_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class MessageCard extends StatefulWidget {
  final Message message;
  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = UserModel.instance.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        _showBottomSheet(isMe);
      },
      onTap: () {
        if (widget.message.type == MsgType.image) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ImageFullScreen(
                url: widget.message.msg,
                heroTag: widget.message.sent,
              ),
            ),
          );
        }
      },
      child: isMe ? _greenMessage() : _blueMessage(),
    );
  }

  // sender/ another user message
  Widget _blueMessage() {
    //update last read message if sender and receiver are different
    String walkingDistance = "";
    if (widget.message.read.isEmpty) {
      Provider.of<MessagingProvider>(context, listen: false)
          .updateMessageReadStatus(widget.message);
      // updating the message as readed to remove the badge on chats
      Provider.of<AuthProvider>(context, listen: false).updateHasUnreadMessage(
        uid: widget.message.fromId,
        updateInMyConnections: true,
        hasUnreadMessage: false,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //message content
        Flexible(
          child: Container(
            padding: widget.message.type == MsgType.image
                ? EdgeInsets.only(
                    top: mq.width * .03,
                    left: mq.width * .03,
                    right: mq.width * .03,
                    bottom: mq.width * .01)
                : EdgeInsets.symmetric(
                    horizontal: mq.width * .03,
                    vertical: mq.width * .01,
                  ),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 221, 245, 255),
              border: Border.all(color: Colors.lightBlue),
              //making borders curved
              borderRadius: widget.message.type == MsgType.image
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    )
                  : const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.message.type == MsgType.text
                    ?
                    //show text
                    Text(
                        widget.message.msg,
                        style: const TextStyle(
                            fontSize: 15, color: Colors.black87),
                      )
                    : widget.message.type == MsgType.image
                        ? //show image
                        ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Hero(
                              tag: widget.message.sent,
                              child: CachedNetworkImage(
                                imageUrl: widget.message.msg,
                                placeholder: (context, url) => const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.image, size: 70),
                              ),
                            ),
                          )
                        : RequestStreamCard(
                            requestId: widget.message.msg,
                            fromId: widget.message.fromId,
                          ),
                const SizedBox(
                  height: 4,
                ),
                //sent time
                Text(
                  MyDateUtil.getFormattedTime(
                      context: context, time: widget.message.sent),
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: mq.width * 0.2,
        ),
      ],
    );
  }

  // our or user message
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //message time
        Row(
          children: [
            //for adding some space
            SizedBox(width: mq.width * .04),

            //double tick blue icon for message read
            widget.message.read.isNotEmpty
                ? const Icon(
                    Icons.done_all_rounded,
                    color: Colors.blue,
                    size: 20,
                  )
                : const Icon(
                    Icons.done,
                    color: Colors.grey,
                    size: 20,
                  ),

            //for adding some space
            const SizedBox(width: 2),
          ],
        ),

        //message content
        Flexible(
          child: Container(
            padding: widget.message.type == MsgType.image
                ? EdgeInsets.only(
                    top: mq.width * .03,
                    left: mq.width * .03,
                    right: mq.width * .03,
                    bottom: mq.width * .01)
                : EdgeInsets.symmetric(
                    horizontal: mq.width * .03,
                    vertical: mq.width * .01,
                  ),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 218, 255, 176),
              border: Border.all(color: Colors.lightGreen),
              //making borders curved
              borderRadius: widget.message.type == MsgType.image
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                    )
                  : const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                    ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                widget.message.type == MsgType.text
                    ?
                    //show text
                    Text(
                        widget.message.msg,
                        style: const TextStyle(
                            fontSize: 15, color: Colors.black87),
                      )
                    : widget.message.type == MsgType.image
                        ?
                        //show image
                        ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Hero(
                              tag: widget.message.sent,
                              child: CachedNetworkImage(
                                imageUrl: widget.message.msg,
                                placeholder: (context, url) => const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.image, size: 70),
                              ),
                            ),
                          )
                        // show request
                        : RequestStreamCard(
                            requestId: widget.message.msg,
                            myMessage: true,
                            fromId: widget.message.fromId,
                          ),

                const SizedBox(
                  height: 4,
                ),
                //sent time
                Text(
                  MyDateUtil.getFormattedTime(
                      context: context, time: widget.message.sent),
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // bottom sheet for modifying message details
  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          children: [
            //black divider
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(
                  vertical: mq.height * .015, horizontal: mq.width * .4),
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(8)),
            ),

            widget.message.type == MsgType.text
                ?
                //copy option
                _OptionItem(
                    icon: const Icon(Icons.copy_all_rounded,
                        color: Colors.blue, size: 26),
                    name: 'Copy Text',
                    onTap: () async {
                      await Clipboard.setData(
                              ClipboardData(text: widget.message.msg))
                          .then((value) {
                        //for hiding bottom sheet
                        Navigator.pop(context);

                        MyAppServices.showSnackBar(context, 'Text Copied!');
                      });
                    })
                : const SizedBox(),

            //delete option
            if (isMe && widget.message.type != MsgType.custom)
              _OptionItem(
                  icon: const Icon(Icons.delete_forever,
                      color: Colors.red, size: 26),
                  name: 'Delete Message',
                  onTap: () async {
                    //for hiding bottom sheet
                    Navigator.pop(context);
                    await Provider.of<MessagingProvider>(context, listen: false)
                        .deleteMessage(widget.message)
                        .then((value) {
                      MyAppServices.showSnackBar(context, 'Message deleted!');
                    });
                  }),

            //separator or divider
            Divider(
              color: Colors.black54,
              endIndent: mq.width * .04,
              indent: mq.width * .04,
            ),

            //sent time
            _OptionItem(
                icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                name:
                    'Sent At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
                onTap: () {}),

            //read time
            _OptionItem(
                icon: const Icon(Icons.remove_red_eye, color: Colors.green),
                name: widget.message.read.isEmpty
                    ? 'Read At: Not seen yet'
                    : 'Read At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
                onTap: () {}),
          ],
        );
      },
    );
  }
}

//custom options card (for copy, edit, delete, etc.)
class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: EdgeInsets.only(
              left: mq.width * .05,
              top: mq.height * .015,
              bottom: mq.height * .015),
          child: Row(children: [
            icon,
            Flexible(
                child: Text('    $name',
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        letterSpacing: 0.5)))
          ]),
        ));
  }
}
