import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/provider/messaging_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
            icon: SizedBox(
              height: 26,
              width: 25,
              child: Stack(
                children: [
                  Icon(
                    Icons.chat_outlined,
                    color: AppColors.deepGreen,
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Consumer<MessagingProvider>(
                      builder: (BuildContext context, MessagingProvider mp,
                          Widget? child) {
                        return Visibility(
                          visible: mp.hasMessage,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.red,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            label: "chat"),
      ],
    );
  }
}
