import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/screens/profileScreens/event_creator_profile.dart';
import 'package:freedom_of_athletics/services/auth_helper.dart';
import 'package:freedom_of_athletics/services/fcm_handler.dart';
import 'package:freedom_of_athletics/widgets/animatedContainers/twoSidedJoiningEventRequestContainer.dart';
import 'package:freedom_of_athletics/widgets/animatedContainers/twoSidedJoiningTeamRequestContainer.dart';
import 'package:freedom_of_athletics/widgets/animatedContainers/twoSidedTeamContainer.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';

import '../../services/DataController.dart';
import '../../widgets/InvitationsBackground.dart';
import '../../widgets/animatedContainers/twoSidedEventContainer.dart';

class Invitations extends StatefulWidget {
  DocumentSnapshot user;

  Invitations(this.user);


  @override
  State<Invitations> createState() => _InvitationsState();

}

class _InvitationsState extends State<Invitations> {

  @override
  Widget build(BuildContext context){
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    DataController dataController = Get.find<DataController>();

    final headerList = TwoSidedEventContainer();

    final bottomList = TwoSidedTeamContainer();

    final soloJoinerListToAnEvent = TwoSidedJoiningEventRequestContainer();

    final soloJoinerListToATeam = TwoSidedJoiningTeamRequestContainer();

    final body = Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('My invitations'),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Text('Event invitations',style: TextStyle(fontSize: 20,color: Colors.white),),
              Stack(
                children: <Widget>[
                  SizedBox(height: 20,),
                  Padding(padding: EdgeInsets.only(top: 10.0),child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 200.0,
                        width: _width,
                        child: headerList
                      ),
                      Text('Friend Requests',style: TextStyle(fontSize: 20,color: Colors.black),),
                      Container(
                        height: 160,
                          child:
                            Obx(() => dataController.isRequestsLoading.value
                                ? const Center(
                              child: CircularProgressIndicator(),
                            )
                                : ListView.builder(
                              shrinkWrap: true,
                              itemBuilder: (ctx, i) {
                                DocumentSnapshot user =
                                dataController.allUsers.firstWhere(
                                        (e) => e.id == dataController.filteredRequests[i].get('Uid'));
                                if(UserHelper.isItForMe(dataController.filteredRequests[i].get('receiver_uid'))) {
                                  return ListTile(
                                    title: Text(
                                        dataController.filteredRequests[i].get(
                                            'firstname')),
                                    leading: GestureDetector(child: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            dataController.filteredRequests[i].get(
                                                'profilePicture'))), onTap: () {
                                      Get.to(
                                              () => EventCreatorProfile(user));
                                    }),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          child: Icon(Iconsax.tick_circle),
                                          onTap: () {
                                            var senderUid = FirebaseAuth.instance
                                                .currentUser!.uid;
                                            var senderName = dataController
                                                .myDocument?.get('firstname');
                                            var senderToken = dataController
                                                .myDocument?.get('fcmToken');
                                            var senderProfilePicture = dataController
                                                .myDocument?.get('profilePicture');
                                            var acceptorToken = dataController
                                                .filteredRequests[i].get(
                                                'fcmToken');
                                            UserHelper.DeleteFriendRequest(
                                                senderUid,
                                                dataController.filteredRequests[i]
                                                    .get('Uid'));
                                            UserHelper.AddFriend(
                                                senderName,
                                                senderUid,
                                                senderToken,
                                                senderProfilePicture,
                                                dataController.filteredRequests[i]
                                                    .get('Uid'),
                                                dataController.filteredRequests[i]
                                                    .get('firstname'),
                                                acceptorToken,
                                                dataController.filteredRequests[i]
                                                    .get('profilePicture'));
                                            LocalNotificationService
                                                .sendNotification(
                                                'Friend Request Accepted',
                                                '$senderName Accepted your friend request!',
                                                acceptorToken);
                                            print(acceptorToken);
                                          },),
                                        SizedBox(width: 5),
                                        GestureDetector(
                                          child: Icon(Iconsax.tag_cross),
                                          onTap: () {
                                            var senderUid = FirebaseAuth.instance
                                                .currentUser!.uid;
                                            UserHelper.DeleteFriendRequest(
                                                senderUid,
                                                dataController.filteredRequests[i]
                                                    .get('Uid'));
                                          },)
                                      ],
                                    ),
                                  );
                                }else
                                  {
                                    return SizedBox.shrink();
                                  }
                              },
                              itemCount: dataController.filteredRequests.length,
                              scrollDirection: Axis.vertical,
                            )),
                      ),
                      SizedBox(height: 40,),
                      Text('Team invitations',style: TextStyle(fontSize: 20,color: Colors.black),),
                      SizedBox(height: 10,),
                      Container(
                          height: 150.0,
                          width: _width,
                          child: bottomList
                      ),
                      Text('Joining to Event Requests',style: TextStyle(fontSize: 20,color: Colors.black),),
                      SizedBox(height: 10,),
                      Container(
                          height: 150.0,
                          width: _width,
                          child: soloJoinerListToAnEvent
                      ),
                      Text('Joining to Team Requests',style: TextStyle(fontSize: 20,color: Colors.black),),
                      SizedBox(height: 10,),
                      Container(
                          height: 150.0,
                          width: _width,
                          child: soloJoinerListToATeam
                      ),
                    ],
                  ),)
                ],
              ),
            ],
          ),
        ),
      ),
    );



    return Container(decoration: BoxDecoration(
      color: Color(0xFF273A48),
    ),
      child: Stack(
        children: <Widget>[
          CustomPaint(
            size: Size(_width,_height),
            painter: InvitationsBackground(),
          ),
          body,
        ],
      ),
    );
  }
}