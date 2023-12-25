import 'package:cached_network_image/cached_network_image.dart';
import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/model/connection_model.dart';
import 'package:cashxchange/model/request_model.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/utils/location_services.dart';
import 'package:cashxchange/widgets/constant_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef MyCallBack = Function(
    RequestModel request, Connection connection, String distance);
typedef MyCallBack2 = Function(RequestModel request);

class NearbyRequestList extends StatelessWidget {
  final List<RequestModel> requests;
  final MyCallBack onTap;
  final MyCallBack2 onAccept;
  final double myLat;
  final double myLng;
  const NearbyRequestList({
    super.key,
    required this.requests,
    required this.onTap,
    required this.onAccept,
    required this.myLat,
    required this.myLng,
  });

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return MyConstantWidget(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("No nearby requests"),
            const SizedBox(
              height: 100,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 100,
                height: 100,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: AppColors.deepGreen),
                  onPressed: () {
                    // Navigator.of(context).push(MaterialPageRoute(
                    //   builder: (context) => const MainBody(
                    //     currentIndex: 2,
                    //   ),
                    // ));
                  },
                  child: const Icon(
                    Icons.atm,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const Text(
              "See Nearby ATM's",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20.0,
              ),
            ),
          ],
        ),
      );
    } else {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            String distance = "--";
            final request = requests.elementAt(index);
            final bool isAccepted =
                request.acceptedBy.contains(UserModel.instance.uid);
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
                              onTap(request, user, distance);
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
                            FutureBuilder(
                              future: LocationServices.calculateWalkingDistance(
                                  originLat: myLat,
                                  originLng: myLng,
                                  destinationLat: request.locationLat,
                                  destinationLng: request.locationLon),
                              builder: (context, snapshot) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.none:
                                  case ConnectionState.waiting:
                                  case ConnectionState.active:
                                    return const Text(
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      "walking distance: calculating...",
                                    );
                                  case ConnectionState.done:
                                    if (snapshot.hasData) {
                                      distance =
                                          (snapshot.data!['distance_value'] /
                                                  1000)
                                              .toStringAsFixed(2);
                                      return Text(
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        "Walking distance: $distance KM",
                                      );
                                    } else {
                                      return const Text(
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        "walking distance: could not get!",
                                      );
                                    }
                                }
                              },
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
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () {
                                      if (!request.acceptedBy
                                          .contains(UserModel.instance.uid)) {
                                        onAccept(request);
                                      }
                                    },
                                    style: ButtonStyle(
                                      overlayColor:
                                          MaterialStateProperty.all<Color>(
                                              isAccepted
                                                  ? Colors.green.withAlpha(200)
                                                  : Colors.white
                                                      .withAlpha(200)),
                                      side:
                                          MaterialStateProperty.all<BorderSide>(
                                        BorderSide(
                                            color: isAccepted
                                                ? Colors.white
                                                : AppColors.deepGreen,
                                            width: 1.0),
                                      ),
                                      foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                        isAccepted
                                            ? Colors.white
                                            : AppColors.deepGreen,
                                      ),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              isAccepted
                                                  ? AppColors.deepGreen
                                                      .withAlpha(170)
                                                  : Colors.transparent),
                                    ),
                                    child: Text(
                                        isAccepted ? 'Accepted' : 'Accept'),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          childCount: requests.length,
        ),
      );
    }
  }
}
