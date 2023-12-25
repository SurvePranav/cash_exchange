import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/model/connection_model.dart';
import 'package:cashxchange/model/request_model.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/request_provider.dart';
import 'package:cashxchange/screens/profile_module_screens/i_accepted_list.dart';
import 'package:cashxchange/widgets/nearby_request_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IAcceptedScreen extends StatefulWidget {
  const IAcceptedScreen({super.key});
  @override
  State<IAcceptedScreen> createState() => _IAcceptedScreenState();
}

class _IAcceptedScreenState extends State<IAcceptedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Confirmed To Me",
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
            future: value.getRequestsConfirmedToMe(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasData) {
                List<RequestModel> documents = snapshot.data ?? [];

                // removing own requests
                documents
                    .removeWhere((item) => item.uid == UserModel.instance.uid);

                // sorting list according to the
                documents.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: IAcceptedList(
                    requests: documents,
                    onTap: (
                      RequestModel request,
                      Connection connection,
                    ) async {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return NearbyRequestInfo(
                          request: request,
                          connection: connection,
                          distance: '--',
                        );
                      }));
                    },
                  ),
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
