import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../services/DataController.dart';
import '../../widgets/eventWidgets/event_page_view.dart';
import '../../widgets/eventWidgets/event_page_view_for_organizers.dart';
import '../adminScreens/event_view_for_admin.dart';

Widget buildCard({
  String? image,
  text,
  Function? func,
  DocumentSnapshot? eventData,
}) {
  return Stack(
    children: <Widget>[
      Column(
        children: <Widget>[
          Container(
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22.0),
              shadowColor: Colors.black87,
              elevation: 20.0,
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 150,
                      height: 30,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              eventData!.get('event_name').toString(),
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      func!();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(image!),
                          fit: BoxFit.fill,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      width: 350,
                      height: Get.width * 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

eventProfileItem(DocumentSnapshot event) {
  DataController dataController = Get.find<DataController>();

  DocumentSnapshot user =
  dataController.allUsers.firstWhere((e) => event.get('uid') == e.id);

  String eventImage = '';
  try {
    List media = event.get('media') as List;
    Map mediaItem = media.first as Map;
    eventImage = mediaItem['url'];
  } catch (e) {
    eventImage = '';
  }

  return Column(
    children: [
      buildCard(
          text: event.get('event_name'),
          eventData: event,
          image: eventImage,
          func: () {
            if (FirebaseAuth.instance.currentUser!.uid == event.get('uid')) {
              Get.to(() => EventPageViewForOrganizers(event, user));
            } else if (dataController.myDocument?.get('role') == 'admin') {
              Get.to(() => EventViewForAdmin(event));
            } else {
              Get.to(() => EventPageView(event, user));
            }
          }),
    ],
  );
}
