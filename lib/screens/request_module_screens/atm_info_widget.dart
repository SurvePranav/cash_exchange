import 'package:flutter/material.dart';

class AtmInfoWidget extends StatelessWidget {
  final String address;
  final String duration;
  final String distance;

  const AtmInfoWidget(
      {super.key,
      required this.address,
      required this.duration,
      required this.distance});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text(
            'Address',
            style: TextStyle(
              color: Colors.deepOrange,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            address,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
        ),
        const Divider(),
        ListTile(
          title: const Text(
            'Walking Distance',
            style: TextStyle(
              color: Colors.deepOrange,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            distance,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
        ),
        const Divider(),
        ListTile(
          title: const Text(
            'Estimated Duration to reach',
            style: TextStyle(
              color: Colors.deepOrange,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            duration,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}
