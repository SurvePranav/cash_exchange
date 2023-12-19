import 'dart:developer';

import 'package:cashxchange/model/connection_model.dart';
import 'package:cashxchange/model/message_model.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/provider/messaging_provider.dart';
import 'package:cashxchange/provider/request_provider.dart';
import 'package:cashxchange/utils/location_services.dart';
import 'package:cashxchange/utils/util.dart';
import 'package:cashxchange/widgets/constant_widget.dart';
import 'package:cashxchange/widgets/nearby_req_list.dart';
import 'package:cashxchange/widgets/nearby_request_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RequestsWidget extends StatefulWidget {
  final bool nearMe;
  const RequestsWidget({
    super.key,
    this.nearMe = true,
  });

  @override
  State<RequestsWidget> createState() => _RequestsWidgetState();
}

class _RequestsWidgetState extends State<RequestsWidget> {
  final List<Map<String, dynamic>> _outputData = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: widget.nearMe
          ? getRequests(context: context)
          : getRequests(context: context, nearHome: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MyConstantWidget();
        } else if (snapshot.connectionState == ConnectionState.done) {
          return NearbyRequestList(
              requests: _outputData,
              onTap: (Map<String, dynamic> request) async {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return NearbyRequestInfo(
                    request: request,
                    distance: request['distance']!,
                  );
                }));
              },
              onAccept: (Map<String, dynamic> request) async {
                final ap = Provider.of<AuthProvider>(context, listen: false);
                final mp =
                    Provider.of<MessagingProvider>(context, listen: false);
                final connection = Connection.fromJson(

                    // getting user information (who raised request)
                    await ap.getUserDataById(uid: request['uid']));

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
                }).then((value) async {
                  await mp
                      .sendMessage(connection, 'I accept your request',
                          MsgType.text, context)
                      .then((value) {
                    MyAppServices.showSlackBar(context, "request accepted");
                  });
                });
              });
        } else {
          return const Center(child: Text("Something Went wrong"));
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> getRequests({
    required BuildContext context,
    bool nearHome = false,
  }) async {
    final RequestProvider rp =
        Provider.of<RequestProvider>(context, listen: false);
    late final double lat, lng;
    if (nearHome) {
      lat = double.parse(UserModel.instance.locationLat);
      lng = double.parse(UserModel.instance.locationLon);
    } else {
      await LocationServices.getCurrentLocation().then((value) {
        lat = value[0];
        lng = value[1];
      });
    }
    await rp.getActiveRequests().then(
      (requests) async {
        _outputData.clear();
        for (int i = 0; i < requests.length; i++) {
          if (requests[i].uid != UserModel.instance.uid) {
            double distance = LocationServices.findDistanceBetweenCoordinates(
              lat,
              lng,
              requests[i].locationLat,
              requests[i].locationLon,
            );
            if (distance < 3000) {
              Map<String, dynamic> finalData = requests[i].toJson();
              finalData.addAll(
                  await Provider.of<AuthProvider>(context, listen: false)
                      .getUserDataById(uid: requests[i].uid));
              distance /= 1000;
              finalData['distance'] = distance.toStringAsFixed(2);
              _outputData.add(finalData);
            }
          }
        }
        return _outputData;
      },
    );
    return _outputData;
  }
}
