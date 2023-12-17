import 'package:cached_network_image/cached_network_image.dart';
import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/screens/profile_module_screens/profile_pic_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NearbyRequestInfo extends StatelessWidget {
  final Map<String, dynamic> request;
  final String distance;
  const NearbyRequestInfo(
      {super.key, required this.request, required this.distance});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Request Info")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: Provider.of<AuthProvider>(context, listen: false)
            .getUserDataById(uid: request['uid']),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done) {
            final Map<String, dynamic> userData = snapshot.data ?? {};

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ImageFullScreen(
                            url: userData['profilePic']!,
                            heroTag: request['reqId'],
                          ),
                        ),
                      );
                    },
                    child: Hero(
                      tag: request['reqId'],
                      child: CircleAvatar(
                        backgroundColor: AppColors.deepGreen,
                        backgroundImage:
                            const AssetImage("assets/images/profile_icon.png"),
                        foregroundImage:
                            CachedNetworkImageProvider(userData['profilePic']!),
                        radius: 60,
                      ),
                    ),
                  ),
                  Text(
                    userData['name']!,
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.info),
                      Text(userData['bio']!),
                    ],
                  ),
                  buildInfoRow(
                      'Creation Date', request['createdAt'].toString()),
                  buildInfoRow('Amount', request['amount']),
                  buildInfoRow('Request Type', request['type']),
                  buildInfoRow('Views', request['views'].toString()),
                  buildInfoRow('Accepted By', '--'),
                  buildInfoRow('More Info', request['info']),
                  buildInfoRow('Distance From you', "$distance KM"),
                ],
              ),
            );
          } else {
            return const Center(
              child: Text("Something Went Wrong"),
            );
          }
        },
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
