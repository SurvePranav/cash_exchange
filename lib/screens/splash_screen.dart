import 'package:cashxchange/main.dart';
import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/screens/auth_module_screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), () {
      checkUserAuthentication();
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return const Scaffold(
      body: Center(
        child: Hero(
          tag: 'app_logo',
          child: Image(
            image: AssetImage('assets/images/app_logo.png'),
          ),
        ),
      ),
    );
  }

  Future<void> checkUserAuthentication() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    await ap.checkSignIn().then(
      (value) async {
        if (ap.isSignedIn == true) {
          await ap.getDataFromSP().whenComplete(
                () => Navigator.pushReplacementNamed(context, 'home_screen'),
              );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const WelcomeScreen(), // SecondPage is the destination page
            ),
          );
        }
      },
    );
  }
}
