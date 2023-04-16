import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/services/DataController.dart';
import 'package:freedom_of_athletics/services/auth_helper.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class TeamSelectorCheckboxWidget extends StatefulWidget {
  TeamSelectorCheckboxWidget(this.selectedMembers);

  final List<String> selectedMembers;

  @override
  State<TeamSelectorCheckboxWidget> createState() =>
      _TeamSelectorCheckboxWidgetState();
}

class _TeamSelectorCheckboxWidgetState
    extends State<TeamSelectorCheckboxWidget> {
  DataController dataController = Get.find<DataController>();
  List<String> _tempSelectedMembers = [];
  List<String> _tempSelectedMemberUids = [];
  List<String> _tempSelectedMemberTokens = [];


  @override
  void initState() {
    _tempSelectedMembers = widget.selectedMembers;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: <Widget>[
          Text(
            'Teams',
            style: TextStyle(fontSize: 18.0, color: Colors.black),
            textAlign: TextAlign.center,
          ),
          Expanded(
              child: Obx(() => dataController.isTeamsLoading.value
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : SizedBox(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (ctx, i) {
                          return ExpansionTile(
                            title: Text(
                                dataController.allTeams[i].get('team_name')),
                            children: [
                              Obx(() => dataController.isTeamMemberLoading.value
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : SizedBox(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (ctx, i){
                                      return CheckboxListTile(
                                          title: Text(dataController
                                              .filteredSpecificTeamMember[i]
                                              .get('firstname')),
                                          value: _tempSelectedMembers.contains(
                                            dataController
                                                .filteredSpecificTeamMember[i]
                                                .get('firstname'),
                                          ),
                                          onChanged: (value) {
                                            if (value != null) {
                                              if (!_tempSelectedMembers.contains(
                                                  dataController.filteredSpecificTeamMember[i]
                                                      .get('firstname'))) {
                                                setState(() {
                                                  _tempSelectedMembers.add(
                                                      dataController
                                                          .filteredSpecificTeamMember[i]
                                                          .get('firstname'));
                                                  _tempSelectedMemberTokens.add(dataController.filteredSpecificTeamMember[i].get('memberToken'));
                                                  _tempSelectedMemberUids.add(dataController.filteredSpecificTeamMember[i].get('Uid'));
                                                });
                                              }
                                            } else {
                                              if (_tempSelectedMembers.contains(
                                                  dataController.filteredSpecificTeamMember[i]
                                                      .get('firstname'))) {
                                                setState(() {
                                                  _tempSelectedMembers.removeWhere(
                                                          (String friend) =>
                                                      friend ==
                                                          dataController
                                                              .filteredSpecificTeamMember[i]
                                                              .get('firstname'));
                                                  _tempSelectedMemberUids.removeWhere(
                                                          (String uid) =>
                                                      uid ==
                                                          dataController
                                                              .filteredSpecificTeamMember[i]
                                                              .get('Uid'));
                                                  _tempSelectedMemberTokens.removeWhere(
                                                          (String token) =>
                                                      token ==
                                                          dataController
                                                              .filteredSpecificTeamMember[i]
                                                              .get('memberToken'));
                                                });
                                              }
                                            }
                                          });
                                   },
                                  itemCount: dataController.filteredSpecificTeamMember.length,
                                  scrollDirection: Axis.vertical,
                                ),
                              ))
                            ],
                          );
                        },
                        itemCount: dataController.allTeams.length,
                        scrollDirection: Axis.vertical,
                      ),
                    ))),
          ElevatedButton(
              onPressed: () {
                var senderName = dataController.myDocument?.get('firstname');
                UserHelper.sendOutGroupNotifications(_tempSelectedMemberTokens, senderName);
                Get.back();
              },
              child: Text('Done')),
        ],
      ),
    );
  }
}
