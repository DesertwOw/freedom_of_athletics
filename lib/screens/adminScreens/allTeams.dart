import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/widgets/custom_app_bar.dart';
import 'package:freedom_of_athletics/widgets/eventWidgets/events_feed_widget.dart';
import 'package:freedom_of_athletics/widgets/teamWidgets/teams_feed_widget.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../services/DataController.dart';
import '../../widgets/selectors/AdminSelectorForAddingMembersToTeams.dart';
import '../../widgets/selectors/AdminSelectorForRemovingMembersFromTeams.dart';

class allTeams extends StatefulWidget {


  @override
  State<allTeams> createState() => _allTeamsState();
}

class _allTeamsState extends State<allTeams> {
  DataController dataController = Get.find<DataController>();

  @override
  Widget build(BuildContext context) {
    DocumentSnapshot user = dataController.allUsers.firstWhere((e) => FirebaseAuth.instance.currentUser!.uid == e.id);
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
              WelcomeUser(user, user.get('firstname'), 'Have a successful developing', user.get('profilePicture')),
              const SizedBox(height: 25,),
              const SizedBox(child: Center(child: Text('Manage the teams below',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)))),
              const SizedBox(height: 20,),
              Flexible(
                child:Obx(() {
                  if (dataController.isTeamsLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {

                    return ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (ctx, i) {
                        return
                          teamItem(dataController.allTeams[i]);
                      },
                      itemCount: dataController.allTeams.length,
                    );
                  }
                }),
              )
            ],

          ),
        ),
      )
    );
  }
}
