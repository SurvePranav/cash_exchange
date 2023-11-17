import 'dart:io';
import 'package:cashxchange/constants/color_constants.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/provider/location_provider.dart';
import 'package:cashxchange/screens/main_body.dart';
import 'package:cashxchange/utils/util.dart';
import 'package:cashxchange/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  File? image;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();
  final locationController = TextEditingController();
  late String lat, lon;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    bioController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        Provider.of<AuthProvider>(context, listen: true).isLoading;

    return Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: blue_10),
            )
          : SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 18),
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            if (await checkPermission(
                                Permission.photos, context)) {
                              selectImage();
                            }
                          },
                          child: image == null
                              ? CircleAvatar(
                                  backgroundColor: blue_10,
                                  radius: 50,
                                  child: const Icon(
                                    Icons.account_circle,
                                    color: Colors.white,
                                    size: 60,
                                  ),
                                )
                              : CircleAvatar(
                                  backgroundImage: FileImage(image!),
                                  radius: 50,
                                ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          // padding:
                          //     const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                          margin: const EdgeInsets.only(top: 30),
                          child: Column(
                            children: [
                              // name field
                              textFeld(
                                hintText: "John Smith",
                                icon: Icons.account_circle,
                                inputType: TextInputType.name,
                                maxLines: 1,
                                controller: nameController,
                              ),

                              // email
                              textFeld(
                                hintText: "abc@example.com",
                                icon: Icons.email,
                                inputType: TextInputType.emailAddress,
                                maxLines: 1,
                                controller: emailController,
                              ),

                              //location
                              Consumer<LocationProvider>(
                                builder: (context, value, child) {
                                  return textFeld(
                                      hintText: "Enter your address",
                                      icon: Icons.location_pin,
                                      inputType: TextInputType.name,
                                      maxLines: 2,
                                      controller: locationController,
                                      locationButton: true,
                                      onLocationPressed: () async {
                                        await value
                                            .getCurrentLocation()
                                            .then((val) async {
                                          lat = '${val.latitude}';
                                          lon = '${val.longitude}';
                                          final coordinates = Coordinates(
                                              double.parse(lat),
                                              double.parse(lon));
                                          var address = await value
                                              .getAddressFromCoordinates(
                                                  coordinates);
                                          locationController.text = address
                                              .first.addressLine
                                              .toString();
                                          setState(() {});
                                        });
                                      });
                                },
                              ),

                              // bio
                              textFeld(
                                hintText: "Enter your bio here...",
                                icon: Icons.edit,
                                inputType: TextInputType.name,
                                maxLines: 2,
                                controller: bioController,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          height: 50,
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: Consumer<LocationProvider>(
                            builder: (context, value, child) {
                              return CustomButton(
                                text: "Continue",
                                onPressed: () async {
                                  // getting latitude and longitude from address
                                  await value
                                      .getAddressFromQuery(
                                          locationController.text.trim())
                                      .then((value) {
                                    lat = value.first.coordinates.latitude
                                        .toString();
                                    lon = value.first.coordinates.longitude
                                        .toString();

                                    //calling store data function
                                    storeData();
                                  });
                                },
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget textFeld({
    required String hintText,
    required IconData icon,
    required TextInputType inputType,
    required int maxLines,
    required TextEditingController controller,
    Function? onLocationPressed,
    locationButton = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        cursorColor: blue_10,
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          suffixIcon: locationButton
              ? Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue_10,
                    ),
                    child: const Icon(
                      Icons.location_searching,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (onLocationPressed != null) {
                        onLocationPressed();
                      }
                    },
                  ),
                )
              : null,
          prefixIcon: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: blue_10,
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.transparent,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: blue_4,
            ),
          ),
          hintText: hintText,
          alignLabelWithHint: true,
          border: InputBorder.none,
          fillColor: blue_2,
          filled: true,
        ),
      ),
    );
  }

  // for selecting image

  void selectImage() async {
    image = await pickImage(context);
    setState(() {});
  }

  // store user data to database
  void storeData() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);

// initilizing userModel singleton instance
    UserModel.instance.initializeUser(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      bio: bioController.text.trim(),
      profilePic: "",
      createdAt: "",
      phoneNumber: "",
      uid: "",
      address: locationController.text.trim(),
      locationLat: lat,
      locationLon: lon,
    );

    // saving the data
    if (image != null) {
      ap.saveUserDataToFirebase(
        context: context,
        profilePic: image!,
        onSuccess: () {
          // once data is saved we need to store it locally also using shared preference library
          ap.saveDataToSP().then((value) => ap.setSignedIn()).then(
                (value) => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const MainBody(),
                    ),
                    (route) => false),
              );
        },
      );
    } else {
      showSlackBar(context, "Please upload a profile photo");
    }
    ;
  }
}
