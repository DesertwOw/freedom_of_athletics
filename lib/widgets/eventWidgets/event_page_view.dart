
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freedom_of_athletics/screens/profileScreens/event_creator_profile.dart';
import 'package:freedom_of_athletics/services/DataController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/services/auth_helper.dart';
import 'package:freedom_of_athletics/services/fcm_handler.dart';
import 'package:freedom_of_athletics/widgets/clipper.dart';
import 'package:freedom_of_athletics/widgets/selectors/friend_selector_checkbox_widget.dart';
import 'package:freedom_of_athletics/widgets/selectors/team_selector_checkbox_widget.dart';
import 'package:get/get.dart';

class EventPageView extends StatefulWidget {
  DocumentSnapshot eventData, user;

  EventPageView(this.eventData, this.user);

  @override
  _EventPageViewState createState() => _EventPageViewState();
}

class _EventPageViewState extends State<EventPageView> {
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
                    ),
                  ),
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${widget.eventData.get('event_name')}",
                  style: const TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(height: 15,),
        FutureBuilder<bool>(
          future: UserHelper.isEventFull(widget.eventData.get('maximum_players'), widget.eventData.id),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasData) {
              if (snapshot.data!) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Tele van',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 28,color: Colors.white),)
                   ]
                );
              } else {

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FutureBuilder<bool>(
                        future: UserHelper.isUserDocumentExists(FirebaseAuth.instance.currentUser!.uid, 'users', 'participatingInEvents', 'Uid', FirebaseAuth.instance.currentUser!.uid),
                        builder: (BuildContext context,AsyncSnapshot<bool> snapshot){
                          if(snapshot.connectionState == ConnectionState.waiting){
                            return CircularProgressIndicator();
                          } else if (snapshot.hasData){
                            if(snapshot.data!){
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
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(13)),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10
                                ),
                                child: const Center(
                                  child: Text(
                                    'Joined',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black
                                    ),
                                  ),
                                ),
                              );
                            }else {
                              return TextButton(onPressed: () => showDialog(
                                  context: context,
                                  builder: (context) {
                                    return TeamSelectorCheckboxWidget(selectedTeams);
                                  }
                              ),
                                child:  Container(
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
                                            color: Colors.black
                                        ),
                                      ),
                                    )
                                ),);

                            }
                          } else {
                            return Text('Error: ${snapshot.error}');
                          }
                        },

                    ),
                    FutureBuilder<bool>(
                        future: UserHelper.isUserDocumentExists(FirebaseAuth.instance.currentUser!.uid, 'users', 'participatingInEvents', 'Uid', FirebaseAuth.instance.currentUser!.uid),
                        builder: (BuildContext context, AsyncSnapshot snapshot){
                          if(snapshot.connectionState == ConnectionState.waiting){
                            return CircularProgressIndicator();
                          }else if(snapshot.hasData){
                            if(snapshot.data!){
                              return InkWell(
                                onTap: () async{
                                  UserHelper.LeaveEvent(widget.eventData.id, FirebaseAuth.instance.currentUser!.uid);
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
                                        borderRadius: BorderRadius.circular(13)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    child: const Center(
                                      child: Text(
                                        'Leave the Event',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black
                                        ),
                                      ),
                                    )
                                ),
                              );
                            }else {
                              return InkWell(
                                onTap: () async {
                                  var senderName = dataController.myDocument?.get('firstname');
                                  final QuerySnapshot result = await FirebaseFirestore.instance
                                      .collection('users')
                                      .where('uid', isEqualTo: widget.eventData.get('uid'))
                                      .limit(1)
                                      .get();
                                  final DocumentSnapshot doc = result.docs.first;
                                  String eventCreatorToken = doc.get('fcmToken');
                                  String eventCreatorUid = doc.get('uid');
                                  UserHelper.JoiningRequestToAnEvent(dataController.myDocument?.get('fcmToken'),FirebaseAuth.instance.currentUser!.uid,eventCreatorUid, widget.eventData.id, widget.eventData.get('uid'), widget.eventData.get('event_name'), eventImage, dataController.myDocument?.get('firstname'), eventCreatorToken, dataController.myDocument?.get('profilePicture'));
                                  LocalNotificationService.sendNotification('New joining Request', '$senderName wants to join your event', eventCreatorToken);
                                },
                                child:  Container(
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
                                        'Join',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black
                                        ),
                                      ),
                                    )
                                ),);
                            }
                          }else{
                            return Text('Error: ${snapshot.error}');
                          }
                        }

                    ),
                    TextButton(onPressed: () => showDialog(
                        context: context,
                        builder: (context) {
                          return FriendSelectorCheckboxWidget(selectedFriends,widget.eventData);
                        }
                    ),
                      child:  Container(
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
                                  color: Colors.black
                              ),
                            ),
                          )
                      ),),
                  ],

                );
              }
            } else {
              return Container();
            }
          },
        ),
    Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 100,
                  width: 150,
                  child:FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    future: widget.eventData.reference.collection("participants").get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      } else {
                        List<DocumentSnapshot<Map<String, dynamic>>> participants = snapshot.data!.docs;
                        return ListView.builder(
                          itemBuilder: (ctx, i) {
                            DocumentSnapshot<Map<String, dynamic>> participant = participants[i];
                            return Align(
                              child: InkWell(
                                onTap: () {
                                  Get.to(() => EventCreatorProfile(participant));
                                },
                                child: CircleAvatar(backgroundImage: NetworkImage(participant.get('profilePicture')),),
                              ),
                            );
                          },
                          itemCount: participants.length,
                          scrollDirection: Axis.horizontal,
                        );
                      }
                    },
                  )
                )

              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Text(
                    "${widget.eventData.get('description')}",
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                )
              ],
            ),
          ],
        )));
  }
}
