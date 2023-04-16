import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:freedom_of_athletics/screens/functionalityScreens/browse_events.dart';
import 'package:freedom_of_athletics/screens/functionalityScreens/browse_teams.dart';
import 'package:flutter/material.dart';

import 'package:freedom_of_athletics/screens/functionalityScreens/my_events.dart';
import 'package:freedom_of_athletics/screens/functionalityScreens/profile.dart';

import 'package:freedom_of_athletics/services/DataController.dart';
import 'package:freedom_of_athletics/services/auth_helper.dart';
import 'package:freedom_of_athletics/utils/color_utils.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';

import '../services/fcm_handler.dart';
import 'functionalityScreens/myTeams.dart';


class PlayerHomePage extends StatefulWidget {
  @override
  State<PlayerHomePage> createState() => _PlayerHomePageState();
}

class _PlayerHomePageState extends State<PlayerHomePage> {
  int index = 2;

  final playerScreens = [
    BrowseTeams(),
    myTeam(),
    BrowseEvents(),
    MyEvents(),
    Profile(),
  ];




  @override
  void initState() {
    super.initState();
    Get.put(DataController(),permanent: true);
    FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onMessage.listen((message){
      LocalNotificationService.display(message);
    });
    LocalNotificationService.storeToken();

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: playerScreens[index],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Colors.blue.shade100,
          labelTextStyle: MaterialStateProperty.all(
            TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        child: NavigationBar(
          height: 60,
          backgroundColor: Colors.white,
          selectedIndex: index,
          onDestinationSelected: (index) => setState(() => this.index = index),
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.group,
                size: 30.0,
              ),
              label: 'Teams',
            ),
            NavigationDestination(
              icon: Icon(
                Iconsax.people5,
                size: 30.0,
              ),
              label: 'My Teams',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.home,
                size: 30.0,
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.event,
                size: 30.0,
              ),
              label: 'My Events',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.person,
                size: 30.0,
              ),
              label: 'Person',
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Welcome to Freeletics'),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
    );
  }
}
