import 'package:cashxchange/constants/color_constants.dart';
import 'package:cashxchange/provider/location_provider.dart';
import 'package:cashxchange/screens/to_implement/full_map.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class ViewMapWidget extends StatelessWidget {
  const ViewMapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Container(
            // color: Colors.red,
            padding: const EdgeInsets.all(10),
            height: 200,
            child: FutureBuilder(
              future: Provider.of<LocationProvider>(context, listen: false)
                  .getCurrentLocation(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.deepGreen,
                    ),
                  );
                } else {
                  return GoogleMap(
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    markers: {
                      Marker(
                        markerId: const MarkerId("1"),
                        position: LatLng(snapshot.data[0], snapshot.data[1]),
                        infoWindow: const InfoWindow(
                          title: 'Your location',
                        ),
                      ),
                    },
                    initialCameraPosition: CameraPosition(
                      target: LatLng(snapshot.data[0], snapshot.data[1]),
                      zoom: 14,
                    ),
                  );
                }
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) => const FullMapScreen(),
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, // Change the text color
              padding: const EdgeInsets.all(16.0), // Change padding
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(10.0), // Change button shape
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.map,
                  color: AppColors.deepGreen,
                ),
                const SizedBox(
                  width: 20,
                ),
                Text(
                  'View On Map',
                  style: TextStyle(color: AppColors.deepGreen),
                ),
                const Expanded(child: SizedBox()),
                Icon(
                  Icons.arrow_forward,
                  color: AppColors.deepGreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
