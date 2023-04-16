import 'package:flutter/gestures.dart';
import 'package:freedom_of_athletics/screens/functionalityScreens/signup.dart';
import 'package:freedom_of_athletics/screens/the_choice.dart';
import 'package:freedom_of_athletics/services/auth_helper.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/utils/color_utils.dart';
import 'package:freedom_of_athletics/widgets/reusable_widget.dart';
import 'package:get/get.dart';
import 'package:icon_loading_button/icon_loading_button.dart';
import 'package:iconsax/iconsax.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  final IconButtonController _btnController1 = IconButtonController();




  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).size.height * 0.2, 20, 0),
              child: Column(
                children: <Widget>[
                  //logoWidget("assets/images/logo1.png"),
                  const SizedBox(
                    height: 30,
                  ),
                  reusableTextField("Enter Username", Iconsax.user, emailTextController),
                  const SizedBox(
                    height: 20,
                  ),
                  PasswordField(icon: Iconsax.password_check, labelText: 'Enter password', hintText: 'Enter your password', controller: passwordTextController,),
                  const SizedBox(
                    height: 40,
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Expanded(
                      child: IconLoadingButton(
                        color: Colors.white,
                        iconColor: const Color(0xff0066ff),
                        valueColor: const Color(0xff0066ff),
                        errorColor: const Color(0xffe0333c),
                        successColor: const Color(0xff58B09C),
                        iconData: Icons.login,
                        onPressed: () async {
                          try {
                            final user = await AuthHelper.signInWithEmail(
                                email: emailTextController.text,
                                password: passwordTextController.text);
                            if (user != null) {
                              Future.delayed(const Duration(seconds: 2), () {
                                _btnController1.success();
                                _btnController1.reset();
                              });
                              Get.to(
                                      () => ChooseYourSide());

                            }
                          } catch (e) {
                            Future.delayed(const Duration(seconds: 1), () {
                              _btnController1.error();
                              Future.delayed(const Duration(seconds: 1), () {
                                _btnController1.reset();
                                GlobalSnackBar.show(context, 'Email or password Wrong');
                              });
                            });
                          }
                        },
                        successIcon: Icons.check,
                        controller: _btnController1,
                        child: const Text(
                          'Login',
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                  ]),
                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            const TextSpan(text: 'If you new to us, you can '),
                            TextSpan(
                                text: 'Sign Up ',
                                style: const TextStyle(fontSize: 16.0),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Get.to(
                                            () => SignupPage());
                                  }),
                            const TextSpan(text: 'here!')
                          ],
                        ),
                      )
                    ],
                  )
                ],
              )),
        ),
      ),
    );
  }
}
