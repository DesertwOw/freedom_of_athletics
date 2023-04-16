import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:math' as math;

import '../../services/DataController.dart';
import '../../services/auth_helper.dart';
import '../../services/fcm_handler.dart';
class TwoSidedTeamContainer extends StatefulWidget {

  @override
  _TwoSidedTeamContainerState createState() => _TwoSidedTeamContainerState();
}

class _TwoSidedTeamContainerState extends State<TwoSidedTeamContainer> with SingleTickerProviderStateMixin{
  bool _isFrontSideVisible = true;
  late AnimationController _animationController;
  late Animation<double> _animation;

  void _toggleSides() {
    setState(() {
      _isFrontSideVisible = !_isFrontSideVisible;
    });

    if (_isFrontSideVisible) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DataController dataController = Get.find<DataController>();
    return Obx(() => dataController.isBecomingMemberLoading.value
        ? const Center(
      child: CircularProgressIndicator(),
    )
        : ListView.builder(
      itemBuilder: (context,i){
        var senderUid = FirebaseAuth.instance.currentUser!.uid;
        var senderName = dataController.myDocument?.get('firstname');
        var senderProfilePicture = dataController.myDocument?.get('profilePicture');
        var acceptor = dataController.filteredMemberRequests[i].get('potentionalMemberName');
        var acceptorToken = dataController.filteredMemberRequests[i].get('senderToken');

        var teamName = dataController.filteredMemberRequests[i].get('team_name');
        var acceptorUid = dataController.filteredMemberRequests[i].get('Uid');
        EdgeInsets padding = i == 0 ? const EdgeInsets.only(
            left: 20.0, right: 10.0, top: 4.0, bottom: 30.0): const EdgeInsets.only(
            left: 10.0, right : 10.0, top: 4.0, bottom: 30.0);

        return Padding(
            padding: padding,
            child:  GestureDetector(
              onTap: _toggleSides,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  final angle =  math.pi * _animation.value * 2;
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                    child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 5,
                              spreadRadius: 1,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _isFrontSideVisible
                            ?  Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.blueAccent,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withAlpha(70),
                                  offset: Offset(3.0, 10.0),
                                  blurRadius: 15.0)
                            ],
                          ),
                          width: 200.0,
                          child: ListTile(
                            title: Text(teamName),
                            subtitle: Text(
                              acceptor,
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  child: const Icon(Iconsax.tick_circle),
                                  onTap: (){
                                    Query query  = FirebaseFirestore.instance.collection('teams').where('uid',isEqualTo: acceptorUid);
                                    query.get().then((querySnapshot){
                                      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
                                      String documentId = documentSnapshot.id;
                                      print(documentId);
                                      String documentName = documentSnapshot.get('team_name');
                                      String documentPicture = documentSnapshot.get('badge');
                                      UserHelper.AcceptTeamInv(
                                          senderUid,dataController.filteredMemberRequests[i].get('Uid'), documentId,documentName, acceptorToken,senderName,senderProfilePicture,documentPicture);
                                      UserHelper.DeleteJoiningToATeamRequest(senderUid,dataController.filteredMemberRequests[i].get('Uid'));
                                      LocalNotificationService.sendNotification(
                                          'Team Invitation Request Accepted',
                                          '$acceptor Accepted your invite!', acceptorToken);
                                    });

                                    },
                                ),
                                const SizedBox(width: 5),
                                GestureDetector(
                                  child: Icon(Iconsax.tag_cross),
                                  onTap: () {
                                    UserHelper.DeleteJoiningToATeamRequest(senderUid,dataController.filteredMemberRequests[i].get('Uid'));
                                  },
                                )
                              ],
                            ),
                          ),
                        )
                            : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.blueAccent,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withAlpha(70),
                                  offset: const Offset(3.0, 10.0),
                                  blurRadius: 15.0)
                            ],
                            image:
                            DecorationImage(image: NetworkImage(dataController.filteredMemberRequests[i].get(
                                'teamBadge')), fit: BoxFit.fitHeight),
                          ),
                          width: 200.0,
                          child: Stack(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  decoration: const BoxDecoration(
                                      color: Color(0xFF273A48),
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10.0),
                                          bottomRight: Radius.circular(10.0))),
                                  height: 30.0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        teamName,
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                    ),
                  );
                },
              ),
            )
        );
      },
      scrollDirection: Axis.horizontal,
      itemCount: dataController.filteredMemberRequests.length,
    ),
    );
  }
}
