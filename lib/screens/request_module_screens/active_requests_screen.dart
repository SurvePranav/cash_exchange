import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/provider/request_provider.dart';
import 'package:cashxchange/screens/request_module_screens/request_fullscreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'active_requests_list.dart';

class RequestStatusScreen extends StatefulWidget {
  const RequestStatusScreen({super.key});

  @override
  State<RequestStatusScreen> createState() => _RequestStatusScreenState();
}

class _RequestStatusScreenState extends State<RequestStatusScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Your Active Requests",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
        ),
        backgroundColor: AppColors.deepGreen,
      ),
      body: Consumer<RequestProvider>(
        builder: (context, value, child) {
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: value.getActiveRequests(context, onlyMyRequests: true),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData) {
                List<Map<String, dynamic>> documents = snapshot.data ?? [];
                return ActiveRequestsList(
                  requests: documents,
                  onTap: (Map<String, dynamic> request) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RequestDetailsScreen(
                          request: request,
                        ),
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return const Center(child: Text("Something Went wrong"));
              }
            },
          );
        },
      ),
    );
  }
}
