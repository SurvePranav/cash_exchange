import 'package:cached_network_image/cached_network_image.dart';
import 'package:cashxchange/main.dart';
import 'package:cashxchange/model/connection_model.dart';
import 'package:cashxchange/model/message_model.dart';
import 'package:cashxchange/model/request_model.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/provider/messaging_provider.dart';
import 'package:cashxchange/provider/request_provider.dart';
import 'package:cashxchange/screens/profile_module_screens/profile_pic_screen.dart';
import 'package:cashxchange/utils/date_util.dart';
import 'package:cashxchange/utils/location_services.dart';
import 'package:cashxchange/utils/notification_services.dart';
import 'package:cashxchange/utils/util.dart';
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
    if (widget.message.read.isEmpty) {
      Provider.of<MessagingProvider>(context, listen: false)
          .updateMessageReadStatus(widget.message);
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
                        : StreamBuilder(
                            // custom msg type that is request send widget
                            stream: Provider.of<RequestProvider>(context,
                                    listen: false)
                                .getRequestById(context, widget.message.msg),
                            builder: (context, snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.none:
                                case ConnectionState.waiting:
                                  return const CircularProgressIndicator();
                                case ConnectionState.active:
                                case ConnectionState.done:
                                  if (snapshot.hasData &&
                                      snapshot.data != null) {
                                    String status = '';
                                    RequestModel request;
                                    final data = snapshot.data;
                                    if (data != null) {
                                      request =
                                          RequestModel.fromJson(data.data()!);
                                      // getting status of request:
                                      if (request.confirmedTo.isNotEmpty) {
                                        if (request.confirmedTo
                                            .contains(widget.message.fromId)) {
                                          status = 'Confirmed';
                                        } else {
                                          status = 'Confirmed To Other';
                                        }
                                      } else {
                                        status = 'Not Confirmed';
                                      }
                                    } else {
                                      request = RequestModel.fromJson({});
                                    }

                                    return Container(
                                      padding: const EdgeInsets.all(20),
                                      width: mq.width * 0.6,
                                      margin: const EdgeInsets.only(top: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: request.confirmedTo.isNotEmpty
                                            ? request.confirmedTo.contains(
                                                    widget.message.fromId)
                                                ? Colors.green.withAlpha(100)
                                                : Colors.red.withAlpha(100)
                                            : Colors.white,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('status: $status'),
                                          const Divider(
                                            color: Colors.blue,
                                          ),
                                          Text(
                                            'Want Rs.${request.amount} ${request.type}',
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                          Text(
                                            'Accepted by ${request.acceptedBy.length} peoples',
                                          ),
                                          const Divider(
                                            color: Colors.blue,
                                          ),
                                          FutureBuilder(
                                            future:
                                                Provider.of<RequestProvider>(
                                                        context,
                                                        listen: false)
                                                    .getRequestMetaData(
                                                        reqId: request.reqId,
                                                        uid: widget
                                                            .message.fromId),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                      ConnectionState.done &&
                                                  snapshot.hasData) {
                                                final data =
                                                    snapshot.data?.data() ?? {};
                                                String msg =
                                                    'I accept your request';
                                                if (data['msg']
                                                    .toString()
                                                    .isNotEmpty) {
                                                  msg = data['msg'];
                                                }
                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        'At: ${MyDateUtil.getTimeStamp(
                                                      context: context,
                                                      time: data['date']
                                                          .toString(),
                                                    )}'),
                                                    Text(msg),
                                                    FutureBuilder(
                                                      future: LocationServices
                                                          .calculateWalkingDistance(
                                                              originLat: request
                                                                  .locationLat,
                                                              originLng: request
                                                                  .locationLon,
                                                              destinationLat:
                                                                  data['lat'],
                                                              destinationLng:
                                                                  data['lng']),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot.connectionState ==
                                                                ConnectionState
                                                                    .done &&
                                                            snapshot.hasData) {
                                                          return Text(
                                                              'Walking Distance: ${(snapshot.data!['distance_value'] / 1000).toStringAsFixed(2)} KM');
                                                        } else {
                                                          return const Text(
                                                              'WalkingDistance: --');
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                );
                                              } else {
                                                return const Text('');
                                              }
                                            },
                                          ),
                                          Visibility(
                                            visible:
                                                request.confirmedTo.isEmpty,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: TextButton(
                                                    onPressed: () async {
                                                      // confirmation dialog
                                                      await MyAppServices
                                                              .showConfirmationDialog(
                                                                  context:
                                                                      context,
                                                                  title:
                                                                      'Confirm Request',
                                                                  body:
                                                                      'do you want to confirm your request?')
                                                          .then((value) {
                                                        if (value) {
                                                          // confirm request
                                                          Provider.of<RequestProvider>(
                                                                  context,
                                                                  listen: false)
                                                              .confirmRequest(
                                                                  reqId: request
                                                                      .reqId,
                                                                  uid: widget
                                                                      .message
                                                                      .fromId)
                                                              .then((value) {
                                                            // making the connection primary if not
                                                            if (!UserModel
                                                                .instance
                                                                .connections
                                                                .contains(widget
                                                                    .message
                                                                    .fromId)) {
                                                              Provider.of<AuthProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .updateConnectionPriority(
                                                                      senderUid: widget
                                                                          .message
                                                                          .fromId,
                                                                      primary:
                                                                          true);
                                                            }
                                                            // notifiying the user about confirmation
                                                            Provider.of<AuthProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .getUserDataById(
                                                                    uid: widget
                                                                        .message
                                                                        .fromId)
                                                                .then((user) {
                                                              NotificationServics.sendPushNotification(
                                                                  Connection
                                                                      .fromJson(
                                                                          user),
                                                                  '${UserModel.instance.name} has confirmed his request to you',
                                                                  MsgType
                                                                      .custom,
                                                                  title:
                                                                      'Request Confirmed');
                                                              NotificationServics
                                                                  .sendInAppNotification(
                                                                uid: widget
                                                                    .message
                                                                    .fromId,
                                                                title:
                                                                    'Request Confirmed',
                                                                body:
                                                                    '${UserModel.instance.name} has confirmed his request to you',
                                                              );
                                                            });
                                                          });
                                                        }
                                                      });
                                                    },
                                                    style: ButtonStyle(
                                                      side:
                                                          MaterialStateProperty
                                                              .all<BorderSide>(
                                                        const BorderSide(
                                                            color: Colors.green,
                                                            width: 1.0),
                                                      ),
                                                    ),
                                                    child:
                                                        const Text('Confirm'),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Visibility(
                                            visible: request.confirmedTo
                                                .contains(
                                                    widget.message.fromId),
                                            child: TextButton(
                                              onPressed: () async {
                                                var data = await Provider.of<
                                                            RequestProvider>(
                                                        context,
                                                        listen: false)
                                                    .getRequestMetaData(
                                                        reqId: request.reqId,
                                                        uid: widget
                                                            .message.fromId);
                                                final snap = data.data();
                                                MyAppServices.launchAnyUrl(
                                                  'https://www.google.com/maps/search/?api=1&query=${snap!['lat']},${snap['lng']}',
                                                );
                                              },
                                              style: ButtonStyle(
                                                  side: MaterialStateProperty
                                                      .all<BorderSide>(
                                                    const BorderSide(
                                                        color: Colors.blue,
                                                        width: 1.0),
                                                  ),
                                                  foregroundColor:
                                                      const MaterialStatePropertyAll<
                                                          Color>(Colors.blue)),
                                              child: const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text('Directions'),
                                                  SizedBox(
                                                    width: 4,
                                                  ),
                                                  Icon(
                                                    Icons.directions,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return const SizedBox(
                                      height: 20,
                                      width: 20,
                                    );
                                  }
                              }
                            },
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
                        :
                        // show request
                        StreamBuilder(
                            // custom msg type that is request send widget
                            stream: Provider.of<RequestProvider>(context,
                                    listen: false)
                                .getRequestById(context, widget.message.msg),
                            builder: (context, snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.none:
                                case ConnectionState.waiting:
                                  return const CircularProgressIndicator();
                                case ConnectionState.active:
                                case ConnectionState.done:
                                  if (snapshot.hasData &&
                                      snapshot.data != null) {
                                    String status = '';
                                    RequestModel request;
                                    final data = snapshot.data;
                                    if (data != null) {
                                      request =
                                          RequestModel.fromJson(data.data()!);
                                      // getting status of request:
                                      if (request.confirmedTo.isNotEmpty) {
                                        if (request.confirmedTo
                                            .contains(UserModel.instance.uid)) {
                                          status = 'Confirmed';
                                        } else {
                                          status = 'Confirmed To Other';
                                        }
                                      } else {
                                        status = 'Not Confirmed';
                                      }
                                    } else {
                                      request = RequestModel.fromJson({});
                                    }

                                    return Container(
                                      padding: const EdgeInsets.all(20),
                                      margin: const EdgeInsets.only(top: 10),
                                      width: mq.width * 0.6,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: request.confirmedTo.isNotEmpty
                                            ? request.confirmedTo.contains(
                                                    UserModel.instance.uid)
                                                ? Colors.green.withAlpha(100)
                                                : Colors.red.withAlpha(100)
                                            : Colors.white,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('status: $status'),
                                          const Divider(
                                            color: Colors.blue,
                                          ),
                                          Text(
                                            'Want Rs.${request.amount} ${request.type}',
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                          Text(
                                            'Accepted by ${request.acceptedBy.length} peoples',
                                          ),
                                          const Divider(
                                            color: Colors.blue,
                                          ),
                                          FutureBuilder(
                                            future:
                                                Provider.of<RequestProvider>(
                                                        context,
                                                        listen: false)
                                                    .getRequestMetaData(
                                                        reqId: request.reqId,
                                                        uid: UserModel
                                                            .instance.uid),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                      ConnectionState.done &&
                                                  snapshot.hasData) {
                                                final data =
                                                    snapshot.data?.data() ?? {};
                                                String msg =
                                                    'I accept your request';
                                                if (data['msg']
                                                    .toString()
                                                    .isNotEmpty) {
                                                  msg = data['msg'];
                                                }
                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        MyDateUtil.getTimeStamp(
                                                      context: context,
                                                      time: data['date']
                                                          .toString(),
                                                    )),
                                                    const SizedBox(
                                                      height: 3,
                                                    ),
                                                    Text(msg),
                                                  ],
                                                );
                                              } else {
                                                return const Text('');
                                              }
                                            },
                                          ),
                                          Visibility(
                                            visible: request.confirmedTo
                                                .contains(
                                                    UserModel.instance.uid),
                                            child: TextButton(
                                              onPressed: () {
                                                MyAppServices.launchAnyUrl(
                                                  'https://www.google.com/maps/search/?api=1&query=${request.locationLat},${request.locationLon}',
                                                );
                                              },
                                              style: ButtonStyle(
                                                  side: MaterialStateProperty
                                                      .all<BorderSide>(
                                                    const BorderSide(
                                                        color: Colors.blue,
                                                        width: 1.0),
                                                  ),
                                                  foregroundColor:
                                                      const MaterialStatePropertyAll<
                                                          Color>(Colors.blue)),
                                              child: const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text('Directions'),
                                                  SizedBox(
                                                    width: 4,
                                                  ),
                                                  Icon(
                                                    Icons.directions,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return const SizedBox(
                                      height: 20,
                                      width: 20,
                                    );
                                  }
                              }
                            },
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
