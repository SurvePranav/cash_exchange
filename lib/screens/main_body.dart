import 'package:cashxchange/constants/color_constants.dart';
import 'package:cashxchange/screens/chat_module_screens/chat_screen.dart';
import 'package:cashxchange/screens/home_screen.dart';
import 'package:cashxchange/screens/request_module_screens/request_screen.dart';
import 'package:cashxchange/widgets/custom_bottom_navigation.dart';
import 'package:flutter/material.dart';

class MainBody extends StatefulWidget {
  final int currentIndex;
  const MainBody({super.key, this.currentIndex = 0});
  @override
  State<MainBody> createState() => _MainBodyState();
}

class _MainBodyState extends State<MainBody> {
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentPage == 0 ? true : false,
      onPopInvoked: (myval) async {
        _currentPage = 0;
        setState(() {});
      },
      child: Scaffold(
        backgroundColor: AppColors.blue_4,
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                stops: const [
                  0.5,
                  1.0,
                ],
                colors: [
                  AppColors.mintGreen,
                  AppColors.blue_4,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: IndexedStack(
              index: _currentPage,
              children: const [
                HomeScreen(),
                // SafeArea(child: Container()),
                RaiseRequestScreen(),
                ChatScreen(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: MyCustomBottomNaviationBar(
          selectedIndex: _currentPage,
          onTabChange: (int index) {
            _currentPage = index;
            setState(() {});
          },
        ),
      ),
    );
  }
}
