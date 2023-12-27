import 'package:cashxchange/utils/location_services.dart';
import 'package:flutter/material.dart';

class WalkingDistance extends StatelessWidget {
  final double originLat, originLng, destinationLat, destinationLng;

  const WalkingDistance(
      {super.key,
      required this.originLat,
      required this.originLng,
      required this.destinationLat,
      required this.destinationLng});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: LocationServices.calculateWalkingDistance(
        originLat: originLat,
        originLng: originLng,
        destinationLat: destinationLat,
        destinationLng: destinationLng,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          String walkingDistance =
              (snapshot.data!['distance_value'] / 1000).toStringAsFixed(2);
          return Text('Walking Distance: $walkingDistance KM');
        } else {
          return const Text('WalkingDistance: --');
        }
      },
    );
  }
}
