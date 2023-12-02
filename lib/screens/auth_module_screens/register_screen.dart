import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/widgets/custom_button.dart';
import 'package:country_picker/country_picker.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/constant_values.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _controller = TextEditingController();
  Country selectedCountry = Country(
    phoneCode: "91",
    countryCode: "IN",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "India",
    example: "India",
    displayName: "India",
    displayNameNoCountryCode: "IN",
    e164Key: "",
  );

  @override
  Widget build(BuildContext context) {
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 35),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: AppColors.blue_4,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    "assets/images/image2.png",
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Text(
                  "Register",
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
                  "Add your phone number, we will send you a verification code!",
                  style: TextStyle(color: AppColors.dimBlack),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: _controller,
                  cursorColor: AppColors.deepGreen,
                  onChanged: (value) {
                    if (_controller.text.length == 9 ||
                        _controller.text.length == 10) {
                      setState(() {});
                    }
                  },
                  style: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide:
                          BorderSide(color: AppColors.dimBlack, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide:
                          BorderSide(color: AppColors.deepGreen, width: 1.5),
                    ),
                    hintText: "Enter phone number",
                    hintStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.normal),
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(5.0),
                      width: 90,
                      alignment: Alignment.center,
                      // color: Colors.red,
                      child: InkWell(
                        onTap: () {
                          showCountryPicker(
                              context: context,
                              onSelect: (value) {
                                setState(() {
                                  selectedCountry = value;
                                });
                              },
                              countryListTheme: const CountryListThemeData(
                                  bottomSheetHeight: 600));
                        },
                        child: Text(
                          "${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    suffixIcon: _controller.text.length > 9
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipOval(
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  color: Colors.green,
                                  child: const Icon(
                                    Icons.done,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              )
                            ],
                          )
                        : null,
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: CustomButton(
                    onPressed: () {
                      sendPhoneNumber();
                    },
                    text: 'Login',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void sendPhoneNumber() {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String phoneNo = _controller.text.trim();
    ap.signInWithPhone(context, "+${selectedCountry.phoneCode}$phoneNo");
  }
}
