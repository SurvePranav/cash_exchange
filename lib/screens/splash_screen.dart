import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/screens/register_screen.dart';
import 'package:cashxchange/screens/welcome_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main_body.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkUserAuthentication();
  }

  void checkUserAuthentication() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    // await Future.delayed(const Duration(seconds: 2));
    if (ap.isSignedIn == true) {
      await ap.getDataFromSP().whenComplete(
            () => Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                builder: (context) =>
                    const MainBody(), // SecondPage is the destination page
              ),
            ),
          );
    } else {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) =>
              const WelcomeScreen(), // SecondPage is the destination page
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.blue,
        ),
      ),
    );
  }
}
