import 'package:cashxchange/model/request_model.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/request_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RequestDetailsScreen extends StatefulWidget {
  final String reqId;
  const RequestDetailsScreen({super.key, required this.reqId});

  @override
  State createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Details'),
      ),
      body: Consumer<RequestProvider>(
        builder: (context, value, child) {
          return FutureBuilder<void>(
            future: value.getRequestById(context, widget.reqId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else {
                String location = "Current Location";
                if (UserModel.instance.locationLat ==
                        RequestModel.instance.locationLat &&
                    UserModel.instance.locationLon ==
                        RequestModel.instance.locationLon) {
                  location = "Your Preffered Location";
                }
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildInfoRow('Creation Date',
                          RequestModel.instance.createdAt.toLocal().toString()),
                      buildInfoRow(
                          'Expiration Date',
                          RequestModel.instance.createdAt
                              .add(const Duration(hours: 12))
                              .toLocal()
                              .toString()),
                      buildInfoRow('Amount', RequestModel.instance.amount),
                      buildInfoRow('Request Type', RequestModel.instance.type),
                      buildInfoRow('Location', location),
                      buildInfoRow(
                          'Views', RequestModel.instance.views.toString()),
                      buildInfoRow('Accepted By', '--'),
                      buildInfoRow('More Info', RequestModel.instance.info),
                    ],
                  ),
                );
              }
            },
          );
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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
