import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../services/DataController.dart';
import '../../services/auth_helper.dart';

class AdminSelectorForAddingUsersToEvents extends StatefulWidget {
  DocumentSnapshot event;

  AdminSelectorForAddingUsersToEvents(this.event);

  @override
  State<AdminSelectorForAddingUsersToEvents> createState() => _AdminSelectorForAddingUsersToEventsState();
}

class _AdminSelectorForAddingUsersToEventsState extends State<AdminSelectorForAddingUsersToEvents> {
  List<String> _tempSelectedUsers = [];
  List<String> _tempSelectedUserUids = [];
  List<String> _tempSelectedUserProfPics = [];

  DataController dataController = Get.find<DataController>();
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 20,
          ),
          const Text(
            'You can add users to this event below',
            style: TextStyle(fontSize: 18.0, color: Colors.black),
          ),
          const SizedBox(
            height: 30,
          ),
          FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance.collection('events').doc(widget.event.id).collection('participants').get(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshotEvent) {
              if (snapshotEvent.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshotEvent.hasError) {
                return const Center(
                  child: Text('Error fetching data'),
                );
              }

              List<String> participantUids = [];
              if (snapshotEvent.hasData) {
                participantUids = snapshotEvent.data!.docs.map((doc) => doc['Uid'].toString()).toList();
              }

              return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance.collection('users').get(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error fetching data'),
                    );
                  }

                  List<QueryDocumentSnapshot<Map<String, dynamic>>> nonParticipantUsers = snapshot.data!.docs.where((doc) => !participantUids.contains(doc['uid'])).toList();


                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (ctx, i) {
                      final user = nonParticipantUsers[i];
                      return CheckboxListTile(
                        title: Text(user.get('firstname')),
                        value: _tempSelectedUsers.contains(user.get('firstname')),
                        onChanged: (value) {
                          if (value != null) {
                            if (!_tempSelectedUsers.contains(user.get('firstname'))) {
                              setState(() {
                                _tempSelectedUsers.add(user.get('firstname'));
                                _tempSelectedUserUids.add(user.get('uid'));
                                _tempSelectedUserProfPics.add(user.get('profilePicture'));
                              });
                            }
                          } else {
                            if (_tempSelectedUsers.contains(user.get('firstname'))) {
                              setState(() {
                                _tempSelectedUsers.removeWhere((String selectedUser) => selectedUser == user.get('firstname'));
                                _tempSelectedUserUids.removeWhere((String userUid) => userUid == user.get('uid'));
                                _tempSelectedUserProfPics.removeWhere((String profilePic) => profilePic == user.get('profilePicture'));
                              });
                            }
                          }
                        },
                      );
                    },
                    itemCount: nonParticipantUsers.length,
                  );
                },
              );
            },
          ),

          Center(
            child: TextButton(
              child: const Text("Done"),
              onPressed: () async {
               for(int i = 0; i < _tempSelectedUsers.length; i++){
                 UserHelper.addParticipantsToEventByAdmin(
                     [_tempSelectedUserUids[i]],
                     widget.event.id,
                     widget.event.get('uid'),
                     _tempSelectedUsers[i],
                     _tempSelectedUserProfPics[i],
                     widget.event.get('event_name')
                 );
               }
               Get.back();
              },
            ),
          ),

        ],
      ),
    );
  }
}
