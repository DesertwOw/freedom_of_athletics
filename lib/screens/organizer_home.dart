import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:freedom_of_athletics/screens/functionalityScreens/my_events.dart';
import 'package:freedom_of_athletics/screens/functionalityScreens/organise.dart';
import 'package:freedom_of_athletics/screens/functionalityScreens/profile.dart';
import 'package:freedom_of_athletics/screens/functionalityScreens/teams.dart';
import 'package:freedom_of_athletics/utils/color_utils.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';

import '../services/DataController.dart';
import '../services/fcm_handler.dart';
import 'functionalityScreens/EventsCreatedByMe.dart';
import 'functionalityScreens/recruitment.dart';

class OrganizerHome extends StatefulWidget {
  const OrganizerHome({Key? key}) : super(key: key);

  @override
  State<OrganizerHome> createState() => _OrganizerHomeState();
}

class _OrganizerHomeState extends State<OrganizerHome> {

  int index = 2;

  final organizerScreens = [
    Teams(),
    Recruitment(),
    Organize(),
    EventsCreatedByMe(),
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
      body: organizerScreens[index],
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
          destinations: const [
            NavigationDestination(
              icon: Icon(
                Icons.group,
                size: 30.0,
              ),
              label: 'Teams',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.group_add_outlined,
                size: 30.0,
              ),
              label: 'Recruitment',
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
