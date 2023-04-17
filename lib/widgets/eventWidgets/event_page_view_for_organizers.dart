import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/services/DataController.dart';
import 'package:freedom_of_athletics/widgets/clipper.dart';
import 'package:freedom_of_athletics/widgets/selectors/team_selector_checkbox_widget.dart';
import 'package:freedom_of_athletics/widgets/eventWidgets/updateEventDialog.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';

import '../../screens/profileScreens/event_creator_profile.dart';
import '../../services/auth_helper.dart';
import '../selectors/friend_selector_checkbox_widget.dart';

class EventPageViewForOrganizers extends StatefulWidget {
  DocumentSnapshot eventData, user;

  EventPageViewForOrganizers(this.eventData, this.user);

  @override
  State<EventPageViewForOrganizers> createState() =>
      _EventPageViewForOrganizersState();
}

class _EventPageViewForOrganizersState
    extends State<EventPageViewForOrganizers> {
  DataController dataController = Get.find<DataController>();
  List<String> selectedTeams = [];
  List<String> selectedFriends = [];

  @override
  Widget build(BuildContext context) {
    String eventImage = '';
    try {
      List media = widget.eventData.get('media') as List;
      Map mediaItem = media.first as Map;
      eventImage = mediaItem['url'];
    } catch (e) {
      eventImage = '';
    }

    return Scaffold(
        backgroundColor: Colors.blueAccent,
        body: SingleChildScrollView(
          child: Column(
            children: [
              ClipPath(
                clipper: EventViewClipper(),
                child: Container(
                  height: MediaQuery.of(context).size.height * .60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(eventImage),
                        fit: BoxFit.cover,
                      )),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${widget.eventData.get('event_name')}",
                    style: const TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    child: Text('You created this event!'),
                  )
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FutureBuilder<bool>(
                    future: UserHelper.isUserDocumentExists(
                        FirebaseAuth.instance.currentUser!.uid,
                        'users',
                        'participatingInEvents',
                        'Uid',
                        FirebaseAuth.instance.currentUser!.uid),
                    builder:
                        (BuildContext context, AsyncSnapshot<bool> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasData) {
                        if (snapshot.data!) {
                          return Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.8),
                                      spreadRadius: 0.1,
                                      blurRadius: 60,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(13)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: const Center(
                                child: Text(
                                  'You are already joined',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black),
                                ),
                              ));
                        } else {
                          return TextButton(
                            onPressed: () => showDialog(
                                context: context,
                                builder: (context) {
                                  return TeamSelectorCheckboxWidget(
                                      selectedTeams);
                                }),
                            child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.8),
                                        spreadRadius: 0.1,
                                        blurRadius: 60,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(13)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                child: const Center(
                                  child: Text(
                                    'Join with Team',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black),
                                  ),
                                )),
                          );
                        }
                      } else {
                        return Text('Error: ${snapshot.error}');
                      }
                    },
                  ),
                  TextButton(
                    onPressed: () => showDialog(
                        context: context,
                        builder: (context) {
                          return FriendSelectorCheckboxWidget(
                              selectedFriends, widget.eventData);
                        }),
                    child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.8),
                                spreadRadius: 0.1,
                                blurRadius: 60,
                                offset: const Offset(0, 1),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(13)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: const Center(
                          child: Text(
                            'Invite Friends',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                        )),
                  ),
                ],
              ),
              SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 100,
                      width: 380,
                      child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        future: widget.eventData.reference
                            .collection("participants")
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text("Error: ${snapshot.error}"));
                          } else {
                            List<DocumentSnapshot<Map<String, dynamic>>>
                                participants = snapshot.data!.docs;
                            return ListView.builder(
                              itemBuilder: (ctx, i) {
                                DocumentSnapshot<Map<String, dynamic>>
                                    participant = participants[i];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Container(
                                    width: 100,
                                    height: 200,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 3,
                                              blurRadius: 10,
                                              offset: Offset(0, 3))
                                        ]),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Expanded(
                                        child: Column(
                                          children: [
                                            CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  participant
                                                      .get('profilePicture')),
                                            ),
                                            Text(
                                              participant.get('firstname'),
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                            GestureDetector(
                                              child: Icon(Iconsax.profile_delete),
                                              onTap: () {
                                                UserHelper.RemoveParticipant(
                                                    widget.eventData.id,
                                                    participant.get('Uid'));
                                              },
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              itemCount: participants.length,
                              scrollDirection: Axis.horizontal,
                            );
                          }
                        },
                      ))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return UpdateEventDialog(
                            eventDoc: widget.eventData.id,
                            description: widget.eventData.get('description'),
                            eventLocation: widget.eventData.get('location'),
                            eventName: widget.eventData.get('event_name'),
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blueAccent,
                      onPrimary: Colors.white,
                    ),
                    child: Text(
                      'Update your event info there!',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              )
            ],
          ),
        ));
  }
}
