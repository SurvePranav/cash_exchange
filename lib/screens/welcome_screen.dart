import 'package:cashxchange/constants/color_constants.dart';
import 'package:cashxchange/screens/register_screen.dart';
import 'package:cashxchange/widgets/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/images/welcome_image.png"),
            const SizedBox(
              height: 40,
            ),
            Text(
              "Exchange Your Cash With Digital Money & Vise-A-Versa!",
              style: TextStyle(
                  color: AppColors.darkBlack,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "Start Your Journey Now!",
              style: TextStyle(color: AppColors.dimBlack),
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: CustomButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) =>
                          const RegisterScreen(), // SecondPage is the destination page
                    ),
                  );
                },
                text: 'Get Started',
              ),
            ),
          ],
        ),
      )),
    );
  }
}
