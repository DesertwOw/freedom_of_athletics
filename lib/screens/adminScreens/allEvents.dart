import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/services/DataController.dart';
import 'package:freedom_of_athletics/widgets/custom_app_bar.dart';
import 'package:freedom_of_athletics/widgets/eventWidgets/events_feed_widget.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../widgets/selectors/admin_selector_for_adding_users_to_events.dart';
import '../../widgets/selectors/admin_selector_for_removing_participants_from_events.dart';

class allEvents extends StatefulWidget {

  @override
  State<allEvents> createState() => _allEventsState();
}

class _allEventsState extends State<allEvents> {
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
              const SizedBox(child: Center(child: Text('Manage the events below',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)))),
              const SizedBox(height: 20,),
              Flexible(
                  child:Obx(() {
                    if (dataController.isEventsLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {

                      return ListView.builder(
                        shrinkWrap: true,
                        itemBuilder: (ctx, i) {
                          return
                              eventItem(dataController.allEvents[i]);
                        },
                        itemCount: dataController.allEvents.length,
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
