import 'package:cashxchange/main.dart';
import 'package:cashxchange/model/connection_model.dart';
import 'package:cashxchange/model/message_model.dart';
import 'package:cashxchange/model/request_model.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/provider/request_provider.dart';
import 'package:cashxchange/utils/notification_services.dart';
import 'package:cashxchange/utils/util.dart';
import 'package:cashxchange/widgets/request_meat_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RequestMsgCard extends StatelessWidget {
  final RequestModel request;
  final String fromId;
  final String status;
  final bool myMessage;
  const RequestMsgCard({
    super.key,
    required this.request,
    required this.fromId,
    required this.status,
    this.myMessage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: mq.width * 0.6,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: request.confirmedTo.isNotEmpty
            ? (request.confirmedTo.contains(fromId))
                ? Colors.green.withAlpha(100)
                : Colors.red.withAlpha(100)
            : Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('status: $status'),
          const Divider(
            color: Colors.blue,
          ),
          Text(
            'Want Rs.${request.amount} ${request.type}',
            style: const TextStyle(color: Colors.black),
          ),
          Text(
            'Accepted by ${request.acceptedBy.length} peoples',
          ),
          const Divider(
            color: Colors.blue,
          ),
          RequestMetaData(
            request: request,
            showDistance: !myMessage,
            fromId: fromId,
          ),
          Visibility(
            visible: (request.confirmedTo.isEmpty && !myMessage),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      // confirmation dialog
                      await MyAppServices.showConfirmationDialog(
                              context: context,
                              title: 'Confirm Request',
                              body: 'do you want to confirm your request?')
                          .then((value) {
                        if (value) {
                          // confirm request
                          Provider.of<RequestProvider>(context, listen: false)
                              .confirmRequest(reqId: request.reqId, uid: fromId)
                              .then((value) {
                            // making the connection primary if not
                            if (!UserModel.instance.connections
                                .contains(fromId)) {
                              Provider.of<AuthProvider>(context, listen: false)
                                  .updateConnectionPriority(
                                      senderUid: fromId, primary: true);
                            }
                            // notifiying the user about confirmation
                            Provider.of<AuthProvider>(context, listen: false)
                                .getUserDataById(uid: fromId)
                                .then((user) {
                              NotificationServics.sendPushNotification(
                                  Connection.fromJson(user),
                                  '${UserModel.instance.name} has confirmed his request to you',
                                  MsgType.custom,
                                  title: 'Request Confirmed');

                              NotificationServics.sendInAppNotification(
                                uid: fromId,
                                title: 'Request Confirmed',
                                body:
                                    '${UserModel.instance.name} has confirmed his request to you',
                              );
                            });
                          });
                        }
                      });
                    },
                    style: ButtonStyle(
                      side: MaterialStateProperty.all<BorderSide>(
                        const BorderSide(color: Colors.green, width: 1.0),
                      ),
                    ),
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: (request.confirmedTo.contains(fromId)),
            child: TextButton(
              onPressed: () async {
                var data =
                    await Provider.of<RequestProvider>(context, listen: false)
                        .getRequestMetaData(reqId: request.reqId, uid: fromId);
                final snap = data.data();
                MyAppServices.launchAnyUrl(
                  'https://www.google.com/maps/search/?api=1&query=${snap!['lat']},${snap['lng']}',
                );
              },
              style: ButtonStyle(
                  side: MaterialStateProperty.all<BorderSide>(
                    const BorderSide(color: Colors.blue, width: 1.0),
                  ),
                  foregroundColor:
                      const MaterialStatePropertyAll<Color>(Colors.blue)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
  }
}
