import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FullMapScreen extends StatefulWidget {
  const FullMapScreen({super.key});

  @override
  State<FullMapScreen> createState() => _FullMapScreenState();
}

class _FullMapScreenState extends State<FullMapScreen> {
  @override
  Widget build(BuildContext context) {
    final Completer<GoogleMapController> mapController = Completer();
    const CameraPosition cameraPosition = CameraPosition(
      target: LatLng(19.0760, 72.8777),
      zoom: 15,
    );
    return Scaffold(
      body: SafeArea(
        child: GoogleMap(
          initialCameraPosition: cameraPosition,
          mapType: MapType.normal,
          compassEnabled: true,
          onMapCreated: (controller) {
            mapController.complete(controller);
          },
        ),
      ),
    );
  }
}
