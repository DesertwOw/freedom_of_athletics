
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/screens/functionalityScreens/login.dart';
import 'package:freedom_of_athletics/services/DataController.dart';
import 'package:freedom_of_athletics/services/auth_helper.dart';
import 'package:freedom_of_athletics/widgets/my_account_widgets.dart';
import 'package:freedom_of_athletics/widgets/profile_page_view.dart';
import 'package:get/get.dart';
class MyAccount extends StatefulWidget {
  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {


  State<MyAccount> createState() => _MyAccountState();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  DataController? dataController;

  @override
  void initState() {
    super.initState();
    dataController = Get.find<DataController>();


    firstNameController.text = dataController!.myDocument!.get('firstname');
    lastNameController.text = dataController!.myDocument!.get("lastname");
    emailController.text = dataController!.myDocument!.get("email");
    passwordController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 50, bottom: 20),
                    width: 30,
                    height: 30,
                  ),
                ),
              ],
            ),
            ProfPic(),
            const SizedBox(
              height:20,
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
            TextButton(
              child: const Text("Update"),
              onPressed: () async {
                try {
                    UserHelper.updateUserData(firstNameController.text,lastNameController.text,passwordController.text,emailController.text);
                } catch (e) {
                  print(e);
                }
              },
            ),
            TextButton(
              child: const Text("Log out"),
              onPressed: () async {
                try {
                  AuthHelper.logOut();
                  Get.to(() => LoginPage());
                } catch (e) {
                  print(e);
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

