import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/location_provider.dart';
import 'package:cashxchange/provider/request_provider.dart';
import 'package:cashxchange/widgets/nearby_req_list.dart';
import 'package:cashxchange/widgets/nearby_request_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NearbyRequestsWidget extends StatefulWidget {
  final bool nearHome;
  final bool nearMe;
  final bool showAtms;
  const NearbyRequestsWidget({
    super.key,
    this.nearHome = false,
    this.nearMe = true,
    this.showAtms = false,
  });

  @override
  State<NearbyRequestsWidget> createState() => _NearbyRequestsWidgetState();
}

class _NearbyRequestsWidgetState extends State<NearbyRequestsWidget> {
  final List<Map<String, dynamic>> _outputData = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: widget.nearMe
          ? getNearbyRequests(context: context)
          : widget.nearHome
              ? getRequestsNearHome(context: context)
              : getNearbyRequests(context: context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverList(
            delegate: SliverChildListDelegate.fixed(
              [
                Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    height: MediaQuery.of(context).size.height * 0.35,
                    child: const Center(child: CircularProgressIndicator())),
              ],
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          return NearbyRequestList(
            requests: _outputData,
            onTap: (Map<String, dynamic> request) async {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return NearbyRequestInfo(
                  request: request,
                  distance: request['distance']!,
                );
              }));
            },
          );
        } else {
          return const Center(child: Text("Something Went wrong"));
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> getNearbyRequests(
      {required BuildContext context}) async {
    print("i was called : nearbyRequests");
    final LocationProvider lp =
        Provider.of<LocationProvider>(context, listen: false);
    await lp.getCurrentLocation().then(
      (currentLocation) async {
        await Provider.of<RequestProvider>(context, listen: false)
            .getActiveRequests(context)
            .then(
          (requests) async {
            _outputData.clear();
            for (int i = 0; i < requests.length; i++) {
              print("request: ${requests[i]}");
              double distance = lp.findDistanceBetweenCoordinates(
                currentLocation[0],
                currentLocation[1],
                requests[i]['locationLat'],
                requests[i]['locationLon'],
              );
              if (distance < 3000) {
                distance /= 1000;
                requests[i]['distance'] = distance.toStringAsFixed(2);
                _outputData.add(requests[i]);
              }
            }
            return _outputData;
          },
        );
      },
    );
    return _outputData;
  }

  Future<List<Map<String, dynamic>>> getRequestsNearHome(
      {required BuildContext context}) async {
    final LocationProvider lp =
        Provider.of<LocationProvider>(context, listen: false);
    await Provider.of<RequestProvider>(context, listen: false)
        .getActiveRequests(context)
        .then(
      (requests) async {
        _outputData.clear();
        for (int i = 0; i < requests.length; i++) {
          double distance = lp.findDistanceBetweenCoordinates(
            double.parse(UserModel.instance.locationLat),
            double.parse(UserModel.instance.locationLon),
            requests[i]['locationLat'],
            requests[i]['locationLon'],
          );
          if (distance < 3000) {
            distance /= 1000;
            requests[i]['distance'] = distance.toStringAsFixed(2);
            _outputData.add(requests[i]);
          }
        }
        return _outputData;
      },
    );
    return _outputData;
  }
}
