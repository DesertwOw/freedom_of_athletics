import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/services/auth_helper.dart';
import 'package:freedom_of_athletics/widgets/custom_app_bar.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';

import '../../services/DataController.dart';
import '../../services/fcm_handler.dart';
import '../profileScreens/event_creator_profile.dart';

class Recruitment extends StatefulWidget {
  const Recruitment({Key? key}) : super(key: key);

  @override
  State<Recruitment> createState() => _RecruitmentState();
}

class _RecruitmentState extends State<Recruitment> {
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
              customAppBar(),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Find the missing piece for your event/team',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),)
                ],
              ),
              SizedBox(height: 30,),
              Expanded(
                child: Obx(
                      () => dataController.isUsersLoading.value
                      ? const Center(
                    child: CircularProgressIndicator(),
                  )
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (ctx, i) {
                      var senderName = dataController.myDocument?.get('firstname');
                      var notifierToken = dataController.allUsers[i].get('fcmToken');
                      final currentUser = dataController.myDocument?.get('uid');
                      final user = dataController.allUsers[i];
                      if (currentUser == user.get('uid')) {
                        return SizedBox.shrink();
                      }
                      return Column(
                        children: [
                          InkWell(
                            onTap: () async {
                              Get.to(() => EventCreatorProfile(user));
                            },
                            child: ListTile(
                              onTap: () {
                                Get.to(() => EventCreatorProfile(user));
                              },
                              title: Text(
                                user.get('firstname'),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                ),
                              ),
                              subtitle: Text(
                                user.get('age').toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              leading: GestureDetector(
                                child:  CircleAvatar(
                      backgroundImage: NetworkImage(
                      dataController.allUsers[i].get('profilePicture')),
                                ),
                              ),
                              trailing: GestureDetector(
                                child: Icon(
                                  Iconsax.add,
                                  color: Colors.black,
                                ),
                                onTap: () => {
                                UserHelper.setTheRequestToASubcollection(
                                dataController.myDocument?. get ('firstname'),
                                dataController.myDocument?. get ('uid'),
                                dataController.myDocument?. get ('fcmToken'),
                                dataController.myDocument?. get ('profilePicture'),
                                dataController.allUsers[i]. get ('uid'),
                                dataController.allUsers[i]. get ('firstname'),
                                dataController.allUsers[i]. get ('fcmToken'),
                                dataController.allUsers[i]. get ('profilePicture')
                                ),
                                LocalNotificationService.sendNotification(
                                'You have a new Friend Request',
                                '$senderName wants to be your friend',
                                notifierToken,
                                )
                              }
                              ),
                            ),
                          ),
                          SizedBox(height: 10), // Add some spacing here
                        ],
                      );
                    },
                    itemCount: dataController.allUsers.length,
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
