import 'package:cashxchange/constants/color_constants.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/screens/profile_pic_screen.dart';
import 'package:cashxchange/screens/user_info_fill.dart';
import 'package:cashxchange/screens/welcome_screen.dart';
import 'package:cashxchange/utils/local_images.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    return SafeArea(
        child: SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 40,
                  height: 60,
                ),
                Text(
                  "Your Profile",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepGreen,
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: IconButton(
                    icon: Icon(
                      Icons.logout,
                      size: 30,
                      color: AppColors.deepGreen,
                    ),
                    onPressed: () async {
                      await ap.userSignOut().then(
                        (value) async {
                          await ImageSingleton.deleteLocalImage().then(
                            (value) => Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) {
                                  return const WelcomeScreen();
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ProfilePicScreen()));
            },
            child: SizedBox(
              height: 150,
              child: Hero(
                  tag: "profile_pic",
                  child: Container(
                    decoration: ShapeDecoration(
                      shape: const CircleBorder(),
                      color: Colors.red,
                      image: DecorationImage(
                        fit: BoxFit.contain,
                        image: FileImage(ImageSingleton.getLocalImage()!),
                      ),
                    ),
                  )),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(UserModel.instance.name),
          Text(
            UserModel.instance.email,
            style: TextStyle(color: AppColors.dimBlack),
          ),
          Text(UserModel.instance.bio),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => const UserInfoScreen(
                    editProfile: true,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              foregroundColor: Colors.white,
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              side: BorderSide(
                width: 1,
                color: AppColors.deepGreen,
              ),
            ),
            child: Text(
              "Edit Profile",
              style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 15,
                  color: AppColors.deepGreen),
            ),
          ),
        ],
      ),
    ));
  }

  Widget myBody() {
    return Container(
      width: MediaQuery.of(context).size.width,
      // height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ), // Adjust the value for roundness
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.blue_6,
            backgroundImage: const AssetImage("assets/images/profile_icon.png"),
            foregroundImage: NetworkImage(UserModel.instance.profilePic),
            radius: 50,
          ),
          const SizedBox(
            height: 40,
          ),
          Text(UserModel.instance.name),
          Text(UserModel.instance.email),
          Text(UserModel.instance.bio),
          Text(UserModel.instance.phoneNumber),
        ],
      ),
    );
  }
}
