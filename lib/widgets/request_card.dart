import 'package:cashxchange/constants/color_constants.dart';
import 'package:flutter/material.dart';

class RequestCard extends StatelessWidget {
  final String userImage;
  final String userName;
  final String requestType;
  final String amount;
  final VoidCallback onAcceptPressed;

  const RequestCard({
    super.key,
    required this.userImage,
    required this.userName,
    required this.requestType,
    required this.amount,
    required this.onAcceptPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(25.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Rounded corners
      ),
      color: blue_4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 20,
          ),
          Center(
            child: CircleAvatar(
              backgroundColor: blue_6,
              backgroundImage:
                  const AssetImage("assets/images/profile_icon.png"),
              radius: 50,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Request Type: $requestType',
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Amount: $amount',
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue_2,
                      ),
                      onPressed: onAcceptPressed,
                      child: Text(
                        'Accept Request',
                        style: TextStyle(color: blue_10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
