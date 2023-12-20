import 'dart:developer';

import 'package:cashxchange/model/connection_model.dart';
import 'package:cashxchange/model/message_model.dart';
import 'package:cashxchange/model/request_model.dart';
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
  final bool nearby;
  const RequestsWidget({
    super.key,
    this.nearby = true,
  });

  @override
  State<RequestsWidget> createState() => _RequestsWidgetState();
}

class _RequestsWidgetState extends State<RequestsWidget> {
  @override
  Widget build(BuildContext context) {
    if (!widget.nearby) {
      log('near home ');
      return _buildList(
        double.parse(UserModel.instance.locationLat),
        double.parse(UserModel.instance.locationLon),
      );
    } else {
      return FutureBuilder(
        future: LocationServices.getCurrentLocation(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              return const MyConstantWidget();
            case ConnectionState.done:
              double lat = 0;
              double lng = 0;
              if (snapshot.data != null) {
                lat = snapshot.data![0];
                lng = snapshot.data![1];
              }
              return _buildList(lat, lng);
          }
        },
      );
    }
  }

  Widget _buildList(double lat, double lng) {
    return StreamBuilder(
      stream: Provider.of<RequestProvider>(context, listen: false)
          .getActiveRequestsAsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState
            case ConnectionState.none || ConnectionState.waiting) {
          log('waiting...');
          return const MyConstantWidget();
        } else if (snapshot.connectionState
            case ConnectionState.active || ConnectionState.done) {
          List<RequestModel> requests = [];
          if (snapshot.hasData) {
            final data = snapshot.data?.docs;

            // fetching all active requests
            requests =
                data?.map((e) => RequestModel.fromJson(e.data())).toList() ??
                    [];
            log('total requests: ${requests.length}');
            for (int i = 0; i < requests.length; i++) {
              // removing my active requests
              // if (requests[i].uid == UserModel.instance.uid) {
              //   log('removing request: ${requests[i].reqId}');
              //   requests.remove(requests[i]);
              // }

              // calculating distance between user and request
              double distance = LocationServices.findDistanceBetweenCoordinates(
                lat,
                lng,
                requests[i].locationLat,
                requests[i].locationLon,
              );
              log('My lat: $lat');
              log('My lng: $lng');
              log('Request lat: ${requests[i].locationLat}');
              log('Request lng: ${requests[i].locationLon}');
              log('distance: $distance');
              // removing active requests based on distance
              if (distance > 3000) {
                log('removing request: ${requests[i].reqId}');
                requests.remove(requests[i]);
              }
            }
          }
          return NearbyRequestList(
            requests: requests,
            onTap: (RequestModel request, Connection connection,
                String distance) async {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return NearbyRequestInfo(
                  request: request,
                  connection: connection,
                  distance: distance,
                );
              }));
            },
            onAccept: (RequestModel request) async {
              final ap = Provider.of<AuthProvider>(context, listen: false);
              final mp = Provider.of<MessagingProvider>(context, listen: false);
              final connection = Connection.fromJson(

                  // getting user information (who raised request)
                  await ap.getUserDataById(uid: request.uid));

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
                    !UserModel.instance.connections.contains(connection.uid)) {
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
            },
            myLat: lat,
            myLng: lng,
          );
        } else {
          return const MyConstantWidget();
        }
      },
    );
  }

  // Future<List<Map<String, dynamic>>> getRequests({
  //   required BuildContext context,
  //   bool nearHome = false,
  // }) async {
  //   final RequestProvider rp =
  //       Provider.of<RequestProvider>(context, listen: false);
  //   late final double lat, lng;
  //   if (nearHome) {
  //     lat = double.parse(UserModel.instance.locationLat);
  //     lng = double.parse(UserModel.instance.locationLon);
  //   } else {
  //     await LocationServices.getCurrentLocation().then((value) {
  //       lat = value[0];
  //       lng = value[1];
  //     });
  //   }
  //   await rp.getActiveRequests().then(
  //     (requests) async {
  //       _outputData.clear();
  //       for (int i = 0; i < requests.length; i++) {
  //         if (requests[i].uid != UserModel.instance.uid) {
  //           double distance = LocationServices.findDistanceBetweenCoordinates(
  //             lat,
  //             lng,
  //             requests[i].locationLat,
  //             requests[i].locationLon,
  //           );
  //           if (distance < 3000) {
  //             Map<String, dynamic> finalData = requests[i].toJson();
  //             finalData.addAll(
  //                 await Provider.of<AuthProvider>(context, listen: false)
  //                     .getUserDataById(uid: requests[i].uid));
  //             distance /= 1000;
  //             finalData['distance'] = distance.toStringAsFixed(2);
  //             _outputData.add(finalData);
  //           }
  //         }
  //       }
  //       return _outputData;
  //     },
  //   );
  //   return _outputData;
  // }

  // Stream<QuerySnapshot<Map<String, dynamic>>> getRequestsStream({
  //   required BuildContext context,
  //   required double lat,
  //   required double lng,
  //   bool nearHome = false,
  // })  {
  //   await rp.getActiveRequests().then(
  //     (requests) async {
  //       _outputData.clear();
  //       for (int i = 0; i < requests.length; i++) {
  //         if (requests[i].uid != UserModel.instance.uid) {
  //           double distance = LocationServices.findDistanceBetweenCoordinates(
  //             lat,
  //             lng,
  //             requests[i].locationLat,
  //             requests[i].locationLon,
  //           );
  //           if (distance < 3000) {
  //             Map<String, dynamic> finalData = requests[i].toJson();
  //             finalData.addAll(
  //                 await Provider.of<AuthProvider>(context, listen: false)
  //                     .getUserDataById(uid: requests[i].uid));
  //             distance /= 1000;
  //             finalData['distance'] = distance.toStringAsFixed(2);
  //             _outputData.add(finalData);
  //           }
  //         }
  //       }
  //       return _outputData;
  //     },
  //   );
  //   return _outputData;
  // }
}
