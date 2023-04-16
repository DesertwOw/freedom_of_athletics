import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/services/DataController.dart';
import 'package:freedom_of_athletics/services/auth_helper.dart';
import 'package:freedom_of_athletics/widgets/custom_app_bar.dart';
import 'package:get/get.dart';

import '../../widgets/eventWidgets/events_feed_widget.dart';

class EventsCreatedByMe extends StatefulWidget {
  const EventsCreatedByMe({Key? key}) : super(key: key);

  @override
  State<EventsCreatedByMe> createState() => _EventsCreatedByMeState();
}

class _EventsCreatedByMeState extends State<EventsCreatedByMe> {
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customAppBar(),
                SizedBox(
                  height: 20,
                ),
                const Text(
                  "Your events:",
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  height: Get.height * 0.02,
                ),
                Obx(() => dataController.isEventsLoading.value
                    ? const Center(
                  child: CircularProgressIndicator(),
                )
                    : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (ctx, i) {
                      if(dataController.allEvents[i].get('uid') == FirebaseAuth.instance.currentUser!.uid){
                        return eventItem(dataController.allEvents[i]);
                      }
                        return Container();
                    },
                    itemCount: dataController.allEvents.length
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}