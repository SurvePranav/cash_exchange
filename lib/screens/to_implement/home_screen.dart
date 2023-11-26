import 'package:cashxchange/constants/color_constants.dart';
import 'package:cashxchange/screens/request_module_screens/active_requests_screen.dart';
import 'package:cashxchange/screens/to_implement/full_map.dart';
import 'package:cashxchange/widgets/request_card.dart';
import 'package:cashxchange/widgets/view_map.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                  Navigator.of(context).push(CupertinoPageRoute(
                    builder: (context) => const RequestStatusScreen(),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Change the text color
                  padding: const EdgeInsets.all(16.0), // Change padding
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Change button shape
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.request_page,
                      color: AppColors.deepGreen,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      'Check Request Status',
                      style: TextStyle(color: AppColors.deepGreen),
                    ),
                    const Expanded(child: SizedBox()),
                    Icon(
                      Icons.arrow_forward,
                      color: AppColors.deepGreen,
                    ),
                  ],
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
                    child: _buildGridItem('Nearby Requests', Icons.person, () {
                      // Handle tapping on "Requests for Exchange"
                      // You can navigate to a list of requests or a chat screen
                    }),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: ViewMapWidget(),
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
    );
  }

  Widget _buildGridItem(String title, IconData iconData, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              iconData,
              size: 48.0,
              color: AppColors.deepGreen,
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
