import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/screens/profile_screen.dart';
import 'package:cashxchange/screens/to_implement/request_screen.dart';
import 'package:cashxchange/screens/to_implement/chat_screen.dart';
import 'package:cashxchange/screens/to_implement/home_screen.dart';
import 'package:cashxchange/screens/to_implement/notification_screen.dart';
import 'package:cashxchange/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainBody extends StatefulWidget {
  const MainBody({super.key});
  @override
  State<MainBody> createState() => _MainBodyState();
}

class _MainBodyState extends State<MainBody> {
  final PageController _pageController = PageController(initialPage: 0);
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      body: SafeArea(
        child: PageView(
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
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: currentIndex,
        pageController: _pageController,
        onTabChange: (index) {
          setState(
            () {
              currentIndex = index;
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeInOut,
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
