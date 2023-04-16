import 'package:freedom_of_athletics/screens/the_choice.dart';
import 'package:freedom_of_athletics/services/auth_helper.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/utils/color_utils.dart';
import 'package:freedom_of_athletics/widgets/reusable_widget.dart';
import 'package:freedom_of_athletics/utils/constants.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
  static int age = 20;
  static TextEditingController firstnameTextController = TextEditingController();
  static TextEditingController lastnameTextController = TextEditingController();
  static TextEditingController staticPasswordTextController = TextEditingController();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController confirmTextPasswordController = TextEditingController();
  final TextEditingController passwordTextController = SignupPage.staticPasswordTextController;


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                hexStringToColor("7EC8E3"),
                hexStringToColor("7EC8E3"),
                hexStringToColor("FFFFFF")
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 150, 20, 0),
                child: Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 20,
                    ),
                    reusableTextField("Enter Email Address", Iconsax.user,
                        emailTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    PasswordField(icon: Iconsax.password_check, labelText: 'Enter password', hintText: 'Enter your password', controller: passwordTextController,),
                    const SizedBox(
                      height: 20,
                    ),
                    PasswordField(icon: Iconsax.password_check, labelText: 'Confirm password', hintText: 'Confirm your password', controller: confirmTextPasswordController,),
                    const SizedBox(
                      height: 20,
                    ),
                    reusableTextField("Enter First name", Iconsax.user,
                        SignupPage.firstnameTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    reusableTextField("Enter Last name", Iconsax.user,
                        SignupPage.lastnameTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: <Widget>[
                        const Text(
                          'Select your age:   ',
                          style: kLabelTextStyle,
                        ),
                        Text(
                          SignupPage.age.toString(),
                          style: kNumberTextStyle,
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        inactiveTrackColor: const Color(0XFF8D8E98),
                        thumbColor: hexStringToColor("7EC8E3"),
                        activeTrackColor: Colors.white,
                        overlayColor: hexStringToColor("7EC8E3"),
                        thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 15.0),
                        overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 30.0),
                      ),
                      child: Slider(
                        value: SignupPage.age.toDouble(),
                        min: 14.0,
                        max: 99.0,
                        onChanged: (double newValue) {
                          setState(() {
                            SignupPage.age = newValue.round();
                          });
                        },
                      ),
                    ),
                    InkWell(
                      child: const Text("Signup",style: TextStyle(fontSize: 20),),
                      onTap: () async {
                        if (emailTextController.text.isEmpty ||
                            SignupPage.staticPasswordTextController.text.isEmpty) {
                          GlobalSnackBar(message: 'Email and password cannot be empty');
                          return;
                        }
                        if (confirmTextPasswordController.text.isEmpty ||
                            SignupPage.staticPasswordTextController.text !=
                                confirmTextPasswordController.text) {
                          GlobalSnackBar(message: 'Passwords does not match!');
                          return;
                        }
                        try {
                          final user = await AuthHelper.signupWithEmail(
                              email: emailTextController.text,
                              password: SignupPage.staticPasswordTextController.text);
                          if (user != null) {
                            GlobalSnackBar(message: 'Signup successful');
                            Get.to(() => ChooseYourSide());
                          }
                        } catch (e) {
                          print(e);
                        }
                      },
                    )
                  ],
                ),
              ))),
    );
  }
}