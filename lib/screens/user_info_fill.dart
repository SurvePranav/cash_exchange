import 'dart:io';
import 'package:cashxchange/constants/color_constants.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/screens/main_body.dart';
import 'package:cashxchange/utils/util.dart';
import 'package:cashxchange/widgets/custom_button.dart';
import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    bioController.dispose();
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
                          child: CustomButton(
                            text: "Continue",
                            onPressed: () => storeData(),
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        cursorColor: blue_10,
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
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
    );
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
  }
}
