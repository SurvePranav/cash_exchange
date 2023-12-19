import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/screens/profile_module_screens/profile_pic_screen.dart';
import 'package:cashxchange/screens/request_module_screens/atm_info_widget.dart';
import 'package:cashxchange/screens/request_module_screens/atm_on_map_screen.dart';
import 'package:cashxchange/utils/location_services.dart';
import 'package:cashxchange/utils/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AtmInfoScreen extends StatelessWidget {
  final Map<String, dynamic> atm;
  const AtmInfoScreen({super.key, required this.atm});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Details'),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            height: 280,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.mintGreen, AppColors.skyBlue],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: AppColors.deepGreen,
                      minRadius: 78.0,
                      child: atm['photo_reference'] != null
                          ? FutureBuilder(
                              future: LocationServices.getPhotoUrl(
                                  atm['photo_reference']),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ));
                                } else if (snapshot.hasData) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => ImageFullScreen(
                                            url: snapshot.data!,
                                            heroTag: 'atm_image',
                                          ),
                                        ),
                                      );
                                    },
                                    child: Hero(
                                      tag: 'atm_image',
                                      child: ClipOval(
                                        child: Image.network(
                                          snapshot.data!,
                                          width: 150,
                                          height: 150,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  return const Center(
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.business,
                                            color: Colors.white,
                                            size: 70,
                                          ),
                                          Icon(
                                            Icons.atm,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              },
                            )
                          : const Center(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.business,
                                      color: Colors.white,
                                      size: 70,
                                    ),
                                    Icon(
                                      Icons.atm,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  atm['name'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                Text(
                  'Rating: ${atm['rating']}/5',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.skyBlue),
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => AtmOnMapScreen(
                              latitude: atm['lat'],
                              longitude: atm['lng'],
                              atmName: atm['name'],
                            ),
                          ),
                        );
                      },
                      title: const Icon(
                        Icons.map,
                        color: Colors.white,
                        size: 30,
                      ),
                      subtitle: const Text(
                        'View On Map',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: AppColors.blue_6,
                    ),
                    child: ListTile(
                      onTap: () {
                        MyAppServices.launchAnyUrl(
                          'https://www.google.com/maps/search/?api=1&query=${atm['lat']},${atm['lng']}',
                        );
                      },
                      title: const Icon(
                        Icons.location_pin,
                        color: Colors.white,
                        size: 30,
                      ),
                      subtitle: const Text(
                        'Open in Maps',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          FutureBuilder(
            future: LocationServices.calculateWalkingDistance(
                originLat: atm['currentLat'],
                originLng: atm['currentLng'],
                destinationLat: atm['lat'],
                destinationLng: atm['lng']),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const AtmInfoWidget(
                  address: 'getting address...',
                  duration: 'finding duration...',
                  distance: 'finding distance...',
                );
              } else {
                if (snapshot.hasData) {
                  return AtmInfoWidget(
                    address: snapshot.data!['destination_address'],
                    distance:
                        "${(snapshot.data!['distance_value'] / 1000).toStringAsFixed(2)} KM",
                    duration: snapshot.data!['duration_text'],
                  );
                } else {
                  return const AtmInfoWidget(
                    address: 'could not get address',
                    duration: 'could not find duration',
                    distance: 'could not find distance',
                  );
                }
              }
            },
          )
        ],
      ),

      // body: Card(
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(15.0),
      //   ),
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       Container(
      //         height: MediaQuery.of(context).size.height * .5,
      //         child: Stack(
      //           children: [
      //             Padding(
      //               padding: const EdgeInsets.only(bottom: 40.0),
      //               child: Container(
      //                 height: MediaQuery.of(context).size.height,
      //                 decoration: BoxDecoration(
      //                   borderRadius: BorderRadius.only(
      //                     bottomLeft: Radius.elliptical(
      //                         MediaQuery.of(context).size.width * 0.5, 100.0),
      //                     bottomRight: Radius.elliptical(
      //                         MediaQuery.of(context).size.width * 0.5, 100.0),
      //                   ),
      //                   image: const DecorationImage(
      //                     fit: BoxFit.cover,
      //                     image: NetworkImage(
      //                         'https://i.pinimg.com/564x/1e/7f/85/1e7f85e354e1a11b4a439ac9d9f7e283.jpg'),
      //                   ),
      //                 ),
      //               ),
      //             ),
      //             Align(
      //               alignment: Alignment.topCenter,
      //               child: Stack(
      //                 children: [
      //                   Padding(
      //                     padding: const EdgeInsets.only(left: 10, top: 10),
      //                     child: Icon(
      //                       Icons.close,
      //                       color: Color(0xffC3C3C3),
      //                     ),
      //                   ),
      //                   Padding(
      //                     padding: const EdgeInsets.only(left: 10, top: 10),
      //                     child: Align(
      //                       alignment: Alignment.topCenter,
      //                       child: Text(
      //                         'Cora Richardson',
      //                         style: TextStyle(
      //                           color: Color(0xffBDBDBD),
      //                           fontSize: 25,
      //                         ),
      //                       ),
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //             Align(
      //               alignment: Alignment.bottomCenter,
      //               child: Row(
      //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //                 children: [
      //                   CircleAvatar(
      //                     radius: 30,
      //                     backgroundColor: Color(0xffD8D8D8),
      //                     child: Icon(
      //                       Icons.chat,
      //                       size: 30,
      //                       color: Color(0xff6E6E6E),
      //                     ),
      //                   ),
      //                   CircleAvatar(
      //                     radius: 70,
      //                     backgroundImage: NetworkImage(
      //                         'https://i.pinimg.com/564x/1e/7f/85/1e7f85e354e1a11b4a439ac9d9f7e283.jpg'),
      //                   ),
      //                   CircleAvatar(
      //                     radius: 30,
      //                     backgroundColor: Color(0xffD8D8D8),
      //                     child: Icon(
      //                       Icons.call,
      //                       size: 30,
      //                       color: Color(0xff6E6E6E),
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //       Padding(
      //         padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
      //         child: Text(
      //           'It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters',
      //           style: TextStyle(fontSize: 15),
      //         ),
      //       ),
      //       Row(
      //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //         children: [
      //           Text(
      //             'Hacker',
      //             style: TextStyle(
      //               fontWeight: FontWeight.bold,
      //             ),
      //           ),
      //           Text(
      //             '|',
      //             style: TextStyle(
      //               fontWeight: FontWeight.bold,
      //             ),
      //           ),
      //           Text(
      //             'Dev',
      //             style: TextStyle(
      //               fontWeight: FontWeight.bold,
      //             ),
      //           ),
      //           Text(
      //             '|',
      //             style: TextStyle(
      //               fontWeight: FontWeight.bold,
      //             ),
      //           ),
      //           Text(
      //             'Android',
      //             style: TextStyle(
      //               fontWeight: FontWeight.bold,
      //             ),
      //           ),
      //           Text(
      //             '|',
      //             style: TextStyle(
      //               fontWeight: FontWeight.bold,
      //             ),
      //           ),
      //           Text(
      //             'Travel',
      //             style: TextStyle(
      //               fontWeight: FontWeight.bold,
      //             ),
      //           ),
      //         ],
      //       ),
      //       Container(
      //         color: Color(0xffF8F8F8),
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //           children: [
      //             Padding(
      //               padding: const EdgeInsets.only(bottom: 16.0),
      //               child: Column(
      //                 children: [
      //                   Text('Article'),
      //                   SizedBox(
      //                     height: 15,
      //                   ),
      //                   Text(
      //                     '20',
      //                     style: TextStyle(
      //                       fontWeight: FontWeight.bold,
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //             Container(
      //               height: 50,
      //               width: 1,
      //               color: Colors.black,
      //             ),
      //             Padding(
      //               padding: const EdgeInsets.only(bottom: 16.0),
      //               child: Column(
      //                 children: [
      //                   Text('Followers'),
      //                   SizedBox(
      //                     height: 15,
      //                   ),
      //                   Text(
      //                     '200',
      //                     style: TextStyle(
      //                       fontWeight: FontWeight.bold,
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //             Container(
      //               height: 50,
      //               width: 1,
      //               color: Colors.black,
      //             ),
      //             Padding(
      //               padding: const EdgeInsets.only(bottom: 16.0),
      //               child: Column(
      //                 children: [
      //                   Text('Following'),
      //                   SizedBox(
      //                     height: 15,
      //                   ),
      //                   Text(
      //                     '80',
      //                     style: TextStyle(
      //                       fontWeight: FontWeight.bold,
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
