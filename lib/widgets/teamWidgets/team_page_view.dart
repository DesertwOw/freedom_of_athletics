import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/screens/profileScreens/event_creator_profile.dart';
import 'package:freedom_of_athletics/services/DataController.dart';
import 'package:freedom_of_athletics/services/auth_helper.dart';
import 'package:freedom_of_athletics/services/fcm_handler.dart';
import 'package:freedom_of_athletics/widgets/clipper.dart';
import 'package:freedom_of_athletics/widgets/selectors/memberSelectorCheckbox.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../selectors/friend_selector_checkbox_widget.dart';

class TeamPageView extends StatefulWidget {
  DocumentSnapshot teamData, user;

  TeamPageView(this.teamData,this.user);

  @override
  State<TeamPageView> createState() => _TeamPageViewState();
}

class _TeamPageViewState extends State<TeamPageView> {
  DataController dataController = Get.find<DataController>();
  List<String> selectedFriends = [];

  @override
  Widget build(BuildContext context) {


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
                    image: NetworkImage(
                      widget.teamData.get('badge')
                    ),
                    fit: BoxFit.cover
                  )
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${widget.teamData.get('team_name')}",
                  style: const TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.w600
                  ),
                )
              ],
            ),
            SizedBox(height: 15,),
            FutureBuilder<bool>(
              future: UserHelper.isTeamFull(widget.teamData.get('players_count'), widget.teamData.id),
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot){
                if(snapshot.connectionState == ConnectionState.waiting){
                  return CircularProgressIndicator();
                } else if(snapshot.hasData){
                  if(snapshot.data!){
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('The team is already full',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 28,color: Colors.white),)
                      ],
                    );
                  } else {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    FutureBuilder<bool>(
                        future: UserHelper.isUserDocumentExists(FirebaseAuth.instance.currentUser!.uid, 'users', 'memberToATeam', 'user_Uid', FirebaseAuth.instance.currentUser!.uid),
                        builder: (BuildContext context, AsyncSnapshot <bool> snapshot){
                          if(snapshot.connectionState == ConnectionState.waiting){
                            return CircularProgressIndicator();
                          } else if(snapshot.hasData){
                            if(snapshot.data!){
                              return Container(
                                  height: 50,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [BoxShadow(
                                      color: Colors.white.withOpacity(0.8),
                                      spreadRadius: 0.1,
                                      blurRadius: 60,
                                      offset: const Offset(0, 1),
                                    ),
                                    ],
                                    borderRadius: BorderRadius.circular(13)
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,vertical: 10
                                  ),
                                  child: const Center(
                                    child: Text('Already member',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black
                                    ),
                                    ),
                                  ),
                              );
                            }else{
                              return InkWell(
                                onTap: () async{
                                  final QuerySnapshot result = await FirebaseFirestore.instance.collection('teams').where('uid',isEqualTo: widget.teamData.get('uid')).limit(1).get();
                                  final DocumentSnapshot doc = result.docs.first;
                                  final QuerySnapshot userResult = await FirebaseFirestore.instance.collection('users').where('uid',isEqualTo: widget.teamData.get('uid')).limit(1).get();
                                  final DocumentSnapshot userDoc = userResult.docs.first;
                                  String teamDoc = doc.id;
                                  String teamCreatorToken = userDoc.get('fcmToken');
                                  var sender = dataController.myDocument?.get('firstname');
                                  UserHelper.JoiningRequestToATeam(dataController.myDocument?.get('fcmToken'), FirebaseAuth.instance.currentUser!.uid, widget.teamData.get('uid'), teamDoc, widget.teamData.get('uid'), widget.teamData.get('team_name'), widget.teamData.get('badge'), dataController.myDocument?.get('firstname'), dataController.myDocument?.get('fcmToken'), dataController.myDocument?.get('profilePicture'));
                                  LocalNotificationService.sendNotification('Joining request to your team', '$sender wants to join to your team', teamCreatorToken);
                                },
                                child: Container(
                                  height: 45,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.8),
                                        spreadRadius: 0.1,
                                        blurRadius: 60,
                                        offset: const Offset(0,1),
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(13)
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,vertical: 10
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Join',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                          }else{
                            return Text(
                              'Error: ${snapshot.error}'
                            );
                          }
                        }
                    ),
                  TextButton(onPressed: () => showDialog(
                      context: context,
                      builder: (context) {
                        return memberSelectorCheckbox(selectedFriends,widget.teamData);
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
              }}else{
                  return Container();
    }}
            ),
            SizedBox(height: 30),
            SizedBox(
              child: Text('The team consist of these players below:',style: TextStyle(color: Colors.white),),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 100,
                  width: 150,
                  child: FutureBuilder<QuerySnapshot<Map<String,dynamic>>>(
                    future: widget.teamData.reference.collection('members').get(),
                    builder: (context, snapshot) {
                      if(snapshot.connectionState == ConnectionState.waiting){
                        return Center(child: CircularProgressIndicator());
                      }else if(snapshot.hasError){
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else{
                        List<DocumentSnapshot<Map<String,dynamic>>> members = snapshot.data!.docs;
                        return ListView.builder(
                            itemCount: members.length,
                            itemBuilder: (ctx,i){
                              DocumentSnapshot<Map<String,dynamic>> member= members[i];
                              DocumentSnapshot user =
                              dataController.allUsers.firstWhere((e) => member.get('Uid') == e.id);
                              return Align(
                                child: ListTile(
                                  title: Text(member.get('firstname'),style: TextStyle(color: Colors.white),),
                                  leading: GestureDetector(child: CircleAvatar(backgroundImage: NetworkImage(member.get('memberProfilePicture')),),onTap: (){Get.to(() => EventCreatorProfile(user));},),

                                ),
                              );
                            }
                        );
                      }
                    },
                  ),
                )
              ],
            ), SizedBox(height: 30),
            SizedBox(
              child: Text('Some useful words from the creator of the team:',style: TextStyle(color: Colors.white),),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Text(
                    '${widget.teamData.get('description')}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30)
          ],
        ),
      ),
    );
  }
}
