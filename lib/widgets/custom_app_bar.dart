import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/screens/profileScreens/Invitations.dart';
import 'package:get/get.dart';

import 'package:freedom_of_athletics/widgets/reusable_widget.dart';

import '../screens/profileScreens/my_account.dart';
import '../services/DataController.dart';

Widget customAppBar(){

  DataController dataController = Get.find<DataController>();

  DocumentSnapshot user =
  dataController.allUsers.firstWhere(
          (e) => e.id == FirebaseAuth.instance.currentUser?.uid);

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 15),
    child: Row(
      children: [
        SizedBox(
          width: 260,
          height: 17,
          child: myText(
              text: 'Freedom Of Athletics',
              style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,fontSize: 16)),
        ),
        const Spacer(),
        SizedBox(
          width: 24,
          height: 22,
          child: InkWell(
            onTap: () {
              Get.to(() => Invitations(user));
            },
            child: Image.asset('assets/bell.png'),
          ),
        ),
        SizedBox(
          width: Get.width * 0.04,
        ),
        InkWell(
          onTap: () {
            Get.to(() =>  MyAccount());
          },
          child: SizedBox(
            width: 22,
            height: 20,
            child: Image.asset(
              'assets/settings.png',
            ),
          ),
        ),
      ],
    ),
  );

}