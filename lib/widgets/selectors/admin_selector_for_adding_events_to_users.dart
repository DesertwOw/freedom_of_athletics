import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/screens/adminScreens/allEvents.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../services/DataController.dart';
import '../../services/auth_helper.dart';

class AdminSelectorForAddingEventsToUsers extends StatefulWidget {
  DocumentSnapshot user;

  AdminSelectorForAddingEventsToUsers(this.user);

  @override
  State<AdminSelectorForAddingEventsToUsers> createState() => _AdminSelectorForAddingEventsToUsersState();
}

class _AdminSelectorForAddingEventsToUsersState extends State<AdminSelectorForAddingEventsToUsers> {
  @override

  DataController dataController = Get.find<DataController>();

  Widget build(BuildContext context) {
    String userName = widget.user.get('firstname');

    return Dialog(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 20,),
          Text('You can add $userName to these events below',
          style: TextStyle(fontSize: 18.0,color: Colors.black),
          ),
          const SizedBox(
            height: 30,
          ),
          Flexible(
              child:FutureBuilder<List<QueryDocumentSnapshot>>(
                future: UserHelper.getEventsWhereUserNotParticipating(widget.user.get('uid')),
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
                    List<QueryDocumentSnapshot> participatingsInEvents = snapshot.data!;

                    participatingsInEvents = participatingsInEvents.where((event) => event.get('uid') != widget.user.get('uid')).toList();

                    return participatingsInEvents.isEmpty
                        ? const Center(
                      child: Text('No event found.'),
                    )
                        : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (ctx, i) {
                        return ListTile(
                          title: Text(participatingsInEvents[i].get('event_name')),
                          trailing: GestureDetector(
                            child: Icon(Icons.add),
                            onTap: () async {

                              UserHelper.AddUserToAnEventByAdmin(participatingsInEvents[i].id, participatingsInEvents[i].get('event_name'), widget.user.get('uid'), userName, widget.user.get('fcmToken'), widget.user.get('profilePicture'));
                            },
                          ),
                        );
                      },
                      itemCount: participatingsInEvents.length,
                    );
                  }
                },
              )
          )

        ],
      ),
    );
  }
}

