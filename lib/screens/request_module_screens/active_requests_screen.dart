import 'dart:developer';

import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/model/request_model.dart';
import 'package:cashxchange/provider/request_provider.dart';
import 'package:cashxchange/screens/request_module_screens/request_fullscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: Provider.of<RequestProvider>(context, listen: false)
            .getActiveRequestsAsStream(onlyMyRequests: true),
        builder: (context, snapshot) {
          List<RequestModel> requests = [];
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.active:
            case ConnectionState.done:
              final data = snapshot.data?.docs;
              requests =
                  data?.map((e) => RequestModel.fromJson(e.data())).toList() ??
                      [];
              requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              return ActiveRequestsList(
                requests: requests,
                onTap: (RequestModel request) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RequestDetailsScreen(
                        reqId: request.reqId,
                      ),
                    ),
                  );
                },
              );
          }
        },
      ),
    );
  }
}
