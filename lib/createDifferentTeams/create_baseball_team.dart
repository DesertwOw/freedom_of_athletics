import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/models/media.dart';
import 'package:freedom_of_athletics/services/DataController.dart';
import 'package:freedom_of_athletics/services/auth_helper.dart';
import 'package:freedom_of_athletics/widgets/teamWidgets/team_badge_widget.dart';
import 'package:get/get.dart';
import 'package:freedom_of_athletics/widgets/reusable_widget.dart';

import '../utils/carousel_localdata_feed.dart';

class CreateBaseballTeam extends StatefulWidget {
  const CreateBaseballTeam({Key? key}) : super(key: key);

  @override
  State<CreateBaseballTeam> createState() => _CreateBaseballTeamState();
}

class _CreateBaseballTeamState extends State<CreateBaseballTeam> {
  TextEditingController teamName = TextEditingController();
  TextEditingController shortName = TextEditingController();
  TextEditingController description = TextEditingController();
  List<EventMediaModel> media = [];
  List<Map<String, dynamic>> mediaUrls = [];
  String? _selectedPicture;

  void resetControllers() {
    teamName.clear();
    shortName.clear();
    description.clear();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  var isCreatingTeam = false.obs;
  int _currentIndex = 0;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const SizedBox(
                  height: 100,
                ),
                const Center(
                    child: Text(
                  "Baseball team",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                )),
                const SizedBox(
                  height: 30,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final result = await showDialog(
                          context: context,
                          builder: (_) =>
                              PictureSelectionDialog(pictures: pictures),
                        );

                        setState(() {
                          _selectedPicture = result;
                        });
                      },
                      child: Text('Select Picture'),
                    ),
                    SizedBox(height: 20),
                    if (_selectedPicture != null)
                      Image.network(
                        _selectedPicture!,
                        width: 150,
                        height: 150,
                      ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: myTextField(
                        bool: false,
                        icon: 'assets/4DotIcon.png',
                        text: 'Insert your team name',
                        controller: teamName,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                        child: myTextField(
                      bool: false,
                      icon: 'assets/4DotIcon.png',
                      text: 'Insert your 3 letter nickname',
                      controller: shortName,
                    )),
                    const Expanded(child: SizedBox(width: 10)),
                    const Text("Player's count:"),
                    Expanded(
                      child: DropdownButton<int>(
                        value: _currentIndex,
                        items: List<DropdownMenuItem<int>>.generate(
                          9,
                              (index) => DropdownMenuItem(
                            value: index,
                            child: Text('$index'),
                          ),
                        ),
                        onChanged: (value) => setState(() => _currentIndex = value!),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        width: 380,
                        height: 149,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(width: 1, color: Colors.black),
                        ),
                        child: TextFormField(
                          maxLines: 5,
                          controller: description,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.only(top: 25, left: 15, right: 15),
                            hintStyle: TextStyle(
                              color: Colors.white,
                            ),
                            hintText:
                                'Write a summary and any details about your team',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Obx(() => isCreatingTeam.value
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : SizedBox(
                        height: 42,
                        width: double.infinity,
                        child: elevatedButton(
                            onpress: () async {
                              isCreatingTeam(true);

                              Get.put(DataController());
                              DataController dataController = Get.find();

                              Map<String, dynamic> teamData = {
                                'sport_category': 'Baseball',
                                'team_name': teamName.text,
                                'short_name': shortName.text,
                                'description': description.text,
                                'players_count': _currentIndex,
                                'badge': _selectedPicture,
                                'uid': FirebaseAuth.instance.currentUser!.uid,
                              };
                              await dataController
                                  .createTeam(teamData)
                                  .then((value) {
                                isCreatingTeam(false);
                                resetControllers();
                                UserHelper.createMembersSubCollection(
                                    dataController.myDocument!.id,
                                    dataController.myDocument!.get('firstname'),
                                    dataController.myDocument!.get('fcmToken'),
                                    dataController.myDocument!
                                        .get('profilePicture'),
                                    teamName.text,
                                    'Baseball');
                              });
                            },
                            text: 'Create Team'),
                      )),
              ],
            ),
          ),
        )));
  }
}
