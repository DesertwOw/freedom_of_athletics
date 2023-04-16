import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {


  String _serverKey = 'AAAAJ95cZjg:APA91bH2_VxmovLwIKISEN-mysIMcEE5W89o05yCJkK7cFFi4wwuf4l939SKBwul2UnRM8RqzpcD4834ZAoW-0iB6Sb9vZVM3E35B-bgfZcTzEvJk-Go_qBln4FpMPs2q6VObGKO9bXG';

  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static void initialize() {
    const InitializationSettings initializationSettings =
    InitializationSettings(
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
        android: AndroidInitializationSettings("@mipmap/ic_launcher"));
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static void display(RemoteMessage message) async{
    try {
      Random random = new Random();
      int id = random.nextInt(1000);

      const NotificationDetails notificationDetails = NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
          android: AndroidNotificationDetails(
            "mychanel",
            "my chanel",
            importance: Importance.max,
            priority: Priority.high,
          )

      );
      await _flutterLocalNotificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,);
    } on Exception catch (e) {
      print('Error>>>$e');
    }
  }

  static Future<void> sendNotification(
      String? title, String? message, String? token) async {
    String serverKey = LocalNotificationService()._serverKey;
    final data = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      'message': message
    };

    try {
      http.Response r = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':

          'key=$serverKey',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{'body': message, 'title': title},
            'priority': 'high',
            'data': data,
            "to": "$token"
          },
        ),
      );

      if (r.statusCode == 200) {
        print('Done');
      } else {
        print(r.statusCode);
      }
    } catch (e) {
      print('exception $e');
    }
  }


  static storeToken() async {
    try{
      String? token = await FirebaseMessaging.instance.getToken();
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({'fcmToken': token!}, SetOptions(merge: true));

    }catch(e){
      print("error is $e");
    }
  }

}