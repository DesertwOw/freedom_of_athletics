import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/screens/functionalityScreens/login.dart';
import 'package:freedom_of_athletics/screens/organizer_home.dart';

class Settings extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _SettingsState();

}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: FlatButton(
          onPressed: () 
          {
            FirebaseAuth.instance.signOut();
            Navigator.push(context, MaterialPageRoute(builder: (_) =>LoginPage()));
          },
          child: Column(
              children: <Widget>[
              Icon(Icons.delete),
            Text("Quit")
              ],
          ),
        )
      ),
    );
  }
}

