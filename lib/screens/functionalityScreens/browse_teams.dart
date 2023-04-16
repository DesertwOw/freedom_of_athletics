import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/services/DataController.dart';
import 'package:freedom_of_athletics/widgets/teamWidgets/teams_feed_widget.dart';
import 'package:get/get.dart';

import '../../widgets/custom_app_bar.dart';
import '../../widgets/eventWidgets/events_feed_widget.dart';

class BrowseTeams extends StatefulWidget {
  DocumentSnapshot? teamData;
  @override
  State<BrowseTeams> createState() => _BrowseTeamsState();
}

class _BrowseTeamsState extends State<BrowseTeams> {
  DataController dataController = Get.find<DataController>();
  String name = "";

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
                const SizedBox(
                  height: 6,
                ),
                SizedBox(
                  height: 6,
                ),
                TextField(
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search), hintText: 'Search...'),
                  onChanged: (val) {
                    setState(() {
                      name = val;
                    });
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                const Text(
                  "Available Teams:",
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  height: Get.height * 0.02,
                ),
                SizedBox(
                  child: Obx(() {
                    if (dataController.isTeamsLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      List<dynamic> filteredTeams = dataController.allTeams.where((team) => team['uid'] != FirebaseAuth.instance.currentUser!.uid).toList();
                      if (name.isNotEmpty) {
                        filteredTeams = filteredTeams.where((team) {
                          String teamName = team
                              .get('team_name')
                              .toString()
                              .toLowerCase();
                          return teamName.contains(name.toLowerCase());
                        }).toList();
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (ctx, i) {
                          return teamItem(filteredTeams[i]);
                        },
                        itemCount: filteredTeams.length,
                      );
                    }
                  }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

}
