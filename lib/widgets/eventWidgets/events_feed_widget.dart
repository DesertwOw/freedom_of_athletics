import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freedom_of_athletics/screens/adminScreens/event_view_for_admin.dart';
import 'package:freedom_of_athletics/screens/profileScreens/event_creator_profile.dart';
import 'package:freedom_of_athletics/services/DataController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:freedom_of_athletics/widgets/eventWidgets/event_page_view.dart';

import 'event_page_view_for_organizers.dart';

Widget WelcomeUser(DocumentSnapshot user, text, greetText, String image) {
  return Row(
    children: <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Greetings $text!',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 21,
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Text(
            '$greetText',
            style: TextStyle(color: Colors.black, fontSize: 15),
          )
        ],
      ),
      const Spacer(),
      Row(
        children: [
          InkWell(
              onTap: () {
                Get.to(() => EventCreatorProfile(user));
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(image),
              )),
        ],
      )
    ],
  );
}

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
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22.0),
              shadowColor: Colors.black87,
              elevation: 20.0,
              child: Column(
                children: [
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
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: <Widget>[
                        Text(
                          eventData!.get('event_name').toString(),
                          style: TextStyle(fontSize: 18),
                        ),
                        Spacer(),
                        Text(
                          eventData.get('date').toString(),
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('events')
                            .doc(eventData.id)
                            .collection('participants')
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            int size = snapshot.data!.size;
                            return Row(
                              children: [
                                Text('Résztvevők száma az eseményen: '),
                                RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: size.toString(),
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      TextSpan(
                                        text: '/',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      TextSpan(
                                        text: eventData
                                            .get('maximum_players')
                                            .toString(),
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return CircularProgressIndicator();
                          }
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      Column(children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 300),
          height: 250,
          width: 400,
          child: Container(
            width: Get.width,
            height: 50,
            padding: EdgeInsets.only(left: 45),
          ),
        ),
      ]),
    ],
  );
}

eventItem(DocumentSnapshot event) {
    DataController dataController = Get.find<DataController>();

    DocumentSnapshot user =
        dataController.allUsers.firstWhere((e) => event.get('uid') == e.id);

  String image = '';

  try {
    image = user.get('profilePicture');
  } catch (e) {
    image = '';
  }

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
      Row(
        children: [
          InkWell(
            onTap: () {
              Get.to(() => EventCreatorProfile(user));
            },
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.blue,
              backgroundImage: NetworkImage(image),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Text(
            '${user.get('firstname')} ${user.get('lastname')}',
          ),
        ],
      ),
      SizedBox(
        height: Get.height * 0.01,
      ),
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
      const SizedBox(
        height: 45,
      ),
    ],
  );
}
