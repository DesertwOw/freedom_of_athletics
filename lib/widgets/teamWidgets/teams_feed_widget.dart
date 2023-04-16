import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/screens/adminScreens/team_view_for_admin.dart';
import 'package:freedom_of_athletics/screens/profileScreens/event_creator_profile.dart';
import 'package:freedom_of_athletics/services/DataController.dart';
import 'package:freedom_of_athletics/widgets/teamWidgets/team_page_view.dart';
import 'package:freedom_of_athletics/widgets/teamWidgets/team_page_view_for_organizers.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

Widget buildCard({String? image, text, Function? func, DocumentSnapshot? teamData}){
  return Stack(
    children: <Widget>[
      Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 20,right: 20),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22.0),
              shadowColor: Colors.black87,
              elevation: 20.0,
              child: Column(
                children: [
                  InkWell(
                    onTap: (){
                      func!();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(image!), fit: BoxFit.fill
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      width: 350,
                      height: Get.width * 0.6,
                    ),
                  ),
                  Padding(padding: const EdgeInsets.all(8),
                    child: Row(children: <Widget>[
                      Text(
                        teamData!.get('team_name').toString(),
                        style: TextStyle(fontSize: 18),
                      ),
                      Spacer(),
                      Text(
                        teamData.get('short_name').toString(),
                        style: TextStyle(fontSize: 18),
                      )
                    ],),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance.collection('teams').doc(teamData.id).collection('members').get(),
                          builder: (context,snapshot){
                            if(snapshot.hasData){
                              int size = snapshot.data!.size;
                              return Row(
                                children: [
                                  Text('Csapattagok száma:'),
                                  RichText(
                                    text: TextSpan(
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: size.toString(),
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        TextSpan(
                                          text: '/',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        TextSpan(
                                          text: teamData
                                              .get('players_count')
                                              .toString(),
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return CircularProgressIndicator();
                            }
                          }
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
      Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 300),
            height: 250,
            width: 400,
            child: Container(
              width: Get.width,
              height: 50,
              padding: EdgeInsets.only(left: 45),
            ),
          )
        ],
      )
    ],
  );
}

teamItem(DocumentSnapshot team){
  DataController dataController = Get.find<DataController>();

  DocumentSnapshot user =
      dataController.allUsers.firstWhere((e) => team.get('uid') == e.id);

  String image = '';
  try{
    image = user.get('profilePicture');
  } catch(e){
    image = '';
  }

  return Column(
    children: [
      Row(
        children: [
          InkWell(
            onTap: (){
              Get.to(() => EventCreatorProfile(user));
            },
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.blue,
              backgroundImage: NetworkImage(image),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Text(
            '${user.get('firstname')}${user.get('lastname')}',
          ),
        ],
      ),
      SizedBox(
        height: Get.height * 0.01,
      ),
      buildCard(
        text: team.get('team_name'),
        teamData: team,
        image: team.get('badge'),
        func: (){
          if (FirebaseAuth.instance.currentUser!.uid == team.get('uid')) {
            Get.to(() => TeamPageViewForOrganizers(team, user));
          } else if(dataController.myDocument?.get('role') == 'admin') {
            Get.to(() => AdminViewForTeam(team));
          } else {
            Get.to(() => TeamPageView(team, user));
          }
        }
      ),
      const SizedBox(
        height: 45,
      )
    ],
  );
}