import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RequestStatusScreen extends StatefulWidget {
  const RequestStatusScreen({super.key});

  @override
  State<RequestStatusScreen> createState() => _RequestStatusScreenState();
}

class _RequestStatusScreenState extends State<RequestStatusScreen> {
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
