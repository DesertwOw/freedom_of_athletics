import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/widgets/clipper.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../services/DataController.dart';
import '../../services/auth_helper.dart';
import '../../widgets/my_account_widgets.dart';
import '../../widgets/selectors/AdminSelectorForAddingMembersToTeams.dart';
import '../../widgets/selectors/AdminSelectorForRemovingMembersFromTeams.dart';

class AdminViewForTeam extends StatefulWidget {
  DocumentSnapshot team;

  AdminViewForTeam(this.team);

  @override
  State<AdminViewForTeam> createState() => _AdminViewForTeamState();
}

class _AdminViewForTeamState extends State<AdminViewForTeam> {

  DataController dataController = Get.find<DataController>();

   TextEditingController teamNameController = TextEditingController();
   TextEditingController shortNameController = TextEditingController();
   TextEditingController descriptionController = TextEditingController();
   TextEditingController sportCategoryController = TextEditingController();

  @override
  void initState() {
    teamNameController.text = widget.team.get('team_name');
    shortNameController.text = widget.team.get('short_name');
    descriptionController.text = widget.team.get('description');
    sportCategoryController.text = widget.team.get('sport_category');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    String badge = widget.team.get('badge');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipPath(
              clipper: EventViewClipper(),
              child: Container(
                height: MediaQuery.of(context).size.height * .60,
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(badge),
                      fit: BoxFit.cover
                    )
                  )
                ),
              ),
           Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${widget.team.get('team_name')}",
                  style: const TextStyle(
                      fontSize: 30,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Center(
              child: TextButton(onPressed: () => showDialog(
                  context: context,
                  builder: (context) {
                    return AdminSelectorForAddingMembersToTeams(widget.team);
                  }
              ),
                child: Text('Add Members'),
              ),
            ),
            SizedBox(height: 15,),
            Container(
              margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: Column(
                children: [
                  NameInputField(nameController: teamNameController,labelTexts: "Team Name", name: "Team Name"),
                  const SizedBox(
                    height:20,
                  ),
                  NameInputField(nameController: shortNameController,labelTexts: "Short Name", name: "Short Name"),
                  const SizedBox(
                    height:20,
                  ),
                  NameInputField(nameController: descriptionController, labelTexts: "Description", name: "Description"),
                  const SizedBox(
                    height:20,
                  ),
                  NameInputField(nameController: sportCategoryController, labelTexts: "Sport Category", name: "Sport Category"),
                  const SizedBox(
                    height:20,
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: TextButton(
                    child: const Text("Update"),
                    onPressed: () async {
                      try {
                        UserHelper.updateTeamData(widget.team.id, descriptionController.text, shortNameController.text, sportCategoryController.text, teamNameController.text);
                      } catch (e) {
                        print(e);
                      }
                    },
                  ),
                ),
                TextButton(onPressed: () => showDialog(
                    context: context,
                    builder: (context) {
                      return AdminSelectorForRemovingMembersFromTeams(widget.team);
                    }
                ),
                  child: Text('Remove Members'),
                ),
                TextButton(
                  child: const Text("Delete this team"),
                  onPressed: () async {
                    try{
                      UserHelper.DeleteTeam(widget.team.id);
                    } catch(e){
                      print(e);
                    }
                  },
                )
              ],)
          ],
        )
      )
    );
  }
}
