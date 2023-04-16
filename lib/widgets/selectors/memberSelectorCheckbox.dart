import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/services/DataController.dart';
import 'package:freedom_of_athletics/services/auth_helper.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class memberSelectorCheckbox extends StatefulWidget {
  DocumentSnapshot teamData;

  memberSelectorCheckbox(this.selectedFriends,this.teamData);

  final List<String> selectedFriends;

  @override
  State<memberSelectorCheckbox> createState() => _memberSelectorCheckboxState();
}

class _memberSelectorCheckboxState extends State<memberSelectorCheckbox> {

  DataController dataController = Get.find<DataController>();
  List<String> _tempSelectedFriends = [];
  List<String> _tempSelectedUids = [];
  List<String> _tempSelectedTokens = [];

  @override
  void initState(){
    _tempSelectedFriends = widget.selectedFriends;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: <Widget>[
          Text(
            'Friends',
            style: TextStyle(fontSize: 18.0, color: Colors.black),
            textAlign: TextAlign.center,
          ),

          Expanded(
            child: Obx(() {
              if (dataController.isFriendsLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  future: FirebaseFirestore.instance
                      .collection('teams')
                      .doc(widget.teamData.id)
                      .collection('members')
                      .get(),
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
                    final membersSnapshot = snapshot.data!.docs;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (ctx, i) {
                        bool hasMatch = false;
                        for (final member in membersSnapshot) {
                          if (member.get('Uid') == dataController.filteredFriends[i].get('Uid')) {
                            hasMatch = true;
                            break;
                          }
                        }
                        if (hasMatch) {
                          return ListTile(title: Text(dataController.filteredFriends[i].get('firstname')),subtitle: Text('Ez a barátod már csatlakozott a csapathoz'),);
                        } else {
                          return CheckboxListTile(
                            title: Text(dataController.filteredFriends[i].get('firstname')),
                            value: _tempSelectedFriends.contains(dataController.filteredFriends[i].get('firstname')),
                            onChanged: (value) {
                              if (value != null) {
                                if (!_tempSelectedFriends.contains(dataController.filteredFriends[i].get('firstname'))) {
                                  setState(() {
                                    _tempSelectedFriends.add(dataController.filteredFriends[i].get('firstname'));
                                    _tempSelectedUids.add(dataController.filteredFriends[i].get('Uid'));
                                    _tempSelectedTokens.add(dataController.filteredFriends[i].get('fcmToken'));
                                  });
                                }
                              } else {
                                if (_tempSelectedFriends.contains(dataController.filteredFriends[i].get('firstname'))) {
                                  setState(() {
                                    _tempSelectedFriends.removeWhere((String friend) => friend == dataController.filteredFriends[i].get('firstname'));
                                    _tempSelectedUids.removeWhere((String uid) => uid == dataController.filteredFriends[i].get('Uid'));
                                    _tempSelectedTokens.removeWhere((String uid) => uid == dataController.filteredFriends[i].get('fcmToken'));
                                  });
                                }
                              }
                            },
                          );
                        }
                      },
                      itemCount: dataController.filteredFriends.length,
                      scrollDirection: Axis.vertical,
                    );
                  },
                );
              }
            }),
          ),



          ElevatedButton(
              onPressed: () {
                String eventImage = '';
                try {
                  List media = widget.teamData.get('media') as List;
                  Map mediaItem = media.first as Map;
                  eventImage = mediaItem['url'];
                } catch (e) {
                  eventImage = '';
                }

                UserHelper.sendOutTeamInvitationRequests(_tempSelectedUids,widget.teamData.id,widget.teamData.get('uid'),widget.teamData.get('team_name'),eventImage,dataController.myDocument!.get('firstname'),dataController.myDocument!.get('fcmToken'),dataController.myDocument?.get('profilePicture'));

                var senderName = dataController.myDocument?.get('firstname');
                UserHelper.sendOutGroupNotifications(_tempSelectedTokens, senderName);
                Get.back();
              },
              child: Text('Done')
          ),
        ],
      ),
    );
  }
}
