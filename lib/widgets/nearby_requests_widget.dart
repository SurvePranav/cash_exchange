import 'dart:developer';

import 'package:cashxchange/model/connection_model.dart';
import 'package:cashxchange/model/request_model.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/request_provider.dart';
import 'package:cashxchange/utils/location_services.dart';
import 'package:cashxchange/utils/util.dart';
import 'package:cashxchange/widgets/constant_widget.dart';
import 'package:cashxchange/widgets/dialogs/accept_request_dialog.dart';
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
            case ConnectionState.done || ConnectionState.active) {
          List<RequestModel> requests = [];
          if (snapshot.hasData) {
            final data = snapshot.data?.docs;

            //    fetching all active requests
            var tempRequests =
                data?.map((e) => RequestModel.fromJson(e.data())).toList() ??
                    [];
            tempRequests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            log('total requests: ${tempRequests.length}');
            for (int i = 0; i < tempRequests.length; i++) {
              //  calculating distance between user and request
              double distance = LocationServices.findDistanceBetweenCoordinates(
                lat,
                lng,
                tempRequests[i].locationLat,
                tempRequests[i].locationLon,
              );
              log('My lat: $lat');
              log('My lng: $lng');
              log('Request lat: ${tempRequests[i].locationLat}');
              log('Request lng: ${tempRequests[i].locationLon}');
              log('distance: $distance');
              // removing active requests based on distance
              if (tempRequests[i].uid != UserModel.instance.uid &&
                  distance < 2000) {
                requests.add(tempRequests[i]);
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
              await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return AcceptRequestDialog(
                      title: "${request.type} : ${request.amount}",
                      request: request);
                },
              ).then((value) {
                if (value != null) {
                  if (value) {
                    // on not accepting request
                    MyAppServices.showSnackBar(
                      context,
                      'Request Accepted Successfully',
                    );
                  } else {
                    // on error
                    MyAppServices.showSnackBar(
                      context,
                      'Could Not Accept Request',
                      bgColor: Colors.red,
                    );
                  }
                } else {
                  // making loading false if it is loading
                  if (Provider.of<RequestProvider>(context, listen: false)
                      .isLoading) {
                    Provider.of<RequestProvider>(context, listen: false)
                        .setLoading(false);
                  }
                  ;
                }
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
}
