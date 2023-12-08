import 'dart:io';
import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/provider/location_provider.dart';
import 'package:cashxchange/screens/main_body.dart';
import 'package:cashxchange/utils/util.dart';
import 'package:cashxchange/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class UserInfoScreen extends StatefulWidget {
  final bool editProfile;
  const UserInfoScreen({super.key, this.editProfile = false});

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
  void initState() {
    if (widget.editProfile) {
      nameController.text = UserModel.instance.name;
      emailController.text = UserModel.instance.email;
      bioController.text = UserModel.instance.bio;
      locationController.text = UserModel.instance.address;
      lat = UserModel.instance.locationLat;
      lon = UserModel.instance.locationLon;
    }
    super.initState();
  }

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
      appBar: widget.editProfile
          ? AppBar(
              title: const Text("Edit Profile"),
            )
          : null,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.deepGreen),
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
                            selectImage();
                          },
                          child: !widget.editProfile
                              ? CircleAvatar(
                                  backgroundColor: AppColors.deepGreen,
                                  backgroundImage:
                                      image != null ? FileImage(image!) : null,
                                  radius: 70,
                                  child: Stack(
                                    children: [
                                      image != null
                                          ? const SizedBox()
                                          : const Align(
                                              alignment: Alignment.center,
                                              child: Icon(
                                                Icons.account_circle,
                                                color: Colors.white,
                                                size: 90,
                                              ),
                                            ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Container(
                                            height: 35,
                                            width: 35,
                                            color: AppColors.deepGreen,
                                            child: const Icon(
                                              Icons.camera_alt,
                                              color: Colors.white,
                                              size: 28,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Hero(
                                  tag: "hero_image",
                                  child: CircleAvatar(
                                    backgroundColor: Colors.black,
                                    backgroundImage: image != null
                                        ? FileImage(image!)
                                        : NetworkImage(
                                                UserModel.instance.profilePic)
                                            as ImageProvider<Object>?,
                                    radius: 70,
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          height: 35,
                                          width: 35,
                                          color: AppColors.deepGreen,
                                          child: const Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
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
                                      locationButtonIcon: value.isLoading
                                          ? Icons.location_searching
                                          : Icons.location_pin,
                                      // locationButtonIcon: Icons.location_pin,
                                      onLocationPressed: () async {
                                        value.setLoading(true);
                                        await value
                                            .getCurrentLocation()
                                            .then((val) async {
                                          lat = '${val[0]}';
                                          lon = '${val[1]}';
                                          locationController.text = await value
                                              .getAddressFromCoordinates(
                                                  val[0], val[1]);
                                          value.setLoading(false);
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
                                text: widget.editProfile
                                    ? "Update Profile"
                                    : "Continue",
                                onPressed: () async {
                                  // getting latitude and longitude from address
                                  await value
                                      .getCoordinatesFromAddressString(
                                          locationController.text.trim())
                                      .then((coordinates) async {
                                    if (coordinates.isNotEmpty) {
                                      lat = coordinates[0].toString();
                                      lon = coordinates[1].toString();
                                    } else {
                                      List co =
                                          await value.getCurrentLocation();
                                      lat = co[0].toString();
                                      lon = co[1].toString();
                                    }

                                    //calling store data function
                                    await storeData();
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
    IconData locationButtonIcon = Icons.location_searching,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        cursorColor: AppColors.deepGreen,
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          suffixIcon: locationButton
              ? Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.deepGreen,
                        ),
                        child: Icon(
                          locationButtonIcon,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          if (onLocationPressed != null) {
                            onLocationPressed();
                          }
                        },
                      ),
                      const Text(
                        "current location",
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      )
                    ],
                  ),
                )
              : null,
          prefixIcon: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.deepGreen,
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
              color: AppColors.blue_4,
            ),
          ),
          hintText: hintText,
          alignLabelWithHint: true,
          border: InputBorder.none,
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }

  // for selecting image

  void selectImage() async {
    await checkPermission(Permission.photos, context).then((value) async {
      await pickImage(context).then((pickedImage) async {
        if (pickedImage != null) {
          image = pickedImage;
          setState(() {});
        }
      });
    });
  }

  // store user data to database
  Future<void> storeData({bool updateProfile = false}) async {
    final ap = Provider.of<AuthProvider>(context, listen: false);

    // saving the data
    if (nameController.text != "" &&
        emailController.text != "" &&
        locationController.text != "" &&
        bioController.text != "") {
      if (widget.editProfile) {
        UserModel.instance.name = nameController.text.trim();
        UserModel.instance.email = emailController.text.trim();
        UserModel.instance.bio = bioController.text.trim();
        UserModel.instance.address = locationController.text.trim();
        UserModel.instance.locationLat = lat;
        UserModel.instance.locationLon = lon;
        ap.saveUserDataToFirebase(
          context: context,
          profilePic: image,
          updateData: true,
          onSuccess: () async {
            // once data is saved we need to store it locally also using shared preference library
            await ap.saveDataToSP().then((value) {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('home_screen');
            });
          },
        );
      } else if (image != null) {
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
        await ap.saveUserDataToFirebase(
          context: context,
          profilePic: image,
          onSuccess: () {
            // once data is saved we need to store it locally also using shared preference library
            ap.saveDataToSP().then((value) => ap.setSignedIn()).then(
                  (value) => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const MainBody(
                          currentIndex: 0,
                        ),
                      ),
                      (route) => false),
                );
          },
        );
      } else {
        showSlackBar(context, "please Select Image");
      }
    } else {
      showSlackBar(context, "please fill all the fields");
    }
  }
}
