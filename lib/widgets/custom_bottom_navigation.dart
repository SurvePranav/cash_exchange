import 'package:cashxchange/constants/constant_values.dart';
import 'package:flutter/material.dart';

class MyCustomBottomNaviationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChange;
  const MyCustomBottomNaviationBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onTabChange,
      indicatorColor: AppColors.mintGreen,
      backgroundColor: Colors.white,
      elevation: 1,
      height: 50,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      destinations: [
        NavigationDestination(
          selectedIcon: Icon(
            Icons.home,
            color: AppColors.deepGreen,
          ),
          icon: Icon(
            Icons.home_outlined,
            color: AppColors.deepGreen,
          ),
          label: "home",
        ),
        NavigationDestination(
            selectedIcon: Icon(
              Icons.add_circle,
              color: AppColors.deepGreen,
            ),
            icon: Icon(
              Icons.add_circle_outline,
              color: AppColors.deepGreen,
            ),
            label: "add"),
        NavigationDestination(
            selectedIcon: Icon(
              Icons.chat,
              color: AppColors.deepGreen,
            ),
            icon: Icon(
              Icons.chat_outlined,
              color: AppColors.deepGreen,
            ),
            label: "chat"),
      ],
    );
  }
}
