import 'package:cashxchange/model/user_model.dart';
import 'package:flutter/material.dart';

class ProfilePicScreen extends StatelessWidget {
  final bool isLocalImage;
  final String url;
  const ProfilePicScreen(
      {super.key, required this.isLocalImage, this.url = ""});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        color: Colors.black,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: isLocalImage
              ? Hero(
                  tag: "profile_pic",
                  child: Image.network(UserModel.instance.profilePic),
                )
              : Hero(
                  tag: "others_profile",
                  child: Image.network(url),
                ),
        ),
      ),
    );
  }
}
