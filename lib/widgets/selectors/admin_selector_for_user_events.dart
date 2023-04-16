import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';

import '../../services/DataController.dart';
import '../../services/auth_helper.dart';

class AdminSelectorForUserEvents extends StatefulWidget {
  DocumentSnapshot user;

  AdminSelectorForUserEvents(this.user);


  @override
  State<AdminSelectorForUserEvents> createState() => _AdminSelectorForUserEventsState();
}

class _AdminSelectorForUserEventsState extends State<AdminSelectorForUserEvents> {

  DataController dataController = Get.find<DataController>();




  @override
  Widget build(BuildContext context) {
    String userName = widget.user.get('firstname');


    return Dialog(
      child: Column(
        children: <Widget>[
          SizedBox(height: 20,),
          Text(
            '$userName participates in the events below',
            style: TextStyle(fontSize: 18.0, color: Colors.black),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 30,
          ),
          Flexible(
            child:FutureBuilder<List<QueryDocumentSnapshot>>(
              future: UserHelper.getEventsWhereUserTakesPart(widget.user.get('uid')),
              builder: (BuildContext context, AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error retrieving participatings.'),
                  );
                } else {
                  List<QueryDocumentSnapshot> participatingsInEvents = snapshot.data!;

                  return participatingsInEvents.isEmpty
                      ? const Center(
                    child: Text('No participatings found.'),
                  )
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (ctx, i) {
                      return ListTile(
                        title: Text(participatingsInEvents[i].get('event_name')),
                        trailing: GestureDetector(child: Icon(Icons.delete)),onTap: () =>{
                          UserHelper.RemoveParticipant(participatingsInEvents[i].get('Uid'), widget.user.id)
                      },
                      );
                    },
                    itemCount: participatingsInEvents.length,
                  );
                }
              },
            )
          ),
            ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                child: Text('Done')
            ),
        ],
      ),
    );
  }
}
