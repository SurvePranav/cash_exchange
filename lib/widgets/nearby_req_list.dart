import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/widgets/constant_widget.dart';
import 'package:cashxchange/widgets/custom_button.dart';
import 'package:flutter/material.dart';

typedef MyCallBack = Function(Map<String, dynamic> request);

class NearbyRequestList extends StatelessWidget {
  final List<Map<String, dynamic>> requests;
  final MyCallBack onTap;
  const NearbyRequestList({
    super.key,
    required this.requests,
    required this.onTap,
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
            final request = requests.elementAt(index);
            return Container(
              margin: index == 0
                  ? const EdgeInsets.only(
                      top: 20,
                      left: 20,
                      right: 20,
                      bottom: 1,
                    )
                  : index == requests.length - 1
                      ? const EdgeInsets.only(
                          bottom: 20,
                          left: 20,
                          right: 20,
                        )
                      : const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom: 1,
                        ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: index == 0 && index == requests.length - 1
                    ? const BorderRadius.all(
                        Radius.circular(20),
                      )
                    : index == 0
                        ? const BorderRadius.vertical(
                            top: Radius.circular(20),
                          )
                        : index == requests.length - 1
                            ? const BorderRadius.vertical(
                                bottom: Radius.circular(20),
                              )
                            : null,
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.mintGreen,
                      radius: 20,
                      backgroundImage: NetworkImage(request['profilePic']),
                    ),
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${request['name']}",
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
                          "${request['bio']}",
                        ),
                      ],
                    ),
                    onTap: () {
                      onTap(request);
                    },
                  ),
                  // const Divider(),
                  Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Image.asset(
                          request['type'] == 'Cash'
                              ? 'assets/images/want_cash.png'
                              : 'assets/images/want_online_money.png',
                          height: 250,
                        ),
                      ),
                      Container(
                        height: 250,
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
                              "Want ${request['type']}",
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
                              "Rs.${request['amount']}",
                            ),
                            Text(
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              "walking distance.${request['distance']} KM",
                            ),
                            const Text("Accepted By: --"),
                            SizedBox(
                              height: 55,
                              child: Text(
                                "More Info : ${request['info']}",
                                softWrap: true,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                const Expanded(
                                  child: SizedBox(),
                                ),
                                CustomButton(
                                  onPressed: () {},
                                  text: "Accept",
                                ),
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

      // return ListView.builder(
      //   itemCount: requests.length,
      //   itemBuilder: (bcontext, index) {
      //     final request = requests.elementAt(index);
      //     Card(
      //       color: AppColors.deepGreen,
      //       elevation: 5,
      //       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 13),
      //       shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(15),
      //       ),
      //       child: ListTile(
      //         contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      //         leading: CircleAvatar(
      //           backgroundColor: AppColors.mintGreen,
      //           radius: 20,
      //           backgroundImage:
      //               const AssetImage('assets/images/profile_icon.png'),
      //         ),
      //         title: Text(
      //           "Want ${request['type']} for Rs.${request['amount']}",
      //           style: const TextStyle(
      //             color: Colors.white,
      //             fontWeight: FontWeight.bold,
      //             fontSize: 15,
      //           ),
      //         ),
      //         subtitle: Row(
      //           children: [
      //             Text(
      //               'distance: ${request['distance']} KM',
      //               style: const TextStyle(
      //                 color: Colors.white70,
      //                 fontSize: 13,
      //               ),
      //             ),
      //             const Expanded(child: SizedBox()),
      //             SizedBox(
      //               width: 50,
      //               child: Row(
      //                 children: [
      //                   const Icon(Icons.remove_red_eye,
      //                       size: 18, color: Colors.white70),
      //                   const SizedBox(
      //                     width: 5,
      //                   ),
      //                   Text(
      //                     "${request['views']}",
      //                     style: const TextStyle(
      //                         color: Colors.white70, fontSize: 13),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           ],
      //         ),
      //         trailing: const Icon(
      //           Icons.arrow_forward_ios,
      //           color: Colors.white,
      //           size: 25,
      //         ),
      //         onTap: () {
      //           onTap(request);
      //         },
      //       ),
      //     );
      //   },
      // );
    }
  }
}
