import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

import 'package:iconsax/iconsax.dart';

import '../../services/DataController.dart';
import '../../services/auth_helper.dart';
import '../../services/fcm_handler.dart';

class TwoSidedJoiningEventRequestContainer extends StatefulWidget {


  @override
  _TwoSidedJoiningEventRequestContainerState createState() => _TwoSidedJoiningEventRequestContainerState();
}

class _TwoSidedJoiningEventRequestContainerState extends State<TwoSidedJoiningEventRequestContainer> with SingleTickerProviderStateMixin{
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
    return Obx(() => dataController.isJoiningToAnEventRequest.value
        ? const Center(
      child: CircularProgressIndicator(),
    )
        : ListView.builder(
      itemBuilder: (context,i){
        var senderUid = FirebaseAuth.instance.currentUser!.uid;
        var eventDoc= dataController.filteredJoiningToAnEventRequest[i].get(
            'eventDoc');
        var eventUid = dataController.filteredJoiningToAnEventRequest[i].get(
            'eventUid');
        var uid = dataController.filteredJoiningToAnEventRequest[i].get('Uid');
        var eventName = dataController.filteredJoiningToAnEventRequest[i].get(
            'event_name');
        var acceptorToken = dataController.filteredJoiningToAnEventRequest[i].get(
            'inviterToken');
        var acceptorName = dataController.filteredJoiningToAnEventRequest[i].get(
            'inviter_name');
        var notifierName = dataController.myDocument?.get('firstname');
        var acceptorProfilePicture = dataController.myDocument?.get('profilePicture');
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
                            title: Text(eventName),
                            subtitle: Text(
                              acceptorName,
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  child: const Icon(Iconsax.tick_circle),
                                  onTap: (){
                                    LocalNotificationService.sendNotification(
                                        'Event Invitation Request Accepted',
                                        '$notifierName Accepted your invite!', acceptorToken);
                                    UserHelper.IndividualJoin(
                                      senderUid, eventDoc,eventUid, eventName, acceptorToken,uid,acceptorName,acceptorProfilePicture);
                                    UserHelper.DeleteJoinAsAnIndividual(uid, senderUid);
                                  },
                                ),
                                const SizedBox(width: 5),
                                GestureDetector(
                                  child: Icon(Iconsax.tag_cross),
                                  onTap: () {
                                    UserHelper.DeleteJoinAsAnIndividual(uid, senderUid);
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
                            DecorationImage(image: NetworkImage(dataController.filteredJoiningToAnEventRequest[i].get(
                                'event_picture')), fit: BoxFit.fitHeight),
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
                                        eventName,
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
      itemCount: dataController.filteredJoiningToAnEventRequest.length,
    ),
    );
  }
}
