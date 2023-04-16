import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/screens/adminScreens/user_profile_for_admin.dart';
import 'package:freedom_of_athletics/services/auth_helper.dart';
import 'package:freedom_of_athletics/widgets/eventWidgets/events_feed_widget.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';

import '../../services/DataController.dart';
import '../../widgets/custom_app_bar.dart';

class allUsers extends StatefulWidget {

  @override
  State<allUsers> createState() => _allUsersState();
}

class _allUsersState extends State<allUsers> {
  DataController dataController = Get.find<DataController>();

  @override
  Widget build(BuildContext context) {
    DocumentSnapshot user =
    dataController.allUsers.firstWhere((e) => FirebaseAuth.instance.currentUser!.uid == e.id);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: double.infinity,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              customAppBar(),
              WelcomeUser(user, user.get('firstname'),'Have a succesful developing', user.get('profilePicture')),
              SizedBox(height: 25,),
              const SizedBox(child: Center(child: Text('Manage the users below',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),)),),
              SizedBox(height: 20,),
              Flexible(
                child: Obx(() {
                  if (dataController.isUsersLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {

                    List filteredUsers = dataController.allUsers.where((user) => user.get('uid') != FirebaseAuth.instance.currentUser!.uid).toList();

                    return ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (ctx, i) {
                        return ListTile(
                          title: Text(filteredUsers[i].get('firstname')),
                          leading: GestureDetector(
                            onTap: () => {
                              Get.to(() => UserProfileForAdmin(filteredUsers[i]))
                            },
                            child: CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(filteredUsers[i].get('profilePicture')),
                            ),
                          ),
                          trailing: GestureDetector(
                              child: Icon(Iconsax.profile_delete),
                              onTap: () async {
                                try {
                                  await UserHelper.deleteUserAccount(filteredUsers[i].get('uid'));
                                } catch (e) {
                                 e.printError();
                                }
                              }
                          ),
                        );
                      },
                      itemCount: filteredUsers.length,
                    );
                  }
                }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
