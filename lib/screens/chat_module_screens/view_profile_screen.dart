import 'package:cached_network_image/cached_network_image.dart';
import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/main.dart';
import 'package:cashxchange/model/connection_model.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/utils/date_util.dart';
import 'package:cashxchange/utils/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//view profile screen -- to view profile of user
class ViewProfileScreen extends StatefulWidget {
  final Connection connection;

  const ViewProfileScreen({super.key, required this.connection});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          //app bar
          appBar: AppBar(title: Text(widget.connection.name)),
          floatingActionButton: //user about
              Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Joined On: ',
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 15),
              ),
              Text(
                  MyDateUtil.getLastMessageTime(
                      context: context,
                      time: widget.connection.createdAt,
                      showYear: true),
                  style: const TextStyle(color: Colors.black54, fontSize: 15)),
            ],
          ),

          //body
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // for adding some space
                  SizedBox(width: mq.width, height: mq.height * .03),

                  //user profile picture
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .1),
                    child: CachedNetworkImage(
                      width: mq.height * .2,
                      height: mq.height * .2,
                      fit: BoxFit.cover,
                      imageUrl: widget.connection.profilePic,
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),

                  // for adding some space
                  SizedBox(height: mq.height * .03),

                  // user email label
                  Text(widget.connection.email,
                      style:
                          const TextStyle(color: Colors.black87, fontSize: 16)),

                  // for adding some space
                  SizedBox(height: mq.height * .02),

                  //user about
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'About: ',
                        style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 15),
                      ),
                      Text(widget.connection.bio,
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 15)),
                    ],
                  ),

                  const SizedBox(
                    height: 40,
                  ),
                  // block and move to primary buttons

                  StreamBuilder(
                    stream: Provider.of<AuthProvider>(context, listen: false)
                        .getConnectionInfo(userId: widget.connection.uid),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                          return const SizedBox();
                        case ConnectionState.active:
                        case ConnectionState.done:
                          if (snapshot.hasData && snapshot.data != null) {
                            Map<String, dynamic>? doc = {};
                            bool isPrimary = false;
                            var snap = snapshot.data?.docs;
                            if (snap != null && snap.isNotEmpty) {
                              doc = snap.first.data();
                              isPrimary = doc['primary'];
                            }

                            return Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      await MyAppServices
                                          .showConfirmationDialog(
                                        context: context,
                                        title: 'Remove Connection',
                                        body:
                                            'Are you sure you want to remove connection?',
                                      ).then((confirm) {
                                        if (confirm) {
                                          Provider.of<AuthProvider>(context,
                                                  listen: false)
                                              .removeConnection(
                                                  connection:
                                                      widget.connection);
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                        }
                                      });
                                    },
                                    child: Text(
                                      'Remove',
                                      style:
                                          TextStyle(color: AppColors.deepGreen),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      if (doc != null) {
                                        Provider.of<AuthProvider>(context,
                                                listen: false)
                                            .updateConnectionPriority(
                                                senderUid:
                                                    widget.connection.uid,
                                                primary: !doc['primary']);
                                      }
                                    },
                                    child: Text(
                                      isPrimary
                                          ? 'Make Secondary'
                                          : 'Make Primary',
                                      style:
                                          TextStyle(color: AppColors.deepGreen),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return const SizedBox();
                          }
                      }
                    },
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
