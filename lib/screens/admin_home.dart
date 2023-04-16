import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freedom_of_athletics/screens/adminScreens/allEvents.dart';
import 'package:freedom_of_athletics/screens/adminScreens/allTeams.dart';
import 'package:freedom_of_athletics/screens/adminScreens/allUsers.dart';
import 'package:freedom_of_athletics/screens/profileScreens/my_account.dart';
import 'package:freedom_of_athletics/services/auth_helper.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/widgets/custom_app_bar.dart';
import 'package:iconsax/iconsax.dart';

import 'adminScreens/createAdminAccount.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {

  int index = 3;

  final adminScreens = [
      allUsers(),
      allTeams(),
      allEvents(),
      createAdminAccount(),
      MyAccount(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: adminScreens[index],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Colors.blueAccent,
          labelTextStyle: MaterialStateProperty.all(
            TextStyle(fontSize: 14,fontWeight: FontWeight.w500),
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
                  Iconsax.user,
                  size: 20.0,
                ),
                label: 'Users'),
            NavigationDestination(
                icon: Icon(
                  Icons.group,
                  size: 20.0,
                ),
                label: 'My Teams'),
            NavigationDestination(
                icon: Icon(
                  Icons.event,
                  size: 20.0,
                ),
                label: 'Events'),
            NavigationDestination(
                icon: Icon(
                  Iconsax.user_add,
                  size: 20.0,
                ),
                label: 'Add admin'),
            NavigationDestination(
                icon: Icon(
                  Icons.verified_user,
                  size: 20.0,
                ),
                label: 'My Profile'),
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
