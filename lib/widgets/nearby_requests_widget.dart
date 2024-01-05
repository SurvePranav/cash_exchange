import 'dart:async';
import 'dart:developer';

import 'package:cashxchange/model/connection_model.dart';
import 'package:cashxchange/model/request_model.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/request_provider.dart';
import 'package:cashxchange/provider/utility_provider.dart';
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
  final VoidCallback onNoRequests;
  const RequestsWidget({
    super.key,
    this.nearby = true,
    required this.onNoRequests,
  });

  @override
  State<RequestsWidget> createState() => _RequestsWidgetState();
}

class _RequestsWidgetState extends State<RequestsWidget> {
  @override
  void initState() {
    final counterProvider =
        Provider.of<UtilityProvider>(context, listen: false);
    Timer.periodic(const Duration(minutes: 1), (timer) {
      counterProvider.incrementClockCounter();
    });
    super.initState();
  }

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
        future: LocationServices.getCurrentLocation(context),
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

            // fetching all active requests
            requests =
                data?.map((e) => RequestModel.fromJson(e.data())).toList() ??
                    [];

            // removing requests on basis of some criterias
            requests.removeWhere((request) {
              if (request.uid != UserModel.instance.uid) {
                double distance =
                    LocationServices.findDistanceBetweenCoordinates(
                  lat,
                  lng,
                  request.locationLat,
                  request.locationLon,
                );

                // removing requests whose distance is more than 2KM away from user's current location
                // Return true if the distance is less than 2000, indicating it should be removed
                return distance > 2000;
              }
              // removing request which are user's own active requests
              // Return false if the uid matches, indicating it should not be removed
              return true;
            });

            // sorting requests on the basis of request createing date
            requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
                    // on accepting request
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
                }
              });
            },
            myLat: lat,
            myLng: lng,
            onNoRequests: widget.onNoRequests,
          );
        } else {
          return const MyConstantWidget();
        }
      },
    );
  }
}
