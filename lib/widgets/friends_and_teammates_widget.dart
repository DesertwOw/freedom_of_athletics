import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/screens/profileScreens/event_creator_profile.dart';
import 'package:get/get.dart';

import '../services/DataController.dart';


Widget friendWidget(DocumentSnapshot user,String text,String image){
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {},
                child: Row(
                    children: [
                        Container(
                              width: 80,
                              height: 80,
                              margin: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(image),
                                  ),
                              ),
                        ),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    SizedBox(height: 16),
                                    Text(
                                        text,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                        ),
                                    ),
                                    SizedBox(height: 8),
                                    Divider(),
                                ],
                            ),
                        ),
                    ],
                ),
            ),
        ),
    );
}