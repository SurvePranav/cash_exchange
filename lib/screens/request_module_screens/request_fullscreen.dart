import 'package:cashxchange/model/request_model.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/request_provider.dart';
import 'package:cashxchange/screens/request_module_screens/active_requests_screen.dart';
import 'package:cashxchange/screens/request_module_screens/edit_request_screen.dart';
import 'package:cashxchange/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RequestDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> request;
  const RequestDetailsScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Request Details'),
        ),
        body: Builder(builder: (context) {
          String location = "Current Location";
          if (UserModel.instance.locationLat ==
                  RequestModel.instance.locationLat.toString() &&
              UserModel.instance.locationLon ==
                  RequestModel.instance.locationLon.toString()) {
            location = "Home Location";
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildInfoRow('Creation Date',
                    request['createdAt'].toDate().toLocal().toString()),
                buildInfoRow(
                    'Expiration Date',
                    request['createdAt']
                        .toDate()
                        .add(const Duration(hours: 12))
                        .toLocal()
                        .toString()),
                buildInfoRow('Amount', request['amount']),
                buildInfoRow('Request Type', request['type']),
                buildInfoRow('Location', location),
                buildInfoRow('Views', request['views'].toString()),
                buildInfoRow('Accepted By', '--'),
                buildInfoRow('More Info', request['info']),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 50,
                      child: CustomButton(
                        onPressed: () async {
                          await Provider.of<RequestProvider>(context,
                                  listen: false)
                              .deleteRequestById(reqId: request['reqId'])
                              .then((value) {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const RequestStatusScreen(),
                              ),
                            );
                          });
                        },
                        text: "",
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Delete"),
                            Icon(Icons.delete),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 40,
                    ),
                    SizedBox(
                      width: 120,
                      height: 50,
                      child: CustomButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EditRequest(
                                request: request,
                              ),
                            ),
                          );
                        },
                        text: "",
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Edit"),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(Icons.edit),
                          ],
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          );
        }));
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
