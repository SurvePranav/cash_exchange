import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/model/request_model.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/request_provider.dart';
import 'package:cashxchange/utils/location_services.dart';
import 'package:cashxchange/utils/util.dart';
import 'package:cashxchange/widgets/custom_button.dart';
import 'package:cashxchange/widgets/panel_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class FullMapScreen extends StatefulWidget {
  const FullMapScreen({super.key});

  @override
  State<FullMapScreen> createState() => _FullMapScreenState();
}

class _FullMapScreenState extends State<FullMapScreen> {
  // late Future<CameraPosition> _currentPosition;
  // late final GoogleMapController _mapController;
  final List<RequestModel> _locations = [];
  bool _showNearbyRequests = true;
  bool _useCurrentLocation = true;
  @override
  void initState() {
    // _currentPosition = getCameraPosition(current: true);
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
        child: SlidingUpPanel(
          minHeight: MediaQuery.of(context).size.height * 0.1,
          maxHeight: MediaQuery.of(context).size.height * 0.5,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(18),
          ),
          panelBuilder: (sc) {
            return PanelWidget(
              controller: sc,
            );
          },
          body: FutureBuilder<CameraPosition>(
            // future: _currentPosition,
            future: initiateMapWithNearbyRequests(
                useCurrentLocation: _useCurrentLocation),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: snapshot.data,
                      mapType: MapType.normal,
                      onMapCreated: (controller) {
                        // _mapController = controller;
                      },
                      myLocationEnabled: true,
                      markers: _locations.map((location) {
                        return Marker(
                          markerId: MarkerId(location.reqId),
                          position: LatLng(
                            location.locationLat,
                            location.locationLon,
                          ),
                          infoWindow: InfoWindow(
                            title: location.reqId,
                            snippet: location.info,
                          ),
                        );
                      }).toSet(),
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
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: CustomButton(
                                onPressed: () {
                                  setState(() {
                                    _useCurrentLocation = !_useCurrentLocation;
                                  });
                                },
                                text: '',
                                color: _useCurrentLocation
                                    ? Colors.white
                                    : AppColors.deepGreen,
                                child: Column(children: [
                                  Icon(
                                    Icons.location_pin,
                                    color: _useCurrentLocation
                                        ? AppColors.deepGreen
                                        : Colors.white,
                                  ),
                                  Text(
                                    "Near Home",
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: _useCurrentLocation
                                          ? AppColors.deepGreen
                                          : Colors.white,
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
                );
              } else {
                return Center(
                  child: LinearProgressIndicator(color: AppColors.deepGreen),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  // initiates map with current position and loads other markers
  Future<CameraPosition> initiateMapWithNearbyRequests(
      {required bool useCurrentLocation}) async {
    CameraPosition cameraPosition = const CameraPosition(
      target: LatLng(0, 0),
      zoom: 15,
    );

    if (useCurrentLocation == true) {
      await LocationServices.getCurrentLocation().then((location) async {
        cameraPosition = CameraPosition(
          target: LatLng(location[0], location[1]),
          zoom: 15,
        );

        // loading markers
        RequestProvider rp =
            Provider.of<RequestProvider>(context, listen: false);
        await rp.getActiveRequests().then((locations) {
          for (int i = 0; i < locations.length; i++) {
            if (UserModel.instance.uid != locations[i].uid) {
              _locations.add(locations[i]);
            }
          }
          if (_locations.isEmpty) {
            MyAppServices.showSlackBar(context, "No Nearby Requests");
          }
        });

        return cameraPosition;
      });
      return cameraPosition;
    } else {
      return CameraPosition(
          target: LatLng(
            double.parse(UserModel.instance.locationLat),
            double.parse(UserModel.instance.locationLon),
          ),
          zoom: 15);
    }
  }

  // Future<CameraPosition> initiateMapWithNearbyAtm(
  //     {bool current = false}) async {}
}
