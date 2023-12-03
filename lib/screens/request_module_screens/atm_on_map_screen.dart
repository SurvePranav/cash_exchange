import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AtmOnMapScreen extends StatelessWidget {
  final double latitude, longitude;
  final String atmName;
  const AtmOnMapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.atmName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(atmName),
      ),
      body: GoogleMap(
        zoomControlsEnabled: false,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        mapToolbarEnabled: true,
        initialCameraPosition: CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 18,
        ),
        markers: {
          Marker(
            markerId: MarkerId(atmName),
            position: LatLng(latitude, longitude),
          ),
        },
      ),
    );
  }
}
