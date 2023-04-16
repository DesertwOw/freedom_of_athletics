import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../services/DataController.dart';
import '../../services/auth_helper.dart';

class AdminSelectorForRemovingParticipantsFromEvents extends StatefulWidget {
  DocumentSnapshot event;

  AdminSelectorForRemovingParticipantsFromEvents(this.event);

  @override
  State<AdminSelectorForRemovingParticipantsFromEvents> createState() => _AdminSelectorForRemovingParticipantsFromEventsState();
}

class _AdminSelectorForRemovingParticipantsFromEventsState extends State<AdminSelectorForRemovingParticipantsFromEvents> {
  Map<String, List<String>> _selectedUsers = {};
  DataController dataController = Get.find<DataController>();
  bool isChecked = false;

  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 20,
          ),
          const Text(
            'You can remove users from this event below',
            style: TextStyle(fontSize: 18.0, color: Colors.black),
          ),
          const SizedBox(
            height: 30,
          ),
          Flexible(
            child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
              future: widget.event.reference.collection("participants").get(),
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
                      bool isChecked = _selectedUsers[widget.event.id]?.contains(member.id) ?? false;
                      return CheckboxListTile(
                        title: Text(member.get('firstname')),
                        onChanged: (value) {
                          setState(() {
                            isChecked = value ?? false;
                            if (isChecked) {
                              _selectedUsers.update(widget.event.id, (value) => [...value, member.id], ifAbsent: () => [member.id]);
                            } else {
                              _selectedUsers.update(widget.event.id, (value) => value..remove(member.id), ifAbsent: () => []);
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
                List<String> userIds = _selectedUsers[widget.event.id] ?? [];
                await UserHelper.removeParticipants(widget.event.id, userIds);
                Get.back();
              },
            ),
          ),
        ],
      ),
    );
  }
}


