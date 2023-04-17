import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/services/auth_helper.dart';
import 'package:freedom_of_athletics/widgets/custom_app_bar.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../widgets/my_account_widgets.dart';
import '../../widgets/reusable_widget.dart';

class createAdminAccount extends StatefulWidget {
  @override
  _createAdminAccountState createState() => _createAdminAccountState();
}

class _createAdminAccountState extends State<createAdminAccount> {
  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  final TextEditingController firstnameTextController = TextEditingController();
  final TextEditingController lastnameTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: customAppBar(),
            ),
            Text(
              'Create an Admin account',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                    margin:
                    const EdgeInsets.only(top: 50, bottom: 20),
                    width: 30,
                    height: 30,
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: Column(
                children: [
                  EmailField(
                    emailController: emailTextController,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  NameInputField(
                    nameController: firstnameTextController,
                    labelTexts: "Firstname",
                    name: "Firstname",
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  NameInputField(
                    nameController: lastnameTextController,
                    labelTexts: "Lastname",
                    name: "Lastname",
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ProfilePasswordField(
                    passwordController: passwordTextController,
                  ),
                  TextButton(
                    child: const Text("Create"),
                    onPressed: () async {
                      try {
                        UserHelper.createAdmin(
                            emailTextController.text,
                            firstnameTextController.text,
                            lastnameTextController.text,
                            passwordTextController.text);
                      } catch (e) {
                        print(e);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}