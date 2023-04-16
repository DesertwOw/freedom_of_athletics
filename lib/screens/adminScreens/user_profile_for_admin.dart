import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/widgets/selectors/admin_selector_for_adding_events_to_users.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../services/DataController.dart';
import '../../services/auth_helper.dart';
import '../../widgets/reusable_widget.dart';
import '../../widgets/selectors/admin_selector_for_user_events.dart';
import '../../widgets/my_account_widgets.dart';

class UserProfileForAdmin extends StatefulWidget {
  DocumentSnapshot user;

  UserProfileForAdmin(this.user);



  @override

  State<UserProfileForAdmin> createState() => _UserProfileForAdminState();
}

class _UserProfileForAdminState extends State<UserProfileForAdmin> {
  DataController dataController = Get.find<DataController>();

  static TextEditingController firstNameController = TextEditingController();
  static TextEditingController lastNameController = TextEditingController();
  static TextEditingController emailController = TextEditingController();
  static TextEditingController passwordController = TextEditingController();


  @override
  void initState() {
    firstNameController.text = dataController.myDocument!.get('firstname');
    lastNameController.text = dataController.myDocument!.get("lastname");
    emailController.text = dataController.myDocument!.get("email");
    passwordController.text = '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    String image = '';

    try{
      image = widget.user.get('profilePicture');
    }catch(e){
      image = '';
    }

    String? name = widget.user.get('firstname');

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: (){
                  Get.back();
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 50,bottom: 20),
                  width: 30,
                  height: 30,
                ),
              ),
              Center(
                child: CircleAvatar(
                  backgroundImage: NetworkImage(image),
                  radius: 100,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: Text(
                  name!,
                  style: const TextStyle(
                    fontSize: 25,
                    color: Colors.black,
                    fontWeight: FontWeight.w600
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(onPressed: () => showDialog(
                      context: context,
                      builder: (context) {
                        return AdminSelectorForUserEvents(widget.user);
                      }
                  ),
                    child: Text('View participatings'),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
                child: Column(
                  children: [
                    EmailField(emailController: emailController),
                    const SizedBox(
                      height:20,
                    ),
                    ProfilePasswordField(passwordController: passwordController),
                    const SizedBox(
                      height:20,
                    ),
                    NameInputField(nameController: firstNameController, labelTexts: "Firstname", name: "Firstname"),
                    const SizedBox(
                      height:20,
                    ),
                    NameInputField(nameController: lastNameController, labelTexts: "Lastname", name: "Lastname"),
                    const SizedBox(
                      height:20,
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(onPressed: () => showDialog(
                      context: context,
                      builder: (context) {
                        return AdminSelectorForAddingEventsToUsers(widget.user);
                      }
                  ),
                    child: Text('View Events to participate'),
                  ),
                  Center(
                    child: TextButton(
                      child: const Text("Update"),
                      onPressed: () async {
                        try {
                          UserHelper.updateUserData(firstNameController.text,lastNameController.text,passwordController.text,emailController.text);
                        } catch (e) {
                          print(e);
                        }
                      },
                    ),
                  ),
                  TextButton(
                    child: const Text("Delete this account"),
                    onPressed: () async {
                      try {
                        await UserHelper.deleteUserAccount(widget.user.get('uid'));
                      } catch (e) {
                        e.printError();
                      }
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      )
    );
  }
}
