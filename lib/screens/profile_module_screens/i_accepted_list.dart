import 'package:cached_network_image/cached_network_image.dart';
import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/model/connection_model.dart';
import 'package:cashxchange/model/request_model.dart';
import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/utils/date_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef MyCallBack = Function(RequestModel request, Connection user);

class IAcceptedList extends StatelessWidget {
  final List<RequestModel> requests;
  final MyCallBack onTap;
  const IAcceptedList({super.key, required this.requests, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const Center(
        child: Text(
          "No Requests Confirmed To you",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 20.0,
          ),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests.elementAt(index);
          return Container(
            margin: const EdgeInsets.only(
              bottom: 20,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(
                Radius.circular(20),
              ),
              border: Border.all(color: AppColors.deepGreen, width: 1),
            ),
            child: Column(
              children: [
                StreamBuilder(
                  stream: Provider.of<AuthProvider>(context, listen: false)
                      .getUserById(request.uid),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.mintGreen,
                            radius: 20,
                            backgroundImage: const AssetImage(
                                'assets/images/profile_icon.png'),
                          ),
                          title: const Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "......",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                "......",
                              ),
                            ],
                          ),
                        );
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final Connection user;
                        if (snapshot.data != null) {
                          user = Connection.fromJson(snapshot.data!.data()!);
                        } else {
                          user = Connection.fromJson({});
                        }

                        return ListTile(
                          leading: Hero(
                            tag: request.reqId,
                            child: CircleAvatar(
                              backgroundColor: AppColors.mintGreen,
                              radius: 20,
                              backgroundImage:
                                  CachedNetworkImageProvider(user.profilePic),
                            ),
                          ),
                          title: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                user.bio,
                              ),
                            ],
                          ),
                          onTap: () {
                            onTap(request, user);
                          },
                        );
                    }
                  },
                ),
                Divider(
                  color: AppColors.deepGreen,
                ),
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Image.asset(
                        request.type == 'Cash'
                            ? 'assets/images/want_cash.png'
                            : 'assets/images/want_online_money.png',
                        height: 270,
                      ),
                    ),
                    Container(
                      height: 270,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [
                            Colors.white.withOpacity(0.6),
                            Colors.white.withOpacity(0.8),
                            Colors.white.withOpacity(1),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          Text(
                            "Want ${request.type}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                            "Rs.${request.amount}",
                          ),
                          Text(
                            "Accepted By ${request.acceptedBy.length} peoples",
                          ),
                          const Text(
                            "More info:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(
                            height: 55,
                            child: Text(
                              request.info,
                              softWrap: true,
                            ),
                          ),
                          Text(MyDateUtil.getTimeStamp(
                              context: context,
                              time: request.createdAt.toString())),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }
  }
}
