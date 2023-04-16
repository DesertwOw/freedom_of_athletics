import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/services/DataController.dart';
import 'package:freedom_of_athletics/services/fcm_handler.dart';
import 'package:freedom_of_athletics/screens/functionalityScreens/signup.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:io';

class AuthHelper {
  static FirebaseAuth _auth = FirebaseAuth.instance;

  static signInWithEmail({required String email, required String password}) async {
    final res = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    final User? user = res.user;
    return user;
  }

    static signupWithEmail({required String email, required password}) async {
      final res = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final User? user = res.user;
      return user;
    }

  static logOut() {
    return _auth.signOut();
  }
}

class UserHelper {
  static FirebaseFirestore _db = FirebaseFirestore.instance;
  final String apiUrl = 'https://mysterious-pajamas-cod.cyclic.app';

  static saveUser(User? user) async {
    int age = SignupPage.age;
    TextEditingController firstnameController = SignupPage.firstnameTextController;
    TextEditingController lastnameController = SignupPage.lastnameTextController;
    TextEditingController passwordController = SignupPage.staticPasswordTextController;

    Map<String, dynamic> userData = {
      "firstname": firstnameController.text,
      "lastname": lastnameController.text,
      "password": passwordController.text.hashCode,
      "email": user!.email,
      "last_login": user.metadata.lastSignInTime!.millisecondsSinceEpoch,
      "created_at": user.metadata.creationTime!.millisecondsSinceEpoch,
      "role": "user",
      "age" : age,
      "fcmToken" : '',
      'uid' : user.uid,
      "type" : "not yet specified",
      "profilePicture" : "https://firebasestorage.googleapis.com/v0/b/freedom-of-athletics-d4d04.appspot.com/o/profpics%2FprofilePicture.png?alt=media&token=ec571e70-8af6-435f-bd57-49cec1cd6434"
    };
    final userRef = _db.collection("users").doc(user.uid);
    if ((await userRef.get()).exists) {
      await userRef.update({
        "last_login": user.metadata.lastSignInTime!.millisecondsSinceEpoch,
      });
    } else {
      await _db.collection("users").doc(user.uid).set(userData);
    }
  }

  static void DeleteFriendRequest(String senderUid, String receiverUid) async{
    CollectionReference senderRequestSubCollection = _db.collection('users').doc(receiverUid).collection('friendRequests');
    CollectionReference receiverRequestSubCollection = _db.collection('users').doc(senderUid).collection('friendRequests');

    QuerySnapshot qSSender = await senderRequestSubCollection.where('Uid',isEqualTo: senderUid).get();
    QuerySnapshot qSReceiver = await receiverRequestSubCollection.where('Uid',isEqualTo: receiverUid).get();

    if(qSSender.docs.length > 0){
      String docID = qSSender.docs[0].id;
      await senderRequestSubCollection.doc(docID).delete();
    }
    if(qSReceiver.docs.length > 0){
      String docID = qSReceiver.docs[0].id;
      print(docID);
      await receiverRequestSubCollection.doc(docID).delete();
    }
  }

  static void DeleteFriend(String senderUid, String receiverUid) async{
    CollectionReference senderFriendSubCollection = _db.collection('users').doc(senderUid).collection('friends');
    CollectionReference receiverFriendSubCollection = _db.collection('users').doc(receiverUid).collection('friends');

    QuerySnapshot qSSender = await senderFriendSubCollection.where('Uid',isEqualTo: receiverUid).get();
    QuerySnapshot qSReceiver = await receiverFriendSubCollection.where('Uid',isEqualTo: senderUid).get();

    if(qSSender.docs.length > 0){
      String docID = qSSender.docs[0].id;
      await senderFriendSubCollection.doc(docID).delete();
    }

    if(qSReceiver.docs.length > 0){
      String docID = qSReceiver.docs[0].id;
      await receiverFriendSubCollection.doc(docID).delete();
    }
  }

  static void RemoveParticipant(String eventUid, String userUid)async{
    CollectionReference participantSubcollection = _db.collection('events').doc(eventUid).collection('participants');
    CollectionReference participatingInEventsSubcollection = _db.collection('users').doc(userUid).collection('participatingInEvents');

    QuerySnapshot qsEvent = await participantSubcollection.where('Uid',isEqualTo: userUid).get();
    QuerySnapshot qsUser = await participatingInEventsSubcollection.where('Uid',isEqualTo: userUid).get();

    if(qsEvent.docs.length > 0){
      String docID = qsEvent.docs[0].id;
      await participantSubcollection.doc(docID).delete();
    }

    if(qsUser.docs.length > 0){
      String docID = qsUser.docs[0].id;
      await participatingInEventsSubcollection.doc(docID).delete();
    }

}


  static void RemoveMember(String teamUid, String userUid) async{
    CollectionReference memberSubcollection = _db.collection('teams').doc(teamUid).collection('members');
    CollectionReference memberToATeamSubcollection = _db.collection('users').doc(userUid).collection('memberToATeam');

    QuerySnapshot qsTeam = await memberSubcollection.where('user_Uid',isEqualTo: userUid).get();
    QuerySnapshot qsUser = await memberToATeamSubcollection.where('user_Uid',isEqualTo: userUid).get();

    if(qsTeam.docs.length > 0){
      String docID = qsTeam.docs[0].id;
      await memberSubcollection.doc(docID).delete();
    }

    if(qsUser.docs.length > 0){
      String docID = qsUser.docs[0].id;
      await memberToATeamSubcollection.doc(docID).delete();
    }
  }

  static Future<void> removeMembers(String teamUid, List<String> userIds,String value) async{
    CollectionReference membersCollection = _db.collection('teams').doc(teamUid).collection('members');
    for(String userId in userIds){
      await membersCollection.doc(userId).delete();
    }

    CollectionReference memberToATeamCollection = _db.collection('users').doc(value).collection('memberToATeam');
    QuerySnapshot snapshot = await memberToATeamCollection.where('user_Uid', isEqualTo: value).get();

    for(DocumentSnapshot doc in snapshot.docs){
      await doc.reference.delete();
    }
  }
  static void addMembersToATeamByAdmin(List<String> users, String teamDoc, String userName, String profilePicture,String teamCategory, String teamName,String teamID) async {
    CollectionReference team = _db.collection('teams').doc(teamDoc).collection('members');
    users.forEach((userID,) async {
      final createdDocumentRef = team.doc();
      await createdDocumentRef.set({
        'Uid' : teamID,
        'firstname' : userName,
        'inviteAcceptedAt' : DateTime.now(),
        'memberProfilePicture' : profilePicture,
        'team_category' : teamCategory,
        'team_name' : teamName,
        'user_Uid' : userID,
      });
    });

    users.forEach((userId) async{
      CollectionReference invToUser = _db.collection('users').doc(userId).collection('memberToATeam');
      final createdDocumentRef = invToUser.doc();
      await createdDocumentRef.set({
        'Uid' : teamID,
        'user_Uid' : userId,
        'team_name' : teamName,
        'inviteAcceptedAt' : DateTime.now(),
      });
    });

  }

  static Future<void> removeParticipants(String eventUid, List<String> userIds) async {
    CollectionReference participantsCollection = FirebaseFirestore.instance
        .collection('events')
        .doc(eventUid)
        .collection('participants');

    for (String userId in userIds) {
      await participantsCollection.doc(userId).delete();
    }
  }



  static void DeleteJoiningToAnEventRequest(String eventUid, String receiverUid)async{
    CollectionReference eventRequestSubCollection = _db.collection('events').doc(eventUid).collection('eventInvitationRequests');
    CollectionReference receiverRequestSubCollection = _db.collection('users').doc(receiverUid).collection('eventInvitationRequests');

    QuerySnapshot qSEvent = await eventRequestSubCollection.where('Uid',isEqualTo: receiverUid).get();
    QuerySnapshot qSReceiver = await receiverRequestSubCollection.where('Uid',isEqualTo: eventUid).get();

    if(qSEvent.docs.length > 0){
      String docID = qSEvent.docs[0].id;
      print(docID);
      await eventRequestSubCollection.doc(docID).delete();
    }
    if(qSReceiver.docs.length > 0){
      String docID = qSReceiver.docs[0].id;
      print(docID);
      await receiverRequestSubCollection.doc(docID).delete();
    }
  }

  static void DeleteJoinAsAnIndividual(String eventUid, String receiverUid) async{
    CollectionReference eventRequestSubCollection = _db.collection('events').doc(eventUid).collection('joiningRequest');
    CollectionReference receiverRequestSubCollection = _db.collection('users').doc(receiverUid).collection('joiningRequest');

    QuerySnapshot qSEvent = await eventRequestSubCollection.where('Uid',isEqualTo: receiverUid).get();
    QuerySnapshot qSReceiver = await receiverRequestSubCollection.where('Uid',isEqualTo: eventUid).get();

    if(qSEvent.docs.length > 0){
      String docID = qSEvent.docs[0].id;
      print(docID);
      await eventRequestSubCollection.doc(docID).delete();
    }
    if(qSReceiver.docs.length > 0){
      String docID = qSReceiver.docs[0].id;
      print(docID);
      await receiverRequestSubCollection.doc(docID).delete();
    }
  }

  static void DeleteJoinAsAnIndividualToATeam(String teamDoc, String userUid) async{
    CollectionReference teamRequestSubCollection = _db.collection('teams').doc(teamDoc).collection('wantsToJoin');
    CollectionReference receiverRequestSubCollection = _db.collection('users').doc(userUid).collection('wantsToJoin');

    QuerySnapshot qsTeam = await teamRequestSubCollection.where('teamUid',isEqualTo: userUid).get();
    QuerySnapshot qsReceiver = await receiverRequestSubCollection.where('receverUid',isEqualTo: userUid).get();

    if(qsTeam.docs.length > 0){
      String teamDocID = qsTeam.docs[0].id;
      await teamRequestSubCollection.doc(teamDocID).delete();
    }

    if(qsReceiver.docs.length > 0){
      String userDocId = qsReceiver.docs[0].id;
      await receiverRequestSubCollection.doc(userDocId).delete();
    }
  }

  static void DeleteJoiningToATeamRequest(String senderUid, String receiverUid) async{
    CollectionReference senderRequestSubCollection = _db.collection('users').doc(senderUid).collection('teamInviteRequests');
    CollectionReference receiverRequestSubCollection = _db.collection('users').doc(receiverUid).collection('teamInviteRequests');

    QuerySnapshot qsSender = await senderRequestSubCollection.where('Uid',isEqualTo: receiverUid).get();
    QuerySnapshot qsReceiver = await receiverRequestSubCollection.where('Uid',isEqualTo: receiverUid).get();

    if(qsSender.docs.length > 0){
      String docID = qsSender.docs[0].id;
      await senderRequestSubCollection.doc(docID).delete();
    }


    if(qsReceiver.docs.length > 0){
      String docID = qsReceiver.docs[0].id;
      print(docID);
      await receiverRequestSubCollection.doc(docID).delete();
    }

  }

  static void DeleteJoiningRequest(String eventUid, String joinerUid) async{
    CollectionReference event = _db.collection('events').doc(eventUid).collection('eventInvitationRequests');
    QuerySnapshot qSEvent = await event.where('Uid',isEqualTo: joinerUid).get();

    if(qSEvent.docs.length > 0){
      String docID = qSEvent.docs[0].id;
      await event.doc(docID).delete();
    }

    CollectionReference user = _db.collection('users').doc(joinerUid).collection('eventInvitationRequests');
    QuerySnapshot qsUser = await user.where('Uid',isEqualTo: joinerUid).get();

    if(qsUser.docs.length > 0){
      String docId = qsUser.docs[0].id;
      await user.doc(docId).delete();
    }
  }

  static void LeaveEvent(String eventUid, String memberUid) async{
    CollectionReference event = _db.collection('events').doc(eventUid).collection('participants');
    QuerySnapshot qsEvent = await event.where('Uid',isEqualTo: eventUid).get();

    if(qsEvent.docs.length > 0){
      String docID = qsEvent.docs[0].id;
      await event.doc(docID).delete();
    }

    CollectionReference user = _db.collection('users').doc(memberUid).collection('participatingInEvents');
    QuerySnapshot qsUser = await user.where('Uid',isEqualTo: memberUid).get();

    if(qsUser.docs.length > 0){
      String docId = qsUser.docs[0].id;
      await user.doc(docId).delete();
    }
  }

  static void AddFriend(String senderName, String senderUid,String senderToken,String senderProfilePicture,String receiverUid, String receiverName,String receiverToken,String receiverProfilePicture){
    CollectionReference senderFriendsSubCollection = _db.collection('users').doc(receiverUid).collection('friends');
    CollectionReference receiverFriendsSubCollection = _db.collection('users').doc(senderUid).collection('friends');
    senderFriendsSubCollection.add({
      'Uid' : senderUid,
      'firstname' : senderName,
      'fcmToken' : senderToken,
      'requestReceived' : DateTime.now(),
      'profilePicture' : senderProfilePicture
    });
    receiverFriendsSubCollection.add({
      'Uid' : receiverUid,
      'firstname' : receiverName,
      'fcmToken' : receiverToken,
      'requestReceived' : DateTime.now(),
      'profilePicture' : receiverProfilePicture
    });
  }

  static void setTheRequestToASubcollection(String senderName,String senderUid,String senderToken,String senderProfilePicture,String receiverUid,String receiverName,String receiverToken,String receiverProfilePicture){
    CollectionReference senderRequestSubCollection = _db.collection('users').doc(senderUid).collection('friendRequests');
    CollectionReference receiverRequestSubCollection = _db.collection('users').doc(receiverUid).collection('friendRequests');
    senderRequestSubCollection.add({
      'Uid' : receiverUid,
      'firstname' : receiverName,
      'receiver_uid' : receiverUid,
      'fcmToken' : receiverToken,
      'requestReceived' : DateTime.now(),
      'profilePicture' : receiverProfilePicture
    });
    receiverRequestSubCollection.add({
      'Uid' : senderUid,
      'firstname' : senderName,
      'fcmToken' : senderToken,
      'requestReceived' : DateTime.now(),
      'profilePicture' : senderProfilePicture,
      'receiver_uid' : receiverUid,
    });
  }

  static bool isItForMe(String uid){
    if(uid == FirebaseAuth.instance.currentUser!.uid){
      return true;
    }
    return false;
  }

  static void createMembersSubCollection(String memberUid,String creatorName,String memberToken,String memberProfilePicture,String teamName,String teamCategory) async{
    CollectionReference team = _db.collection('teams');
    QuerySnapshot teamSnapshot = await team.where('uid',isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();
    if(teamSnapshot.docs.isNotEmpty){
      String documentID = teamSnapshot.docs.first.id;
      CollectionReference teamMember = _db.collection('teams').doc(documentID).collection('members');
      teamMember.add({
        'Uid' : memberUid,
        'user_Uid': memberUid,
        'team_name' : teamName,
        'team_category' : teamCategory,
        'firstname' : creatorName,
        'inviteAcceptedAt' : DateTime.now(),
        'memberToken' : memberToken,
        'memberProfilePicture' : memberProfilePicture
      });
    }

    CollectionReference user = _db.collection('users').doc(memberUid).collection('memberToATeam');
    user.add({
      'Uid' : memberUid,
      'team_name' : teamName,
      'team_category' : teamCategory,
      'userToken' : memberToken,
      'requestReceived' : DateTime.now(),
      'profilePicture' : memberProfilePicture
    });

  }
  static Future<void> AcceptTeamInv(String userId, String creatorID,String teamUid,String teamName,String userToken,String userName,String profilePicture, String teamBadge) async {
    CollectionReference invToUser = _db.collection('users').doc(userId).collection('memberToATeam');
    invToUser.add({
      'Uid' : teamUid,
      'user_Uid' : userId,
      'team_name' : teamName,
      'userToken' : userToken,
      'requestReceived' : DateTime.now(),
      'profilePicture' : profilePicture
    });
    CollectionReference team = _db.collection('teams');
    QuerySnapshot teamSnapshot = await team.where('uid',isEqualTo: creatorID).get();
    if(teamSnapshot.docs.isNotEmpty){
      String documentID = teamSnapshot.docs.first.id;
      CollectionReference teamMember = _db.collection('teams').doc(documentID).collection('members');
      teamMember.add({
        'Uid' : teamUid,
        'user_Uid' : userId,
        'firstname' : userName,
        'inviteAcceptedAt' : DateTime.now(),
        'memberToken' : userToken,
        'memberProfilePicture' : profilePicture
      });
    }

  }

  static AcceptInvitations(String userId, String eventDoc,String eventUid,String eventName,String userToken,String participantName,String profilePicture){
    CollectionReference event = _db.collection('events').doc(eventDoc).collection('participants');
    CollectionReference invToUser = _db.collection('users').doc(userId).collection('participatingInEvents');
    event.add({
      'Uid' : userId,
      'event_Uid': eventUid,
      'event_name' : eventName,
      'firstname' : participantName,
      'inviteAcceptedAt' : DateTime.now(),
      'profilePicture' : profilePicture
    });

    invToUser.add({
      'Uid' : userId,
      'event_name' : eventName,
      'userToken' : userToken,
      'requestReceived' : DateTime.now(),
      'event_Uid' : eventUid,
    });
  }



  static void addParticipantsToEventByAdmin(List<String> users, String eventDoc,String eventUid,String userName,String profilePicture,String eventName) async {
    CollectionReference event = _db.collection('events').doc(eventDoc).collection('participants');
    users.forEach((userID,) async {
      final createdDocumentRef = event.doc();
      await createdDocumentRef.set({
        'Uid' : userID,
        'firstname' : userName,
        'inviteAcceptedAt' : DateTime.now(),
        'profilePicuture' : profilePicture,
        'event_uid' : eventUid,
      });
    });

    users.forEach((userId) async{
      CollectionReference invToUser = _db.collection('users').doc(userId).collection('participatingInEvents');
      final createdDocumentRef = invToUser.doc();
      await createdDocumentRef.set({
        'Uid' : eventUid,
        'firstname' : userName,
        'event_name' : eventName,
        'inviteAcceptedAt' : DateTime.now(),
        'profilePicuture' : profilePicture,
      });
    });
  }



  static void sendOutEventInvitationRequests(List<String> userIds, String eventDoc,String eventUid,String eventName,String eventPicture,String inviterName,String inviterToken,String inviterProfilePicture){
    CollectionReference invToEvent = _db.collection('events').doc(eventDoc).collection('eventInvitationRequests');
    userIds.forEach((userId) async{
      final createdDocumentRef = invToEvent.doc();
      await createdDocumentRef.set({
        'Uid' : eventUid,
        'eventDoc' : eventDoc,
        'event_name' : eventName,
        'inviter_name' : inviterName,
        'event_picture': eventPicture
      });
    });

    userIds.forEach((userId) async{
      CollectionReference invToUser = _db.collection('users').doc(userId).collection('eventInvitationRequests');
      final createdDocumentRef = invToUser.doc();
      await createdDocumentRef.set({
        'Uid' : userId,
        'eventUid' : eventUid,
        'eventDoc' : eventDoc,
        'event_name' : eventName,
        'inviter_name' : inviterName,
        'inviterToken' : inviterToken,
        'inviterProfilePicture' : inviterProfilePicture,
        'event_picture': eventPicture
      });
    });
  }

  static void sendOutTeamInvitationRequests(List<String> userIds, String teamDoc,String teamUid,String teamName,String teamBadge,String inviterName,String inviterToken,String inviterProfilePicture){
    CollectionReference invToTeam = _db.collection('teams').doc(teamDoc).collection('teamInviteRequests');
    userIds.forEach((userId) async{
      final createdDocumentRef = invToTeam.doc();
      await createdDocumentRef.set({
        'Uid' : teamUid,
        'teamDoc' : teamDoc,
        'team_name' : teamName,
        'inviter_name' : inviterName,
        'team_badge': teamBadge
      });
    });

    userIds.forEach((userId) async{
      CollectionReference invToUser = _db.collection('users').doc(userId).collection('teamInviteRequests');
      final createdDocumentRef = invToUser.doc();
      await createdDocumentRef.set({
        'Uid' : DataController.instance.myDocument!.get('uid'),
        'senderToken': DataController.instance.myDocument!.get('fcmToken'),
        'whenTheRequestedToBeAMember' : DateTime.now(),
        'team_name' : teamName,
        'team_uid' : teamUid,
        'teamBadge' : teamBadge
      });
    });
  }



  static void sendOutGroupNotifications(List<String> userTokens, String senderName) {
    userTokens.forEach((userToken) {
      LocalNotificationService.sendNotification('You have a new event invitation', '$senderName invited you to an event!', userToken);
    });
  }

  static void JoiningRequestToAnEvent(String joinerToken,String joinerUid, String userId, String eventDoc,String eventUid,String eventName,String eventPicture,String inviterName,String inviterToken,String inviterProfilePicture) async{
    CollectionReference invToEvent = _db.collection('events').doc(eventDoc).collection('joiningRequest');
    invToEvent.add({
      'eventUid' : eventUid,
      'Uid' : joinerUid,
      'eventDoc' : eventDoc,
      'event_name' : eventName,
      'inviter_name' : inviterName,
      'event_picture': eventPicture,
      'joinerToken' : joinerToken
    });

    CollectionReference invToUser = _db.collection('users').doc(userId).collection('joiningRequest');
    invToUser.add({
      'receverUid' : userId,
      'Uid': joinerUid,
      'eventUid' : eventUid,
      'eventDoc' : eventDoc,
      'event_name' : eventName,
      'inviter_name' : inviterName,
      'inviterToken' : inviterToken,
      'inviterProfilePicture' : inviterProfilePicture,
      'event_picture': eventPicture
    });
  }

  static void JoinToAnEvent(String eventUid, String eventName, String eventCreatorToken, String userUid, String userName, String userToken, String userProfilePicture) {
    CollectionReference event = _db.collection('events').doc(eventUid).collection('wantsToJoin');
    event.add({
      'Uid' : userUid,
      'event_name' : eventName,
      'event_creator_token' : eventCreatorToken,
      'firstname' : userName,
      'userToken' : userToken,
      'userProfilePicture' : userProfilePicture
    });

    CollectionReference user = _db.collection('users').doc(userUid).collection('participatingInEvents');
    user.add({
      'Uid' : eventUid,
      'event_name' : eventName,
      'event_creator_token' : eventCreatorToken,
      'firstname' : userName,
      'userToken' : userToken,
      'userProfilePicture' : userProfilePicture
    });
  }

  static void JoinToATeam(String teamUid, String teamCategory,String teamName, String teamCreatorToken, String userUid, String userName, String userToken,String userProfilePicture){
    CollectionReference team = _db.collection('teams').doc(teamUid).collection('wantsToJoin');
    team.add({
      'Uid' : userUid,
      'team_category' : teamCategory,
      'team_name' : teamName,
      'team_creator_token' : teamCreatorToken,
      'userName' : userName,
      'userToken' : userToken,
      'userProfilePicture' : userProfilePicture
    });

    CollectionReference user = _db.collection('users').doc(userUid).collection('memberToATeam');
    user.add({
      'Uid' : teamUid,
      'team_category' : teamCategory,
      'team_name' : teamName,
      'team_creator_token' : teamCreatorToken,
      'userName' : userName,
      'userToken' : userToken,
      'userProfilePicture' : userProfilePicture
    });
  }


  static Future<bool> isUserDocumentExists(String docID, String colName,String subColName,String requiredField,String requiredValue) async {
    final subCollectionRef = FirebaseFirestore.instance.collection(colName).doc(docID).collection(subColName);

    final querySnapshot = await subCollectionRef.where(requiredField, isEqualTo: requiredValue).get();
    final documents = querySnapshot.docs;

    if (documents.length > 0) {
      return true;

    } else {
      return false;
    }
  }
  static Future<bool> isEventFull(int max,String eventDoc) async {
    final participants = await FirebaseFirestore.instance
        .collection('events')
        .doc(eventDoc)
        .collection('participants')
        .get();

    if (participants.size == max) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> isTeamFull(int max, String teamDoc) async{
    final members = await FirebaseFirestore.instance.collection('teams').doc(teamDoc).collection('members').get();

    if(members.size == max){
      return true;
    }
    else{
      return false;
    }
  }


  static Future<List<QueryDocumentSnapshot>> getEventsWhereITakePart() async {
    final CollectionReference events = FirebaseFirestore.instance.collection('events');
    final CollectionReference participatingInEvents = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('participatingInEvents');

    final QuerySnapshot participatingInEventsSnapshot = await participatingInEvents.get();
    final List<String> participatingInEventsIds = [];

    participatingInEventsSnapshot.docs.forEach((doc) {
      final data = doc.data();
      if (data is Map<String, dynamic>) {
        participatingInEventsIds.add(data['Uid'] as String);
      }
    });

    final QuerySnapshot eventsSnapshot = await events.where('uid', whereIn: participatingInEventsIds).get();

    final List<QueryDocumentSnapshot> participatingEvents = eventsSnapshot.docs.where((event) => participatingInEventsIds.contains(event['uid'])).toList();

    return participatingEvents;
  }

  static Future<List<QueryDocumentSnapshot>> getEventsWhereTheUserTakesPart(String userDoc) async {
    final CollectionReference events = FirebaseFirestore.instance.collection('events');
    final CollectionReference participatingInEvents = FirebaseFirestore.instance.collection('users').doc(userDoc).collection('participatingInEvents');

    final QuerySnapshot participatingInEventsSnapshot = await participatingInEvents.get();
    final List<String> participatingInEventsIds = [];

    participatingInEventsSnapshot.docs.forEach((doc) {
      final data = doc.data();
      if (data is Map<String, dynamic>) {
        participatingInEventsIds.add(data['event_Uid'] as String);
      }
    });

    final QuerySnapshot eventsSnapshot = await events.where('uid', whereIn: participatingInEventsIds).get();

    final List<QueryDocumentSnapshot> participatingEvents = eventsSnapshot.docs.where((event) => participatingInEventsIds.contains(event['uid'])).toList();

    return participatingEvents;
  }

  static Future<List<QueryDocumentSnapshot>> getTeamsWhereITakePart() async {
    final CollectionReference teams = FirebaseFirestore.instance.collection('teams');
    final CollectionReference memberToATeam = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('memberToATeam');

    final QuerySnapshot memberToATeamSnapshot = await memberToATeam.get();
    final List<String> memberToATeamIds = [];

    memberToATeamSnapshot.docs.forEach((doc) {
      final data = doc.data();
      if (data is Map<String, dynamic>) {
        memberToATeamIds.add(data['Uid'] as String);
      }
    });

    final QuerySnapshot eventsSnapshot = await teams.where('uid', whereIn: memberToATeamIds).get();

    final List<QueryDocumentSnapshot> MemberToATeam = eventsSnapshot.docs.where((team) => memberToATeamIds.contains(team['uid'])).toList();

    return MemberToATeam;
  }





  static void createParticipantsSubCollection(String participantUid,String creatorName,String participantProfilePicture,String eventName,String eventId) async{
    CollectionReference event = _db.collection('events');
    QuerySnapshot eventSnapshot = await event.where('uid',isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();
    if(eventSnapshot.docs.isNotEmpty){
      String documentID = eventSnapshot.docs.first.id;
      CollectionReference eventParticipant = _db.collection('events').doc(documentID).collection('participants');
      eventParticipant.add({
        'Uid' : participantUid,
        'event_Uid' : eventId,
        'firstname' : creatorName,
        'inviteAcceptedAt' : DateTime.now(),
        'profilePicture' : participantProfilePicture,
      });

      CollectionReference userParticipant = _db.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('participatingInEvents');
      userParticipant.add({
        'Uid' : participantUid,
        'firstname' : creatorName,
        'inviteAcceptedAt' : DateTime.now(),
        'profilePicture' : participantProfilePicture,
        'event_name' : eventName
      });
    }

  }



  static void AddUserToAnEventByAdmin(String eventUid, String eventName, String userUid, String userName, String userToken, String userProfilePicture) {
    CollectionReference event = _db.collection('events').doc(eventUid).collection('participants');
    event.add({
      'Uid' : userUid,
      'event_name' : eventName,
      'firstname' : userName,
      'userToken' : userToken,
      'userProfilePicture' : userProfilePicture,
      'inviteAcceptedAt' : DateTime.now()
    });

    CollectionReference user = _db.collection('users').doc(userUid).collection('participatingInEvents');
    user.add({
      'Uid' : eventUid,
      'event_name' : eventName,
      'firstname' : userName,
      'userToken' : userToken,
      'userProfilePicture' : userProfilePicture
    });
  }

  static Future<List<QueryDocumentSnapshot>> getEventsWhereUserTakesPart(String userId) async{
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final participatingInEventsRef = userRef.collection('participatingInEvents');

    final querySnapshot = await participatingInEventsRef.get();

    return querySnapshot.docs;
  }

  static Future<List<QueryDocumentSnapshot>> getEventsWhereUserNotParticipating(String userId) async{
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final participatingInEventsRef = userRef.collection('participatingInEvents');

    final querySnapshot = await FirebaseFirestore.instance.collection('events').where(FieldPath.documentId, whereNotIn: (await participatingInEventsRef.get()).docs.map((doc) => doc.id).toList()).get();

    return querySnapshot.docs;
  }





  static void IndividualJoin(String userId, String eventDoc,String eventUid,String eventName,String userToken,String participantId,String participantName,String profilePicture){
    CollectionReference event = _db.collection('events').doc(eventDoc).collection('participants');
    CollectionReference invToUser = _db.collection('users').doc(participantId).collection('participatingInEvents');
    event.add({
      'event_Uid' : eventUid,
      'Uid': userId,
      'event_name' : eventName,
      'firstname' : participantName,
      'inviteAcceptedAt' : DateTime.now(),
      'profilePicture' : profilePicture
    });

    invToUser.add({
      'event_Uid' : eventUid,
      'event_name' : eventName,
      'userToken' : userToken,
      'requestReceived' : DateTime.now(),
      'Uid' : participantId,
    });
  }

  static void JoinToATeamAlone(String userId, String teamDoc,String teamUid,String teamName,String userToken,String memberId,String memberName,String profilePicture ) {
    CollectionReference team = _db.collection('teams').doc(teamDoc).collection('members');
    CollectionReference invToUser = _db.collection('users').doc(memberId).collection('memberToATeam');
    team.add({
      'user_Uid' : userId,
      'Uid': teamUid,
      'event_name' : teamName,
      'firstname' : memberName,
      'inviteAcceptedAt' : DateTime.now(),
      'memberProfilePicture' : profilePicture
    });

    invToUser.add({
      'user_Uid' : memberId,
      'team_name' : teamName,
      'userToken' : userToken,
      'requestReceived' : DateTime.now(),
      'Uid' : teamUid,
    });
  }

  static void JoiningRequestToATeam(String joinerToken,String joinerUid, String userId, String teamDoc,String teamUid,String teamName,String badge,String inviterName,String inviterToken,String inviterProfilePicture) async{
    CollectionReference invToEvent = _db.collection('teams').doc(teamDoc).collection('wantsToJoin');
    invToEvent.add({
      'teamUid' : teamUid,
      'Uid' : joinerUid,
      'teamDoc' : teamDoc,
      'team_name' : teamName,
      'inviter_name' : inviterName,
      'badge': badge,
      'joinerToken' : joinerToken
    });

    CollectionReference invToUser = _db.collection('users').doc(userId).collection('wantsToJoin');
    invToUser.add({
      'receverUid' : userId,
      'Uid': joinerUid,
      'teamUid' : teamUid,
      'teamDoc' : teamDoc,
      'team_name' : teamName,
      'inviter_name' : inviterName,
      'inviterToken' : inviterToken,
      'inviterProfilePicture' : inviterProfilePicture,
      'badge': badge
    });
  }

  static void setTheTeamMemberRequestToASubcollection(String senderUid,String senderToken,String receiverUid, String receiverName,String receiverToken,String teamBadge,String teamName, String teamUid) {

    CollectionReference receiverSubcollection = _db.collection('users').doc(receiverUid).collection('teamInviteRequests');
    receiverSubcollection.add({
      'Uid' : senderUid,
      'potentionalMemberName' : receiverName,
      'potentionalMemberToken' : receiverToken,
      'senderToken': senderToken,
      'whenTheRequestedToBeAMember' : DateTime.now(),
      'team_name' : teamName,
      'team_uid' : teamUid,
      'teamBadge' : teamBadge
    });
  }


  static updateUserData(String firstname, String lastname, String password, String email) {
    _db.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
      "firstname": firstname,
      "lastname" : lastname,
      "password" : password.hashCode,
      "email": email,
    });
  }

  static updateEventData(String eventDoc, String description, String location,String eventName){
    _db.collection('events').doc(eventDoc).update({
      'description' : description,
      'location' : location,
      'event_name' : eventName
    });
  }

  static updateTeamData(String teamDoc, String description, String shortName, String sportCategory, String teamName){
    _db.collection('teams').doc(teamDoc).update({
      'description' : description,
      'team_name' : teamName,
      'short_name' : shortName,
      'sport_category' : sportCategory
    });
  }

  Future<String> getSecretKey() async {
    final headers = {'Content-Type': 'application/json'};
    final url = Uri.parse('https://mysterious-pajamas-cod.cyclic.app/secret-key');
    print('Making GET request to $url...');
    final response = await http.get(url, headers: headers);
    print('Got response with status code ${response.statusCode}');
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to get secret key.');
    }
  }

  static Future<void> createAdmin(String email, String firstname, String lastname,String password) async {
    final String apiUrl = UserHelper().apiUrl;
    final url = Uri.parse('$apiUrl/createUser');
    final tokenResult = await FirebaseAuth.instance.currentUser!.getIdToken(true);
    final secretKey = await UserHelper().getSecretKey();
    final hmac = Hmac(sha256, utf8.encode(secretKey));
    final signature = base64UrlEncode(hmac.convert(utf8.encode(tokenResult)).bytes);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $signature'
      },
      body: jsonEncode({
        'email': email,
        'firstname': firstname,
        'lastname': lastname,
        'password' : password,
        'idToken': tokenResult,
        'secretKey': secretKey,
      }),
    );

    if (response.statusCode == 200) {
      print('User created successfully!');
    } else {
      print('Failed to create user.');
    }
  }


  static Future<void> deleteUserAccount(String userId) async {
    final String apiUrl = UserHelper().apiUrl;
    final url = Uri.parse('$apiUrl/deleteUser');
    final tokenResult = await FirebaseAuth.instance.currentUser!.getIdToken(true);
    final secretKey = await UserHelper().getSecretKey();
    final hmac = Hmac(sha256, utf8.encode(secretKey));
    final signature = base64UrlEncode(hmac.convert(utf8.encode(tokenResult)).bytes);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $signature'
      },
      body: jsonEncode({
        'uid': userId,
        'idToken': tokenResult,
        'secretKey': secretKey,
      }),
    );

    if (response.statusCode == 200) {
      print('User deleted successfully!');
    } else {
      print('Failed to delete user.');
    }
  }

  static void DeleteEvent(String eventId) {
    _db.collection('events').doc(eventId).delete();
  }

  static void DeleteTeam(String teamId){
    _db.collection('teams').doc(teamId).delete();
  }




}
