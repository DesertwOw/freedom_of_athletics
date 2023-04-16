import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/screens/admin_home.dart';
import 'package:freedom_of_athletics/screens/functionalityScreens/login.dart';
import 'package:freedom_of_athletics/screens/organizer_home.dart';
import 'package:freedom_of_athletics/services/auth_helper.dart';
import 'package:freedom_of_athletics/services/fcm_handler.dart';
import 'package:get/get.dart';
import '../services/DataController.dart';
import '../widgets/reusable_widget.dart';
import 'player_home.dart';

class ChooseYourSide extends StatefulWidget{
  @override
  State<ChooseYourSide> createState() => _ChooseYourSideState();
}

class _ChooseYourSideState extends State<ChooseYourSide>{
  @override
  void initState() {
    Get.put(DataController(),permanent: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
      return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context,snapshot){
          if(snapshot.hasData && snapshot.data != null) {
          UserHelper.saveUser(snapshot.data);
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection("users").doc(snapshot.data!.uid).snapshots(),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
              if(snapshot.hasData && snapshot.data != null){
                final userDoc = snapshot.data;
                if(userDoc!['role'] == 'admin'){
                  return AdminHomePage();
                }
              }
              return ChooseRole();
            }
          );
        }
          return LoginPage();
        }
      );
  }
}

class ChooseRole extends StatelessWidget {
  const ChooseRole({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => showExitPopup(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update(
                      {'type':'organizer',});
                  LocalNotificationService.storeToken();
                  Get.to(
                          () => const OrganizerHome());
                },
                child: Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                              colors: [Colors.blueAccent,Colors.white],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter
                          )
                      ),
                      child: const Center(
                        child: Text(
                          'Organizer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update(
                      {'type':'player',});
                  LocalNotificationService.storeToken();
                  Get.to(
                          () => PlayerHomePage());
                },
                child: Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [Colors.blueAccent,Colors.white],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter
                        )
                      ),
                      child:  const Center(
                        child: Text(
                          'Player',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


