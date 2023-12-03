import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/auth_provider.dart';
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
    final isLoading =
        Provider.of<AuthProvider>(context, listen: true).isLoading;
    return Scaffold(
      body: SafeArea(
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.deepGreen,
                  ),
                )
              : Padding(
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
                            color: AppColors.blue_4,
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
                                showSlackBar(context, "Enter 6-digt Code!");
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
                )),
    );
  }

  // verify otp
  void verifyOtp(BuildContext context, String otp) {
    final ap = Provider.of<AuthProvider>(context, listen: false);

    ap.verifyOtp(
      context: context,
      verificationId: widget.verificationId,
      userOtp: otp,
      onSuccess: () {
        // checking if the user exists in the lab
        ap.checkIfUserExists().then((value) async {
          if (value == true) {
            // user exists in our database
            ap
                .getDataFromFireStroe()
                .then((value) async {
                  await ap.saveDataToSP();
                })
                .then((value) => ap.setSignedIn())
                .then((value) {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('home_screen', (route) => false);
                });
          } else {
            // new user
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const UserInfoScreen(),
                ),
                (route) => false);
          }
        });
      },
    );
  }
}