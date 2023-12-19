import 'dart:developer';

import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/screens/profile_module_screens/my_transactions.dart';
import 'package:cashxchange/screens/profile_module_screens/profile_pic_screen.dart';
import 'package:cashxchange/screens/profile_module_screens/user_info_fill.dart';
import 'package:cashxchange/screens/auth_module_screens/welcome_screen.dart';
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
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 50),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.deepGreen,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Profile",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepGreen,
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  SizedBox(
                    width: 40,
                    child: IconButton(
                      icon: Icon(
                        Icons.logout,
                        size: 25,
                        color: AppColors.deepGreen,
                      ),
                      onPressed: () {
                        ap.updateUserActiveStatus(false).then(
                          (value) async {
                            final data = await ap.getUserDataById(
                                uid: UserModel.instance.uid);
                            log("isOnline: ${data['isOnline']}");
                            ap.userSignOut().then((value) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const WelcomeScreen()),
                                (route) => false,
                              );
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Stack(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.90,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.81,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadiusDirectional.vertical(
                            top: Radius.circular(40)),
                        color: Colors.white,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.white, AppColors.lightMintGreen],
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 100,
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
                              maximumSize: const Size(150, 40),
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Edit Profile",
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 15,
                                      color: AppColors.deepGreen),
                                ),
                                Icon(
                                  Icons.edit,
                                  color: AppColors.deepGreen,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          const Divider(),
                          ListTile(
                            onTap: () {
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) =>
                                      const MyTransactionsScreen(),
                                ),
                              );
                            },
                            leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  color: AppColors.deepGreen,
                                  child: const Icon(
                                    Icons.history,
                                    color: Colors.white,
                                  ),
                                )),
                            title: const Text("My Transactions"),
                            trailing: const Icon(Icons.arrow_forward_ios),
                          ),
                          const Divider(),
                          const ListTile(
                            title: Text("First list tile"),
                          ),
                          const Divider(),
                          const ListTile(
                            title: Text("First list tile"),
                          ),
                          const Divider(),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ImageFullScreen(
                              url: UserModel.instance.profilePic,
                            )));
                  },
                  child: SizedBox(
                    height: 150,
                    child: Hero(
                        tag: "hero_image",
                        child: Container(
                          decoration: ShapeDecoration(
                            shape: const CircleBorder(),
                            color: Colors.black,
                            image: DecorationImage(
                              fit: BoxFit.contain,
                              // image: FileImage(ImageSingleton.getLocalImage()!),
                              image:
                                  NetworkImage(UserModel.instance.profilePic),
                            ),
                          ),
                        )),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
