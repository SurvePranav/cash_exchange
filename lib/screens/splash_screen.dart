import 'package:cashxchange/provider/auth_provider.dart';
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
  Future<void> checkUserAuthentication() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    await ap.checkSignIn().then((value) async {
      if (ap.isSignedIn == true) {
        await ap.getDataFromSP().whenComplete(
              () => Navigator.pushReplacementNamed(context, 'home_screen'),
            );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const WelcomeScreen(), // SecondPage is the destination page
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: checkUserAuthentication(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
