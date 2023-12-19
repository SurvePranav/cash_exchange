import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cashxchange/main.dart';
import 'package:cashxchange/model/connection_model.dart';
import 'package:cashxchange/model/message_model.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/provider/messaging_provider.dart';
import 'package:cashxchange/provider/utility_provider.dart';
import 'package:cashxchange/screens/chat_module_screens/view_profile_screen.dart';
import 'package:cashxchange/widgets/message_card.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class MessageScreen extends StatefulWidget {
  final Connection connection;

  const MessageScreen({super.key, required this.connection});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  List<Message> _list = [];
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mp = Provider.of<MessagingProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        flexibleSpace: StreamBuilder(
          stream: Provider.of<AuthProvider>(context, listen: false)
              .getUserById(widget.connection.uid),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;

            final list =
                data?.map((e) => Connection.fromJson(e.data())).toList() ?? [];

            return SafeArea(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          ViewProfileScreen(connection: widget.connection),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.only(right: 16),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                          list.isNotEmpty
                              ? list.first.profilePic
                              : widget.connection.profilePic,
                        ),
                        maxRadius: 20,
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              list.isNotEmpty
                                  ? list.first.name
                                  : widget.connection.name,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            Text(
                              list.isNotEmpty
                                  ? list.first.isOnline
                                      ? 'Online'
                                      : 'Offline'
                                  : 'Not Specified',
                              style: list.isNotEmpty && list.first.isOnline
                                  ? TextStyle(
                                      color: Colors.green.shade600,
                                      fontSize: 13)
                                  : TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.phone,
                          color: Colors.black54,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: mp.getAllMessages(widget.connection),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  case ConnectionState.active:
                  case ConnectionState.done:
                    final data = snapshot.data?.docs;
                    _list =
                        data?.map((e) => Message.fromJson(e.data())).toList() ??
                            [];

                    if (_list.isNotEmpty) {
                      return ListView.builder(
                        itemCount: _list.length,
                        reverse: true,
                        padding: EdgeInsets.only(top: mq.height * 0.01),
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return MessageCard(message: _list[index]);
                        },
                      );
                    } else {
                      return Center(
                        child: MaterialButton(
                          onPressed: () {},
                          child: const Text(
                            "Say Hi!👋",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      );
                    }
                }
              },
            ),
          ),
          Consumer<UtilityProvider>(
            builder: (context, up, child) {
              if (up.isLoading) {
                return const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 20,
                    ),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                );
              } else {
                return const SizedBox();
              }
            },
          ),
          _chatInput(mp, context),
        ],
      ),
    );
  }

  Widget _chatInput(MessagingProvider mp, BuildContext context) {
    final up = Provider.of<UtilityProvider>(context, listen: false);
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * .025),
      child: Row(
        children: [
          //input field & buttons
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: TextField(
                    controller: _messageController,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        hintText: 'Type Something...',
                        hintStyle: TextStyle(color: Colors.blueAccent),
                        border: InputBorder.none),
                  )),

                  //pick image from gallery button
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Picking multiple images
                        await picker
                            .pickMultiImage(imageQuality: 70)
                            .then((images) async {
                          // uploading & sending image one by one
                          for (var i in images) {
                            log('Image Path: ${i.path}');
                            up.setLoading(true);
                            await mp.sendChatImage(
                                widget.connection, File(i.path), context);
                            up.setLoading(false);
                          }
                        });
                      },
                      icon: const Icon(Icons.image,
                          color: Colors.blueAccent, size: 26)),

                  //take image from camera button
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        await picker
                            .pickImage(
                                source: ImageSource.camera, imageQuality: 70)
                            .then((image) async {
                          if (image != null) {
                            up.setLoading(true);
                            await mp.sendChatImage(
                                widget.connection, File(image.path), context);
                            up.setLoading(false);
                          }
                        });
                      },
                      icon: const Icon(Icons.camera_alt_rounded,
                          color: Colors.blueAccent, size: 26)),

                  //adding some space
                  SizedBox(width: mq.width * .02),
                ],
              ),
            ),
          ),

          //send message button
          MaterialButton(
            onPressed: () async {
              final ap = Provider.of<AuthProvider>(context, listen: false);
              if (_messageController.text.trim().isNotEmpty) {
                if (_list.isEmpty) {
                  //on first message (add user to my_connections collection of receiver)
                  await ap
                      .checkIfUsersConnectedBefore(widget.connection.uid)
                      .then((areConnected) async {
                    if (!areConnected) {
                      await ap.addToMyConnection(user: widget.connection);
                      await ap.addToReceiversConnection(
                          user: widget.connection);
                    }
                  }).then((value) async {
                    await mp.sendMessage(
                      widget.connection,
                      _messageController.text.trim(),
                      MsgType.text,
                      context,
                    );
                  });
                } else {
                  //simply send message
                  await mp.sendMessage(
                    widget.connection,
                    _messageController.text.trim(),
                    MsgType.text,
                    context,
                  );
                }
                _messageController.text = '';
              }
            },
            minWidth: 0,
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: const CircleBorder(),
            color: Colors.green,
            child: const Icon(Icons.send, color: Colors.white, size: 28),
          )
        ],
      ),
    );
  }
}
