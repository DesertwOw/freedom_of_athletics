import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/services/DataController.dart';
import 'package:freedom_of_athletics/widgets/clipper.dart';
import 'package:freedom_of_athletics/widgets/teamWidgets/updateTeamDialog.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';

import '../../screens/profileScreens/event_creator_profile.dart';
import '../../services/auth_helper.dart';
import '../selectors/memberSelectorCheckbox.dart';

class TeamPageViewForOrganizers extends StatefulWidget {
  DocumentSnapshot teamData, user;

  TeamPageViewForOrganizers(this.teamData, this.user);

  @override
  State<TeamPageViewForOrganizers> createState() => _TeamPageViewForOrganizersState();
}

class _TeamPageViewForOrganizersState extends State<TeamPageViewForOrganizers> {
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
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  child: Text('You created this team!'),
                )
              ],
            ),
            SizedBox(
              height: 15,
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
            SizedBox(height: 30),
            SizedBox(
              child: Text('The team consist of these players below:',style: TextStyle(color: Colors.white),),
            ),
            SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               SizedBox(
              height: 117,
              width: 400,
              child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                future: widget.teamData.reference.collection("members").get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else {
                    List<DocumentSnapshot<Map<String, dynamic>>> members = snapshot.data!.docs;
                    return Expanded(
                      child: ListView.builder(
                        itemBuilder: (ctx, i) {
                          DocumentSnapshot<Map<String, dynamic>> member = members[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Container(
                              width: 100,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 5,
                                    ),
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(member.get('memberProfilePicture')),
                                    ),
                                    Text(
                                      member.get('firstname'),
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    GestureDetector(
                                      child: Icon(Iconsax.profile_delete),
                                      onTap: () {
                                        UserHelper.RemoveMember(widget.teamData.id, member.get('Uid'));
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: members.length,
                        scrollDirection: Axis.horizontal,
                      ),
                    );
                  }
                },
              ),
            )

      ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return UpdateTeamDialog(
                          teamDoc: widget.teamData.id,
                          shortName: widget.teamData.get('short_name'),
                          description: widget.teamData.get('description'),
                          sportCategory: widget.teamData.get('sport_category'),
                          teamName: widget.teamData.get('team_name'),
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blueAccent,
                    onPrimary: Colors.white,
                  ),
                  child: Text(
                    'Update your team info there!',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
