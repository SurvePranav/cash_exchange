import 'package:cashxchange/constants/constant_values.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PickLocationScreen extends StatefulWidget {
  final List<double> coordinates;
  const PickLocationScreen({super.key, required this.coordinates});

  @override
  State<PickLocationScreen> createState() => _PickLocationScreenState();
}

class _PickLocationScreenState extends State<PickLocationScreen> {
  late GoogleMapController mapController;
  LatLng selectedLocation = const LatLng(0, 0);
  @override
  void initState() {
    selectedLocation = LatLng(widget.coordinates[0], widget.coordinates[1]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
      ),
      body: GoogleMap(
          zoomControlsEnabled: false,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          onMapCreated: (controller) {
            mapController = controller;
          },
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.coordinates[0], widget.coordinates[1]),
            zoom: 17.0,
          ),
          onTap: (LatLng location) {
            selectedLocation = location;
            mapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: selectedLocation,
                  zoom: 17,
                ),
              ),
            );
            setState(() {});
          },
          markers: {
            Marker(
                markerId: const MarkerId('selectedLocation'),
                position: LatLng(
                    selectedLocation.latitude, selectedLocation.longitude),
                infoWindow: const InfoWindow(
                  title: "Use this location",
                ),
                onTap: () {}),
          }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.deepGreen,
        onPressed: () {
          Navigator.pop(context, [
            selectedLocation.latitude,
            selectedLocation.longitude,
          ]);
        },
        child: const Icon(
          Icons.check,
          color: Colors.white,
        ),
      ),
    );
  }
}
