import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/widgets/teamWidgets/teams_feed_widget.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../services/auth_helper.dart';
import '../../widgets/custom_app_bar.dart';

class myTeam extends StatefulWidget {
  const myTeam({Key? key}) : super(key: key);

  @override
  State<myTeam> createState() => _myTeamState();
}

class _myTeamState extends State<myTeam> {
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
                  "Your teams:",
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  height: Get.height * 0.02,
                ),
                FutureBuilder<List<QueryDocumentSnapshot>>(
                  future: UserHelper.getTeamsWhereITakePart(),
                  builder: (BuildContext context, AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text('Error retrieving teams.'),
                      );
                    } else {
                      List<QueryDocumentSnapshot> filteredTeams = snapshot.data!;

                      return filteredTeams.isEmpty
                          ? const Center(
                        child: Text('No teams found.'),
                      )
                          : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (ctx, i) {
                          return teamItem(filteredTeams[i]);
                        },
                        itemCount: filteredTeams.length,
                      );
                    }
                  },
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}

