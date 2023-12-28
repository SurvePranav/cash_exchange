import 'dart:developer';

import 'package:cashxchange/main.dart';
import 'package:cashxchange/model/request_model.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/request_provider.dart';
import 'package:cashxchange/widgets/request_msg_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RequestStreamCard extends StatelessWidget {
  final String requestId;
  final String fromId;
  final bool myMessage;
  const RequestStreamCard(
      {super.key,
      required this.requestId,
      this.myMessage = false,
      required this.fromId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // custom msg type that is request send widget
      stream: Provider.of<RequestProvider>(context, listen: false)
          .getRequestById(context, requestId),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(top: 10),
              width: mq.width * 0.6,
              height: mq.height * 0.24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
            );
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasData && snapshot.data != null) {
              String status = '';
              RequestModel request;
              final data = snapshot.data;
              if (data != null) {
                request = RequestModel.fromJson(data.data()!);
                // getting status of request:
                if (request.confirmedTo.isNotEmpty) {
                  if (myMessage) {
                    if (request.confirmedTo.contains(UserModel.instance.uid)) {
                      status = 'Confirmed';
                    } else {
                      status = 'Confirmed To Other';
                    }
                  } else {
                    if (request.confirmedTo.contains(fromId)) {
                      status = 'Confirmed';
                    } else {
                      status = 'Confirmed To Other';
                    }
                  }
                } else {
                  int expiration =
                      (DateTime.fromMillisecondsSinceEpoch(request.createdAt)
                              .add(const Duration(hours: 24)))
                          .millisecondsSinceEpoch;
                  log('expiredAt: ${DateTime.now().millisecondsSinceEpoch}');
                  if (expiration > DateTime.now().millisecondsSinceEpoch) {
                    status = 'Not Confirmed';
                  } else {
                    status = 'Expired';
                  }
                }
              } else {
                request = RequestModel.fromJson({});
              }

              return RequestMsgCard(
                request: request,
                fromId: fromId,
                status: status,
                myMessage: myMessage,
              );
            } else {
              return const SizedBox(
                height: 20,
                width: 20,
              );
            }
        }
      },
    );
  }
}
