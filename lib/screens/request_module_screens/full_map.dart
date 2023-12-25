import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/model/request_model.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/request_provider.dart';
import 'package:cashxchange/utils/location_services.dart';
import 'package:cashxchange/utils/util.dart';
import 'package:cashxchange/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class FullMapScreen extends StatefulWidget {
  const FullMapScreen({super.key});

  @override
  State<FullMapScreen> createState() => _FullMapScreenState();
}

class _FullMapScreenState extends State<FullMapScreen> {
  final List<RequestModel> _requests = [];
  final List<Map<String, dynamic>> _nearbyAtms = [];
  bool _showNearbyRequests = true;
  List<double> myLocation = [0, 0];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
        ),
        title: Text(
          _showNearbyRequests ? "Nearby Requests" : "Nearby ATM's",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.deepGreen,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            FutureBuilder<CameraPosition>(
              future: initiateMap(showNearbyRequests: _showNearbyRequests),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return GoogleMap(
                      initialCameraPosition: snapshot.data!,
                      mapType: MapType.normal,
                      onMapCreated: (controller) {
                        // _mapController = controller;
                      },
                      myLocationEnabled: true,
                      markers: _showNearbyRequests
                          ? _requests.map((request) {
                              return Marker(
                                markerId: MarkerId(request.reqId),
                                position: LatLng(
                                  request.locationLat,
                                  request.locationLon,
                                ),
                                infoWindow: InfoWindow(
                                  title:
                                      'Want ${request.type} Rs.${request.amount}',
                                  snippet: request.info,
                                ),
                              );
                            }).toSet()
                          : _nearbyAtms.map((e) {
                              return Marker(
                                onTap: () {},
                                markerId: MarkerId(e['id']),
                                position: LatLng(
                                  e['lat'],
                                  e['lng'],
                                ),
                                infoWindow: InfoWindow(
                                  title: '${e['name']}',
                                  snippet: 'Rating : ${e['rating']}',
                                ),
                              );
                            }).toSet());
                } else {
                  return Center(
                    child: LinearProgressIndicator(color: AppColors.deepGreen),
                  );
                }
              },
            ),
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                // color: Colors.green,
                height: 50,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: CustomButton(
                        onPressed: () {
                          setState(() {
                            _showNearbyRequests = false;
                          });
                        },
                        text: '',
                        color: _showNearbyRequests
                            ? Colors.white
                            : AppColors.deepGreen,
                        child: Column(children: [
                          Icon(
                            Icons.atm,
                            color: _showNearbyRequests
                                ? AppColors.deepGreen
                                : Colors.white,
                          ),
                          Text(
                            "Nearby Atm's",
                            style: TextStyle(
                              fontSize: 8,
                              color: _showNearbyRequests
                                  ? AppColors.deepGreen
                                  : Colors.white,
                            ),
                          )
                        ]),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: CustomButton(
                        onPressed: () {
                          setState(() {
                            _showNearbyRequests = true;
                          });
                        },
                        text: '',
                        color: _showNearbyRequests
                            ? AppColors.deepGreen
                            : Colors.white,
                        child: Column(children: [
                          Icon(
                            Icons.person,
                            color: _showNearbyRequests
                                ? Colors.white
                                : AppColors.deepGreen,
                          ),
                          Text(
                            "Nearby Requests",
                            style: TextStyle(
                              fontSize: 8,
                              color: _showNearbyRequests
                                  ? Colors.white
                                  : AppColors.deepGreen,
                            ),
                          )
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // initiates map with current position and loads other markers
  Future<CameraPosition> initiateMap({required bool showNearbyRequests}) async {
    RequestProvider rp = Provider.of<RequestProvider>(context, listen: false);
    CameraPosition cameraPosition = const CameraPosition(target: LatLng(0, 0));

    await LocationServices.getCurrentLocation().then(
      (location) async {
        cameraPosition = CameraPosition(
          target: LatLng(location[0], location[1]),
          zoom: 15,
        );
        myLocation = location;

        // loading markers for nearby requests
        if (showNearbyRequests) {
          await rp.getActiveRequests().then((requests) {
            _requests.clear();
            for (int i = 0; i < requests.length; i++) {
              double distance = LocationServices.findDistanceBetweenCoordinates(
                location[0],
                location[1],
                requests[i].locationLat,
                requests[i].locationLon,
              );
              if (UserModel.instance.uid != requests[i].uid &&
                  requests[i].confirmedTo.isEmpty &&
                  distance < 2000) {
                _requests.add(requests[i]);
              }
            }
            if (_requests.isEmpty) {
              MyAppServices.showSnackBar(context, "No Nearby Requests");
            }
          });
        }
        // loading markers for nearby atms
        else {
          await LocationServices.getNearbyPlaces(
                  lat: location[0], lng: location[1], place: "atm")
              .then((results) {
            _nearbyAtms.clear();
            for (Map i in results) {
              _nearbyAtms.add(
                {
                  'id': i.toString(),
                  'currentLat': location[0].toString(),
                  'currentLng': location[1].toString(),
                  'lat': i['geometry']['location']['lat'],
                  'lng': i['geometry']['location']['lng'],
                  'name': i['name'],
                  'rating': i.containsKey('rating') ? i['rating'] : '--',
                  'place_id': i['place_id'],
                  'photo_reference': i.containsKey('photos')
                      ? i['photos'][0]['photo_reference']
                      : null,
                  'distance': LocationServices.findDistanceBetweenCoordinates(
                    location[0],
                    location[1],
                    i['geometry']['location']['lat'],
                    i['geometry']['location']['lng'],
                  ),
                },
              );
            }
            if (_nearbyAtms.isEmpty) {
              MyAppServices.showSnackBar(context, "No Nearby Atm's");
            }
          });
        }

        return cameraPosition;
      },
    );
    return cameraPosition;
  }
}
