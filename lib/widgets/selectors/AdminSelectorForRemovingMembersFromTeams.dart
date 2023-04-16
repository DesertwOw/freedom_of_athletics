import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/services/auth_helper.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../screens/adminScreens/user_profile_for_admin.dart';
import '../../services/DataController.dart';

class AdminSelectorForRemovingMembersFromTeams extends StatefulWidget {

  DocumentSnapshot team;
  AdminSelectorForRemovingMembersFromTeams(this.team);


  @override
  State<AdminSelectorForRemovingMembersFromTeams> createState() => _AdminSelectorForRemovingMembersFromTeamsState();
}

class _AdminSelectorForRemovingMembersFromTeamsState extends State<AdminSelectorForRemovingMembersFromTeams> {
  Map<String, List<String>> _selectedUsers = {};
  List<String> _selectedUserIds = [];

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
          const Text('You can remove users from this team below',
            style: TextStyle(fontSize: 18.0, color: Colors.black),
          ),
          const SizedBox(
            height: 30,
          ),

          Flexible(
            child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
              future: widget.team.reference.collection("members").get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else {
                    List<DocumentSnapshot<Map<String, dynamic>>> members = snapshot.data!.docs;
                  return ListView.builder(
                    itemBuilder: (ctx, i) {
                      DocumentSnapshot<Map<String, dynamic>> member = members[i];
                      bool isChecked = _selectedUsers[widget.team.id]?.contains(member.id) ?? false;
                      return CheckboxListTile(
                        title: Text(member.get('firstname')),
                        onChanged: (value) {
                          setState(() {
                            isChecked = value ?? false;
                            if (isChecked) {
                              _selectedUsers.update(widget.team.id, (value) => [...value, member.id], ifAbsent: () => [member.id]);
                              _selectedUserIds.add(member.get('user_Uid'));
                            } else {
                              _selectedUsers.update(widget.team.id, (value) => value..remove(member.id), ifAbsent: () => []);
                              _selectedUserIds.remove(member.get('firstname'));
                            }
                          });
                        },
                        value: isChecked,
                      );
                    },
                    itemCount: members.length,
                    scrollDirection: Axis.vertical,
                  );
                }
              },
            ),
          ),

          Center(
            child: TextButton(
              child: const Text("Done"),
              onPressed: () async {
                List<String> userIds = _selectedUsers[widget.team.id] ?? [];

                for (int i = 0; i < _selectedUserIds.length; i++) {
                  String userId = _selectedUserIds[i];
                  print(userId);
                  await UserHelper.removeMembers(widget.team.id, userIds, userId);
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
