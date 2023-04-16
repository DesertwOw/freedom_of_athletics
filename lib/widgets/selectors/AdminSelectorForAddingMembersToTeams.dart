import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/services/auth_helper.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';

import '../../services/DataController.dart';

class AdminSelectorForAddingMembersToTeams extends StatefulWidget {
  DocumentSnapshot team;

  AdminSelectorForAddingMembersToTeams(this.team);

  @override
  State<AdminSelectorForAddingMembersToTeams> createState() => _AdminSelectorForAddingMembersToTeamsState();
}

class _AdminSelectorForAddingMembersToTeamsState extends State<AdminSelectorForAddingMembersToTeams> {
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
            'You can add users to this team below',
            style: TextStyle(fontSize: 18.0, color: Colors.black),
          ),
          const SizedBox(
            height: 30,
          ),
          FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance.collection('teams').doc(widget.team.id).collection('members').get(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshotTeam) {
              if (snapshotTeam.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshotTeam.hasError) {
                return const Center(
                  child: Text('Error fetching data'),
                );
              }

              List<String> memberUids = [];
              if (snapshotTeam.hasData) {
                memberUids = snapshotTeam.data!.docs.map((doc) => doc['user_Uid'].toString()).toList();
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

                  List<QueryDocumentSnapshot<Map<String, dynamic>>> nonMemberUsers = snapshot.data!.docs.where((doc) => !memberUids.contains(doc['uid'])).toList();


                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (ctx, i) {
                      final user = nonMemberUsers[i];
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
                    itemCount: nonMemberUsers.length,
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
                  UserHelper.addMembersToATeamByAdmin(
                    [_tempSelectedUserUids[i]],
                    widget.team.id,
                    _tempSelectedUsers[i],
                    _tempSelectedUserProfPics[i],
                    widget.team.get('sport_category'),
                    widget.team.get('team_name'),
                    widget.team.get('uid'),
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
