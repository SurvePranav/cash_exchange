import 'package:cashxchange/constants/color_constants.dart';
import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/screens/profile_screen.dart';
import 'package:cashxchange/screens/request_module_screens/request_screen.dart';
import 'package:cashxchange/screens/to_implement/chat_screen.dart';
import 'package:cashxchange/screens/to_implement/home_screen.dart';
import 'package:cashxchange/screens/to_implement/notification_screen.dart';
import 'package:cashxchange/screens/user_info_fill.dart';
import 'package:cashxchange/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainBody extends StatefulWidget {
  final int currentIndex;
  const MainBody({super.key, required this.currentIndex});
  @override
  State<MainBody> createState() => _MainBodyState();
}

class _MainBodyState extends State<MainBody> {
  late final PageController _pageController;
  late int currentIndex;
  @override
  void initState() {
    _pageController = PageController(initialPage: widget.currentIndex);
    currentIndex = widget.currentIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        children: [
          const HomeScreen(),
          const ChatScreen(),
          const RaiseRequestScreen(),
          NofificationScreen(),
          const ProfileScreen(),
          // const UserInfoScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: currentIndex,
        pageController: _pageController,
        onTabChange: (index) {
          setState(
            () {
              currentIndex = index;
              _pageController.jumpToPage(
                index,
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
