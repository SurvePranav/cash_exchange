import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/model/request_model.dart';
import 'package:cashxchange/provider/request_provider.dart';
import 'package:cashxchange/screens/profile_module_screens/transactions_list.dart';
import 'package:cashxchange/screens/request_module_screens/request_fullscreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyTransactionsScreen extends StatefulWidget {
  const MyTransactionsScreen({super.key});

  @override
  State<MyTransactionsScreen> createState() => _MyTransactionsScreenState();
}

class _MyTransactionsScreenState extends State<MyTransactionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Transactions",
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
          return FutureBuilder<List<RequestModel>>(
            future: value.getAllRequests(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData) {
                List<RequestModel> documents = snapshot.data ?? [];
                return TransactionsList(
                  requests: documents,
                  onTap: (RequestModel request) {
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
