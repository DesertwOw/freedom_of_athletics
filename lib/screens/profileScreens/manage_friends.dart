import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/services/auth_helper.dart';
import 'package:freedom_of_athletics/widgets/friends_and_teammates_widget.dart';
import 'package:freedom_of_athletics/widgets/reusable_widget.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:iconsax/iconsax.dart';

import '../../services/DataController.dart';
import '../../services/fcm_handler.dart';
import '../../widgets/custom_app_bar.dart';
import 'event_creator_profile.dart';

class ManageFriends extends StatefulWidget {
  DocumentSnapshot user;

  ManageFriends(this.user);

  @override
  State<ManageFriends> createState() => _ManageFriendsState();
}

class _ManageFriendsState extends State<ManageFriends> {
  DataController dataController = Get.find<DataController>();
  @override
  Widget build(BuildContext context) {
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
              SizedBox(height: 10,),
              customAppBar(),
              Center(child: Text('Manage your friends below',style: TextStyle(fontSize: 20,color: Colors.black),)),
              SizedBox(height: 20,),
              Expanded(
                child: Obx(
                  () => dataController.isFriendsLoading.value
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (ctx, i) {
                            final user = dataController.filteredFriends[i];
                            return Column(
                              children: [
                                InkWell(
                                  child: ListTile(
                                    onTap: () {
                                      Get.to(() => EventCreatorProfile(user));
                                    },
                                    title: Text(
                                      user.get('firstname'),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                      ),
                                    ),
                                    leading: GestureDetector(
                                      child: CircleAvatar(
                                        radius: 16,
                                        backgroundImage: NetworkImage(
                                            dataController.allFriends[i]
                                                .get('profilePicture')),
                                      ),
                                    ),
                                    trailing: GestureDetector(
                                      child: Icon(
                                        Iconsax.profile_delete,
                                        color: Colors.black,
                                      ),
                                      onTap: () async{
                                        UserHelper.DeleteFriend(dataController.myDocument?.get('uid'), dataController.allFriends[i].get('Uid'));
                                      }
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            );
                          },
                          itemCount: dataController.allFriends.length,
                          scrollDirection: Axis.vertical,
                        ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
