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
          title: Text(
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
        Divider(),
        ListTile(
          title: Text(
            'Walking Distance',
            style: TextStyle(
              color: Colors.deepOrange,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            distance,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
        Divider(),
        ListTile(
          title: Text(
            'Estimated Duration to reach',
            style: TextStyle(
              color: Colors.deepOrange,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            duration,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}
