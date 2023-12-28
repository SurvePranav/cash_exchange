import 'dart:developer';
import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/model/connection_model.dart';
import 'package:cashxchange/model/message_model.dart';
import 'package:cashxchange/model/request_model.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/provider/messaging_provider.dart';
import 'package:cashxchange/provider/request_provider.dart';
import 'package:cashxchange/utils/location_services.dart';
import 'package:cashxchange/utils/notification_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AcceptRequestDialog extends StatefulWidget {
  final String title;
  final RequestModel request;
  const AcceptRequestDialog(
      {super.key, required this.title, required this.request});

  @override
  State<AcceptRequestDialog> createState() => _AcceptRequestDialogState();
}

class _AcceptRequestDialogState extends State<AcceptRequestDialog> {
  @override
  Widget build(BuildContext context) {
    return Consumer<RequestProvider>(
      builder: (context, requestProvider, child) {
        String msg = "";
        return AlertDialog(
          title: Text(widget.title),
          content: TextFormField(
            maxLines: null,
            onChanged: (value) => msg = value,
            decoration: InputDecoration(
                hintText: 'Message (optional)',
                prefixIcon: Icon(
                  Icons.message,
                  color: AppColors.deepGreen,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide:
                      BorderSide(color: AppColors.deepGreen, width: 1.5),
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15))),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (!requestProvider.isLoading) {
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.deepGreen),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!requestProvider.isLoading) {
                  try {
                    final ap =
                        Provider.of<AuthProvider>(context, listen: false);
                    final mp =
                        Provider.of<MessagingProvider>(context, listen: false);

                    requestProvider.setLoading(true);
                    final connection = Connection.fromJson(

                        // getting user information (who raised request)
                        await ap.getUserDataById(uid: widget.request.uid));

                    // check if the distance is minimum (near) between them
                    await LocationServices.getCurrentLocation()
                        .then((coordinates) async {
                      // calculate distance between them
                      final double distance =
                          LocationServices.findDistanceBetweenCoordinates(
                              double.parse(connection.locationLat),
                              double.parse(connection.locationLon),
                              coordinates[0],
                              coordinates[1]);
                      if (distance < 2000) {
                        // checking if the users are connected before
                        await ap
                            .checkIfUsersConnectedBefore(connection.uid)
                            .then((connectedBefore) async {
                          if (!connectedBefore) {
                            // if not connected connecting each other using my_users collection
                            log('not connected before');
                            await ap.addToMyConnection(user: connection);
                            await ap.addToReceiversConnection(user: connection);
                          } else if (connectedBefore &&
                              !UserModel.instance.connections
                                  .contains(connection.uid)) {
                            // if users are connected but not in primary then making connection primary
                            log('connected before but not in primary');
                            log('making primary');
                            await ap.updateConnectionPriority(
                                senderUid: connection.uid, primary: true);
                          }
                        }).then(
                          (value) async {
                            // adding user information to the request meta data
                            await requestProvider
                                .addUserToAcceptedRequest(
                              reqId: widget.request.reqId,
                              uid: UserModel.instance.uid,
                              msg: msg.trim(),
                              lat: coordinates[0],
                              lng: coordinates[1],
                            )
                                .then((value) {
                              // sending push notification and request accepted chat message
                              mp
                                  .sendMessage(connection, widget.request.reqId,
                                      MsgType.custom, context)
                                  .then((value) {
                                log('sending true value');
                                requestProvider.setLoading(false);

                                // sending in app notification
                                NotificationServics.sendInAppNotification(
                                    uid: connection.uid,
                                    title: 'Request Accepted',
                                    body:
                                        '${UserModel.instance.name} accepted your ${widget.request.type} request of Rs.${widget.request.amount}');
                                Navigator.of(context).pop(
                                    true); // Return true on accepted request
                              });
                            });
                          },
                        );
                      } else {
                        requestProvider.setLoading(false);
                        Navigator.of(context).pop(false);
                      }
                    });
                  } catch (e) {
                    log('could not accept request');
                    requestProvider.setLoading(false);
                    Navigator.of(context).pop(false);
                  }
                }
              },
              child: requestProvider.isLoading
                  ? const SizedBox(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Accept',
                      style: TextStyle(color: AppColors.deepGreen),
                    ),
            ),
          ],
        );
      },
    );
  }
}
