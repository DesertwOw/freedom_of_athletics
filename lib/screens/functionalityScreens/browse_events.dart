import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freedom_of_athletics/models/dateFormatter.dart';
import 'package:freedom_of_athletics/services/DataController.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/services/auth_helper.dart';
import 'package:get/get.dart';

import '../../widgets/custom_app_bar.dart';
import '../../widgets/eventWidgets/events_feed_widget.dart';
import '../../widgets/reusable_widget.dart';

class BrowseEvents extends StatefulWidget {
  @override
  _BrowseEventsState createState() => _BrowseEventsState();
}

class _BrowseEventsState extends State<BrowseEvents> {
  String name = "";
  DataController dataController = Get.find<DataController>();
  var selectedValue;

  @override
  void initState() {
    super.initState();
    Get.put(DataController());
  }

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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customAppBar(),
              WelcomeUser(user,
                  user.get('firstname'),'Lets explore whats happening today' ,user.get('profilePicture')),
                  const SizedBox(
                    height: 6,
                  ),
                  DatePicker(
                    DateTime.now(),
                    initialSelectedDate: DateTime.now(),
                    selectionColor: Colors.blueAccent,
                    selectedTextColor: Colors.white,
                    onDateChange: (date) {
                      setState(() {
                        String stringDate = date.toString();
                        selectedValue = formatDate(stringDate);
                      });
                    },
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
                    "Available events:",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(
                    height: Get.height * 0.02,
                  ),
                  SizedBox(
                    child: Obx(() {
                      if (dataController.isEventsLoading.value) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        List<dynamic> filteredEvents = dataController.allEvents;

                        if (selectedValue != DateTime.now().day) {
                          filteredEvents = filteredEvents.where((event) {
                            String filterDay =
                                (event.get('date'));
                            return filterDay.padLeft(2,'0') == selectedValue;
                          }).toList();
                        }

                        if (name.isNotEmpty) {
                          filteredEvents = filteredEvents.where((event) {
                            String eventName = event
                                .get('event_name')
                                .toString()
                                .toLowerCase();
                            return eventName.contains(name.toLowerCase());
                          }).toList();
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (ctx, i) {
                            return eventItem(filteredEvents[i]);
                          },
                          itemCount: filteredEvents.length,
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
