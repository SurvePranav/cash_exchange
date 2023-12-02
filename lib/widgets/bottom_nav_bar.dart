import 'package:cashxchange/constants/constant_values.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class CustomBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChange;
  final bool isHomeScreen;
  const CustomBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTabChange,
    this.isHomeScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 2),
      child: GNav(
        backgroundColor: Colors.white,
        color: AppColors.deepGreen,
        activeColor: Colors.white,
        tabBackgroundColor: AppColors.deepGreen,
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        gap: 7,
        onTabChange: onTabChange,
        selectedIndex: currentIndex,
        tabs: const [
          GButton(
            icon: Icons.home_outlined,
            iconSize: 28,
          ),
          GButton(
            icon: Icons.add_circle_outline,
            iconSize: 28,
          ),
          GButton(
            icon: Icons.chat_outlined,
            iconSize: 28,
          ),
        ],
      ),
    );
  }
}
