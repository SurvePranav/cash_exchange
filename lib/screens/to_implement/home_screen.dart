import 'package:cashxchange/constants/color_constants.dart';
import 'package:cashxchange/screens/request_module_screens/active_requests_screen.dart';
import 'package:cashxchange/widgets/request_card.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ), // Adjust the value for roundness
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 60,
                  bottom: 30,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Handle tapping on "Check Request Status"
                    // You can navigate to the request status screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const RequestStatusScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue_2, // Change the text color
                    elevation: 3, // Change the button's elevation
                    padding: const EdgeInsets.all(16.0), // Change padding
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10.0), // Change button shape
                    ),
                  ),
                  child: Text(
                    'Check Request Status',
                    style: TextStyle(color: blue_10),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: _buildGridItem('Nearby ATMs', Icons.atm, () {
                        // Handle tapping on "Nearby ATMs"
                        // You can navigate to a map screen or list ATMs nearby
                      }),
                    ),
                    Expanded(
                      child:
                          _buildGridItem('Nearby Requests', Icons.person, () {
                        // Handle tapping on "Requests for Exchange"
                        // You can navigate to a list of requests or a chat screen
                      }),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 25),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                height: 300,
                child: const GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(19.0760, 72.8777),
                    zoom: 15,
                  ),
                ),
              ),
              RequestCard(
                amount: 'Rs.500',
                onAcceptPressed: () {},
                requestType: 'Cash',
                userImage: 'assets/images/profile_icon.png',
                userName: 'Demo User',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(String title, IconData iconData, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        color: blue_2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              iconData,
              size: 48.0,
              color: blue_10,
            ),
            const SizedBox(height: 8.0),
            Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
