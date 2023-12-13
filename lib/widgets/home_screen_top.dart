import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/screens/request_module_screens/active_requests_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreenTopSection extends StatelessWidget {
  const HomeScreenTopSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 130,
          decoration: BoxDecoration(
              gradient: LinearGradient(stops: const [
            0.2,
            1.0
          ], colors: [
            AppColors.skyBlue,
            Colors.white,
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              const SizedBox(
                height: 55,
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed('profile_screen');
                    },
                    child: Hero(
                      tag: 'hero_image',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: CircleAvatar(
                          backgroundColor: AppColors.deepGreen,
                          radius: 25,
                          child: Center(
                            child: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(UserModel.instance.profilePic),
                              // FileImage(ImageSingleton.getLocalImage()!),
                              radius: 23,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    alignment: Alignment.centerLeft,
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Hero(
                      tag: 'app_logo',
                      child: Image.asset("assets/images/app_logo.png"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Stack(
          children: [
            Container(
              color: Colors.white,
              height: 110,
            ),
            Positioned(
              bottom: 0,
              child: Container(
                height: 70,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: AppColors.mintGreen,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(40),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 34,
              right: 44,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(CupertinoPageRoute(
                          builder: (context) => const RequestStatusScreen(),
                        ));
                      },
                      child: Container(
                        height: 60,
                        width: MediaQuery.of(context).size.width * 0.55,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: AppColors.deepGreen,
                            border: Border.all(color: Colors.white, width: 2)),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.request_page,
                              color: Colors.white,
                              size: 25,
                            ),
                            SizedBox(
                              width: 7,
                            ),
                            Text(
                              'Request Status',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(child: SizedBox()),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('notification_screen');
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 32,
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.deepGreen,
                          child: const Icon(
                            Icons.notifications,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
