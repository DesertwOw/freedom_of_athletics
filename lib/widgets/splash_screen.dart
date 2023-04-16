import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:freedom_of_athletics/screens/functionalityScreens/login.dart';
import 'package:freedom_of_athletics/screens/the_choice.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class SplashScreen extends StatefulWidget{
  const SplashScreen({Key? key}) : super(key: key);
  @override
  State<SplashScreen> createState() => _SplashScreenState();

}

class _SplashScreenState extends State<SplashScreen>{

  @override
  void initState(){
    super.initState();

    Future.delayed(Duration(seconds: 4)).then((value) async {
      if(await FirebaseAuth.instance.currentUser != null){
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) =>  ChooseYourSide(),
        ));
      }
      else{
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) =>  LoginPage(),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Image.asset(
            'assets/Freedom of Athletics.png',
            fit: BoxFit.scaleDown,
            width: Get.width,
            height: Get.height,
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: SpinKitPumpingHeart(
                color: Colors.blueAccent,
                size: 50.0,
              ),
            ),
          ),
        ],
      ),
    );
  }


}
