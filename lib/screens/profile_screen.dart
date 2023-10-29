import 'package:cashxchange/constants/color_constants.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/screens/welcome_screen.dart';
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
      appBar: AppBar(
        backgroundColor: blue_10,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () async {
              await ap.userSignOut().then(
                    (value) => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return const WelcomeScreen();
                        },
                      ),
                    ),
                  );
            },
          ),
        ],
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            CircleAvatar(
              backgroundColor: blue_6,
              backgroundImage:
                  const AssetImage("assets/images/profile_icon.png"),
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
      ),
    );
  }
}
