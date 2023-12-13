import 'dart:developer';

import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/provider/connectivity_provider.dart';
import 'package:cashxchange/provider/utility_provider.dart';
import 'package:cashxchange/screens/home_screen.dart';
import 'package:cashxchange/screens/profile_module_screens/user_info_fill.dart';
import 'package:cashxchange/utils/util.dart';
import 'package:cashxchange/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId;
  const OTPScreen({super.key, required this.verificationId});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  String? otpCode;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<UtilityProvider>(
          builder: (context, value, child) {
            if (value.isLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.deepGreen,
                ),
              );
            } else {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 35),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back,
                              color: AppColors.deepGreen),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      Container(
                        height: 200,
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: AppColors.skyBlue,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          "assets/images/image3.png",
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Text(
                        "Verify",
                        style: TextStyle(
                            color: AppColors.darkBlack,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Please enter the OTP sent to your mobile number",
                        style: TextStyle(color: AppColors.dimBlack),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Pinput(
                        length: 6,
                        showCursor: true,
                        defaultPinTheme: PinTheme(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.deepGreen, width: 1.2),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onCompleted: (value) {
                          setState(() {
                            otpCode = value;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: CustomButton(
                          onPressed: () {
                            if (otpCode != null) {
                              verifyOtp(context, otpCode!);
                            } else {
                              MyAppServices.showSlackBar(
                                  context, "Enter 6-digt Code!");
                            }
                          },
                          text: 'Verify',
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Text(
                        "Didn't receive any code?",
                        style: TextStyle(color: AppColors.dimBlack),
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "Resend Code",
                          style: TextStyle(
                              color: AppColors.deepGreen,
                              fontWeight: FontWeight.w600,
                              fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // verify otp
  void verifyOtp(BuildContext context, String otp) async {
    if (Provider.of<ConnectivityProvider>(context, listen: false).isConnected) {
      final up = Provider.of<UtilityProvider>(context, listen: false);
      final ap = Provider.of<AuthProvider>(context, listen: false);
      up.setLoading(true);
      ap.verifyOtp(
        verificationId: widget.verificationId,
        userOtp: otp,
        context: context,
        onSuccess: () {
          // checking if the user exists in the lab
          ap.checkIfUserExists().then((exists) {
            if (exists) {
              // user exists in database
              ap.getDataFromFireStroe().then((value) {
                ap.setSignedIn().then((value) {
                  ap.saveDataToSP().then((value) {
                    up.setLoading(false);
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        'home_screen', (route) => false);
                  });
                });
              });
            } else {
              //user doesnot exists in database
              up.setLoading(false);
              Navigator.of(context).pushNamedAndRemoveUntil(
                  'user_info_screen', (route) => false);
            }
          });
        },
      );
    } else {
      MyAppServices.showSlackBar(
        context,
        "No internet Connection",
      );
    }
  }
}
