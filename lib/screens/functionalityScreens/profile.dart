import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/screens/profileScreens/Invitations.dart';
import 'package:freedom_of_athletics/screens/profileScreens/manage_friends.dart';
import 'package:freedom_of_athletics/screens/profileScreens/my_account.dart';
import 'package:freedom_of_athletics/utils/color_utils.dart';
import 'package:freedom_of_athletics/widgets/profile_page_view.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../services/DataController.dart';
import '../../widgets/custom_app_bar.dart';

class Profile extends StatefulWidget {
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  DataController dataController = Get.find<DataController>();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                height: double.infinity,
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      customAppBar(),
                      SizedBox(height: 60, child: ProfPic()),
                      const SizedBox(
                        height: 20,
                      ),
                      ProfileMenuItem(
                        icon: "assets/user.svg",
                        text: "My Account",
                        press: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => (MyAccount()),
                              ));
                        },
                      ),
                      ProfileMenuItem(
                        icon: "assets/user.svg",
                        text: "Friends",
                        press: () async {
                          DocumentSnapshot user = dataController.allUsers
                              .firstWhere((e) =>
                          e.id ==
                              FirebaseAuth.instance.currentUser?.uid);

                          Get.to(() => ManageFriends(user));
                        },
                      ),
                      ProfileMenuItem(
                        icon: "assets/user.svg",
                        text: "Invitations",
                        press: () async {
                          DocumentSnapshot user = dataController.allUsers
                              .firstWhere((e) =>
                                  e.id ==
                                  FirebaseAuth.instance.currentUser?.uid);

                          Get.to(() => Invitations(user));
                        },
                      )
                    ],
                  ),
                ))));
  }
}
