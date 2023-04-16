import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

class DataController extends GetxController {
   FirebaseAuth auth = FirebaseAuth.instance;

  DocumentSnapshot? myDocument;

  var allUsers = <DocumentSnapshot>[].obs;
  var allEvents = <DocumentSnapshot>[].obs;
  var filteredUsers = <DocumentSnapshot>[].obs;
  var allTeams = <DocumentSnapshot>[].obs;
  var filteredFriends = <DocumentSnapshot>[].obs;
  var allFriends = <DocumentSnapshot>[].obs;
  var allRequest = <DocumentSnapshot>[].obs;
  var filteredRequests = <DocumentSnapshot>[].obs;
  var allEventInvs = <DocumentSnapshot>[].obs;
  var filteredEventInvs = <DocumentSnapshot>[].obs;
  var myEvents = <DocumentSnapshot>[].obs;
  var allMemberRequest = <DocumentSnapshot>[].obs;
  var filteredMemberRequests = <DocumentSnapshot>[].obs;
  var specificTeamMember = <DocumentSnapshot>[].obs;
  var filteredSpecificTeamMember = <DocumentSnapshot>[].obs;
  var allParticipants =  <DocumentSnapshot>[].obs;
  var filteredParticipants =  <DocumentSnapshot>[].obs;
  var allJoiningToAnEventRequest = <DocumentSnapshot>[].obs;
  var filteredJoiningToAnEventRequest = <DocumentSnapshot>[].obs;
  var allJoiningToATeamRequest = <DocumentSnapshot>[].obs;
  var filteredJoininToATeamRequest = <DocumentSnapshot>[].obs;
  
  var teamMembers = <DocumentSnapshot>[].obs;
  
  var searchList = List.empty(growable: true).obs;
  
  var isEventsLoading = false.obs;
  var isUsersLoading = false.obs;
  var isTeamsLoading = false.obs;
  var isFriendsLoading = false.obs;
  var isRequestsLoading = false.obs;
  var isEventInvsLoading= false.obs;
  var isParticipantsLoading = false.obs;
  var isMyEventsLoading = false.obs;
  var isBecomingMemberLoading = false.obs;
  var isTeamMemberLoading = false.obs;
  var isJoiningToAnEventRequest  = false.obs;
  var isJoiningToATeamRequest = false.obs;



  var selectedList = List<String>.empty(growable: true).obs;
  getSelectedList() => selectedList;
  setSelectedList(List<String> list) => selectedList.value = list;

  String? downloadURL;

  static DataController instance = Get.find();

  getMyDocument() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.uid)
        .snapshots()
        .listen((event) {
      myDocument = event;
    });
  }

  Future<bool> createEvent(Map<String, dynamic> eventData) async {
    bool isCompleted = false;

    await FirebaseFirestore.instance
        .collection('events')
        .add(eventData)
        .then((value) {
      isCompleted = true;
      Get.snackbar('Event Uploaded', 'Event is uploaded successfully.',
          colorText: Colors.white, backgroundColor: Colors.blue);
    }).catchError((e) {
      isCompleted = false;
    });
    return isCompleted;
  }

  Future<bool> createTeam(Map<String, dynamic> teamData) async {
    bool isCompleted = false;

    await FirebaseFirestore.instance
        .collection('teams')
        .add(teamData)
        .then((value) {
      isCompleted = true;
      Get.snackbar('Team Created', 'Your team is ready to be filled up!',
          colorText: Colors.black, backgroundColor: Colors.white);
    }).catchError((e) {
      isCompleted = false;
    });
    return isCompleted;
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getMyDocument();
    getUsers();
    getEvents();
    getTeams();
    getFriends();
    getRequest();
    getEventInvs();
    getMyEvents();
    getMemberRequests();
    getTeamMembers();
    getParticipants();
    getJoiningToAnEventRequest();
    getJoiningToATeamRequest();
  }

  getJoiningToAnEventRequest(){
    isJoiningToAnEventRequest(true);
    String userId = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference userRef = FirebaseFirestore.instance.collection('users');
    userRef.doc(userId).collection('joiningRequest').snapshots().listen((joining){
      allJoiningToAnEventRequest.value = joining.docs;
      filteredJoiningToAnEventRequest.assignAll(allJoiningToAnEventRequest);
      isJoiningToAnEventRequest(false);
    });
  }

  getJoiningToATeamRequest(){
    isJoiningToATeamRequest(true);
    String userId = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference userRef = FirebaseFirestore.instance.collection('users');
    userRef.doc(userId).collection('wantsToJoin').snapshots().listen((teamJoiner){
      allJoiningToATeamRequest.value = teamJoiner.docs;
      filteredJoininToATeamRequest.assignAll(allJoiningToATeamRequest);
      isJoiningToATeamRequest(false);
    });
  }


  getEventInvs(){
    isEventInvsLoading(true);
    String userId = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference userRef = FirebaseFirestore.instance.collection('users');
    userRef.doc(userId).collection('eventInvitationRequests').snapshots().listen((invs) {
      allEventInvs.value = invs.docs;
      filteredEventInvs.assignAll(allEventInvs);
      isEventInvsLoading(false);
    });
  }
   getRequest(){
     isRequestsLoading(true);
     String userId = FirebaseAuth.instance.currentUser!.uid;
     CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
     usersRef.doc(userId).collection('friendRequests').snapshots().listen((request) {
       allRequest.value = request.docs;
       filteredRequests.assignAll(allRequest);
       isRequestsLoading(false);
     });
   }


   getMemberRequests(){
     isBecomingMemberLoading(true);
     String userId = FirebaseAuth.instance.currentUser!.uid;
     CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
     usersRef.doc(userId).collection('teamInviteRequests').snapshots().listen((members) {
       allMemberRequest.value = members.docs;
       filteredMemberRequests.assignAll(allMemberRequest);
       isBecomingMemberLoading(false);
     });
   }
  
  getFriends() {
    isFriendsLoading(true);
    String userId = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
    usersRef.doc(userId).collection('friends').snapshots().listen((friend) {
      allFriends.value = friend.docs;
      filteredFriends.assignAll(allFriends);
      isFriendsLoading(false);
    });
  }

   getTeamMembers(){
     isTeamMemberLoading(true);

     String currentUserID = FirebaseAuth.instance.currentUser!.uid;
     Query query  = FirebaseFirestore.instance.collection('teams').where('uid',isEqualTo: currentUserID);
     query.get().then((querySnapshot){
       DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
       String documentId = documentSnapshot.id;
       CollectionReference teamRef = FirebaseFirestore.instance.collection('teams');
       teamRef.doc(documentId).collection('members').snapshots().listen((member) {
         specificTeamMember.value = member.docs;
         filteredSpecificTeamMember.assignAll(specificTeamMember);
         isTeamMemberLoading(false);
       });
     });
   }

  getParticipants(){
    isParticipantsLoading(true);
    Query query = FirebaseFirestore.instance.collection('events');
    query.get().then((querySnapshot){
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
      String documentID = documentSnapshot.id;
      CollectionReference participantRef = FirebaseFirestore.instance.collection('events');
      participantRef.doc(documentID).collection('participants').snapshots().listen((participant) {
        allParticipants.value = participant.docs;
        filteredParticipants.assignAll(allParticipants);
        isParticipantsLoading(false);
      });
    });
  }

  getUsers() {
    isUsersLoading(true);
    FirebaseFirestore.instance.collection('users').snapshots().listen((user) {
      allUsers.value = user.docs;
      filteredUsers.value.assignAll(allUsers);
      isUsersLoading(false);
    });
  }



  getMyEvents() async{
    isMyEventsLoading(true);
   QuerySnapshot qS = await FirebaseFirestore.instance.collection('events').where('uid',isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();
   myEvents.assignAll(qS.docs);
   isMyEventsLoading(false);
  }

  getEvents() {
    isEventsLoading(true);
    FirebaseFirestore.instance.collection('events').snapshots().listen((event) {
      allEvents.assignAll(event.docs);
      isEventsLoading(false);
    });
  }

  getTeams() {
    isTeamsLoading(true);
    FirebaseFirestore.instance.collection('teams').snapshots().listen((team) { 
      allTeams.assignAll(team.docs);
      isTeamsLoading(false);
      
    });
  }


  Future<String> uploadImageToFirebase(File file) async {
    String fileUrl = '';
    String fileName = Path.basename(file.path);
    var reference = FirebaseStorage.instance.ref().child('myfiles/$fileName');
    UploadTask uploadTask = reference.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    await taskSnapshot.ref.getDownloadURL().then((value) {
      fileUrl = value;
    });
    print("Url $fileUrl");
    return fileUrl;
  }

  Future<String> ProfilePictureHandler(ImageSource source) async {
    String fileUrl = '';
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(
      source: source,
    );
    String fileName = Path.basename(image!.path);
    if (image != null) {
      var reference =
          FirebaseStorage.instance.ref().child('profpics/$fileName');
      UploadTask uploadTask = reference.putFile(File(image.path));
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      await taskSnapshot.ref.getDownloadURL().then((value) {
        fileUrl = value;
        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'profilePicture': fileUrl,
        });
      });
      print("Url $fileUrl");
    }
    return fileUrl;
  }
  setBackProfile() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'profilePicture':
          'https://firebasestorage.googleapis.com/v0/b/freedom-of-athletics-d4d04.appspot.com/o/profpics%2FprofilePicture.png?alt=media&token=ec571e70-8af6-435f-bd57-49cec1cd6434',
    });
  }
}
