import 'package:cached_network_image/cached_network_image.dart';
import 'package:cashxchange/model/connection_model.dart';
import 'package:cashxchange/model/request_model.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/provider/request_provider.dart';
import 'package:cashxchange/screens/request_module_screens/edit_request_screen.dart';
import 'package:cashxchange/utils/date_util.dart';
import 'package:cashxchange/utils/util.dart';
import 'package:cashxchange/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RequestDetailsScreen extends StatelessWidget {
  final String reqId;
  const RequestDetailsScreen({super.key, required this.reqId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Details'),
      ),
      body: StreamBuilder(
        stream: Provider.of<RequestProvider>(context, listen: false)
            .getRequestById(context, reqId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.data == null || snapshot.data!.data() == null) {
            // Handle the case where the document is null (deleted)
            return const Center(
              child: Text('Document not found'),
            );
          }
          final data = snapshot.data;
          final RequestModel request;
          request = RequestModel.fromJson(data!.data()!);
          // getting the expiration date of the request
          int expirationDate =
              DateTime.fromMillisecondsSinceEpoch(request.createdAt)
                  .add(const Duration(hours: 24))
                  .millisecondsSinceEpoch;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildInfoRow(
                    'Creation Date',
                    MyDateUtil.getMessageTime(
                        context: context, time: request.createdAt.toString())),
                buildInfoRow(
                    'Expiration Date',
                    MyDateUtil.getMessageTime(
                        context: context, time: expirationDate.toString())),
                buildInfoRow('Amount', request.amount),
                buildInfoRow('Request Type', request.type),
                buildInfoRow('Accepted By',
                    '${request.acceptedBy.length.toString()} peoples'),
                buildInfoRow('More Info', request.info),

                // if request is not confirmed and accepted by is empty
                if (request.confirmedTo.isEmpty &&
                    request.acceptedBy.isEmpty &&
                    request.createdAt < expirationDate)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(25),
                        width: 120,
                        height: 50,
                        child: CustomButton(
                          onPressed: () async {
                            await MyAppServices.showConfirmationDialog(
                                    context: context,
                                    title: 'Delete Request',
                                    body: 'do you want to delete this request?')
                                .then((value) async {
                              if (value) {
                                await Provider.of<RequestProvider>(context,
                                        listen: false)
                                    .deleteRequestById(reqId: request.reqId)
                                    .then((value) {
                                  Navigator.of(context).pop();
                                });
                              }
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
                      Container(
                        margin: const EdgeInsets.all(25),
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
                  ),

                // confirm by yourself if you want to notify others that request is confirmed.
                if (request.confirmedTo.isEmpty &&
                    request.acceptedBy.isNotEmpty &&
                    request.createdAt < expirationDate)
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        MyAppServices.showConfirmationDialog(
                                context: context,
                                title: 'Confirm By Yourself',
                                body: 'request will be marked as confirm')
                            .then((value) {
                          if (value) {
                            Provider.of<RequestProvider>(context, listen: false)
                                .confirmRequest(
                                    reqId: request.reqId, uid: request.uid);
                          }
                        });
                      },
                      child: const Text('Confirm By Yourself'),
                    ),
                  ),
                if (request.confirmedTo.contains(UserModel.instance.uid))
                  const Text(
                    "Confirmed To Yourself",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                if (request.confirmedTo.isNotEmpty &&
                    !request.confirmedTo.contains(UserModel.instance.uid))
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Confirmed To: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      FutureBuilder(
                        future:
                            Provider.of<AuthProvider>(context, listen: false)
                                .getUserDataById(uid: request.confirmedTo),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox();
                          } else if (!snapshot.hasData) {
                            return const SizedBox();
                          } else {
                            final user = Connection.fromJson(snapshot.data!);
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    CachedNetworkImageProvider(user.profilePic),
                              ),
                              title: Text(user.name),
                              subtitle: Text(user.bio),
                            );
                          }
                        },
                      )
                    ],
                  )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
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
            softWrap: true,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
