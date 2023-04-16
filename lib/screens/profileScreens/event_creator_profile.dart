import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freedom_of_athletics/screens/functionalityScreens/browse_teams.dart';
import 'package:freedom_of_athletics/screens/functionalityScreens/profile_event_widget.dart';
import 'package:freedom_of_athletics/screens/functionalityScreens/sport_team_selection.dart';
import 'package:freedom_of_athletics/services/DataController.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/services/auth_helper.dart';
import 'package:freedom_of_athletics/widgets/custom_app_bar.dart';
import 'package:freedom_of_athletics/widgets/reusable_widget.dart';
import 'package:get/get.dart';

import '../../services/fcm_handler.dart';
import '../../widgets/eventWidgets/events_feed_widget.dart';

class EventCreatorProfile extends StatefulWidget {
  DocumentSnapshot user;

  EventCreatorProfile(this.user);

  @override
  State<EventCreatorProfile> createState() => _EventCreatorProfileState();
}

class _EventCreatorProfileState extends State<EventCreatorProfile> {
  DataController dataController = Get.find<DataController>();

  @override
  Widget build(BuildContext context) {
    String image = '';

    try {
      image = widget.user.get('profilePicture');
    } catch (e) {
      image = '';
    }

    String? name = widget.user.get('firstname');


    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 50, bottom: 20),
                  width: 30,
                  height: 30,
                ),
              ),
              customAppBar(),
              Center(
                child: CircleAvatar(
                  backgroundImage: NetworkImage(image),
                  radius: 100,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: Text(
                  name!,
                  style: const TextStyle(
                      fontSize: 25,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  FutureBuilder<bool>(
                    future: UserHelper.isUserDocumentExists(
                        FirebaseAuth.instance.currentUser!.uid,
                        'users',
                        'friends',
                        'Uid',
                        widget.user.id),
                    builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
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
                            padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            child: const Center(
                              child: Text(
                                'You are already friends',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black),
                              ),
                            ),
                          );
                        } else {
                          if (FirebaseAuth.instance.currentUser!.uid == widget.user.id) {
                            return Container();
                          }
                          return InkWell(
                            onTap: () async {
                              var senderUid = FirebaseAuth.instance.currentUser!.uid;
                              var senderName = dataController.myDocument?.get('firstname');
                              var senderToken = dataController.myDocument?.get('fcmToken');
                              var senderProfilePicture =
                              dataController.myDocument?.get('profilePicture');
                              var notifierToken = widget.user.get('fcmToken');
                              UserHelper.setTheRequestToASubcollection(
                                senderName,
                                senderUid,
                                senderToken,
                                senderProfilePicture,
                                widget.user.id,
                                widget.user.get('firstname'),
                                notifierToken,
                                widget.user.get('profilePicture'),
                              );
                              LocalNotificationService.sendNotification(
                                'You have a new Friend Request',
                                '$senderName wants to be your friend',
                                notifierToken,
                              );
                            },
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
                                borderRadius: BorderRadius.circular(13),
                              ),
                              padding:
                              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              child: const Center(
                                child: Text(
                                  'Add as a Friend',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      } else {
                        return Text('Error: ${snapshot.error}');
                      }
                    },
                  ),
                  FutureBuilder<bool>(
                    future: UserHelper.isUserDocumentExists(widget.user.id, 'users', 'memberToATeam', 'Uid', widget.user.id),
                    builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasData) {
                        if (snapshot.data!) {
                          if(FirebaseAuth.instance.currentUser!.uid == widget.user.id){
                            return GestureDetector(
                              onTap: (){
                                Get.to(() => SportTeamSelection());
                              },
                              child: Center(
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
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  child: const Center(
                                    child: Text(
                                      'Create a team',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
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
                                borderRadius: BorderRadius.circular(13),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: const Center(
                                child: Text(
                                  'Already invited',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            );
                          }
                        } else {

                          return InkWell(
                            onTap: () {
                              var senderUid = FirebaseAuth.instance.currentUser!.uid;
                              var senderName =
                              dataController.myDocument?.get('firstname');
                              var senderToken =
                              dataController.myDocument?.get('fcmToken');
                              var notifierToken = widget.user.get('fcmToken');
                              String currentUserID =
                                  FirebaseAuth.instance.currentUser!.uid;
                              Query query = FirebaseFirestore.instance
                                  .collection('teams')
                                  .where('uid', isEqualTo: currentUserID);
                              query.get().then((querySnapshot) {
                                DocumentSnapshot documentSnapshot =
                                    querySnapshot.docs.first;
                                String documentId = documentSnapshot.id;
                                String documentName = documentSnapshot.get('team_name');
                                String documentPicture = documentSnapshot.get('badge');
                                UserHelper.setTheTeamMemberRequestToASubcollection(
                                    senderUid,
                                    senderToken,
                                    widget.user.get('uid'),
                                    widget.user.get('firstname'),
                                    notifierToken,
                                    documentPicture,
                                    documentName,
                                    documentId);
                              });
                              LocalNotificationService.sendNotification(
                                  'You have a new Team Invitation',
                                  '$senderName wants to invite to their team',
                                  notifierToken);

                            },
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
                                borderRadius: BorderRadius.circular(13),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              child: const Center(
                                child: Text(
                                  'Invite to my team',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      }
                      return Container();
                    },
                  ),

                ],
              ),
              SizedBox(
                height: 25,
              ),
        Center(child: Text('$name is participating these events below',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),)),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FutureBuilder<List<QueryDocumentSnapshot>>(
              future: UserHelper.getEventsWhereTheUserTakesPart(widget.user.id),
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
                      : Expanded(
                    child: Container(
                      height: 300,
                      child: ListView.builder(
                        itemBuilder: (ctx, i) {
                          return eventProfileItem(filteredEvents[i]);
                        },
                        itemCount: filteredEvents.length,
                        scrollDirection: Axis.horizontal,
                      ),
                    ),
                  );
                }
              },
            )
          ],
        )
        ],
          ),
        ),
      ),
    );
  }
}
