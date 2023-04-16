import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/services/DataController.dart';
import 'package:freedom_of_athletics/services/auth_helper.dart';
import 'package:freedom_of_athletics/widgets/custom_app_bar.dart';
import 'package:get/get.dart';

import '../../widgets/eventWidgets/events_feed_widget.dart';

class MyEvents extends StatefulWidget {
  const MyEvents({Key? key}) : super(key: key);

  @override
  State<MyEvents> createState() => _MyEventsState();
}

class _MyEventsState extends State<MyEvents> {



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
            FutureBuilder<List<QueryDocumentSnapshot>>(
              future: UserHelper.getEventsWhereITakePart(),
              builder: (BuildContext context, AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error retrieving events.'),
                  );
                } else {
                  List<dynamic> filteredEvents = snapshot.data!;

                  return filteredEvents.isEmpty
                      ? const Center(
                    child: Text('No events found.'),
                  )
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (ctx, i) {
                      return eventItem(filteredEvents[i]);
                    },
                    itemCount: filteredEvents.length,
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