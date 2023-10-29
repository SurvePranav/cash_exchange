import 'package:cashxchange/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class CustomBottomNavbar extends StatefulWidget {
  final PageController pageController;
  final int currentIndex;
  final Function(int) onTabChange;
  const CustomBottomNavbar({
    super.key,
    required this.pageController,
    required this.currentIndex,
    required this.onTabChange,
  });

  @override
  State<CustomBottomNavbar> createState() => _CustomBottomNavbarState();
}

class _CustomBottomNavbarState extends State<CustomBottomNavbar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: blue_10,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: GNav(
          backgroundColor: blue_10,
          color: Colors.white,
          activeColor: Colors.white,
          tabBackgroundColor: blue_8,
          padding: const EdgeInsets.all(10),
          gap: 10,
          onTabChange: widget.onTabChange,
          selectedIndex: widget.currentIndex,
          tabs: [
            GButton(
              icon: Icons.home_outlined,
              text: "Home",
              onPressed: () {},
            ),
            GButton(
              icon: Icons.chat,
              text: 'Chat',
              onPressed: () {},
            ),
            GButton(
              icon: Icons.add,
              onPressed: () {},
            ),
            GButton(
              icon: Icons.notification_add,
              onPressed: () {},
            ),
            GButton(
              icon: Icons.person_outlined,
              text: 'Profile',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
