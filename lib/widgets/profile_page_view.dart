import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/services/DataController.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';


import '../utils/color_utils.dart';

class ProfPic extends StatefulWidget {
  @override
  State<ProfPic> createState() => _ProfPicState();
}

class _ProfPicState extends State<ProfPic> {

  DataController? dataController;

  @override
  void initState() {
    super.initState();
    
  }




  @override
  Widget build(BuildContext context) {
    DataController dataController = Get.find<DataController>();
    DocumentSnapshot user =
    dataController.allUsers.firstWhere((e) => FirebaseAuth.instance.currentUser!.uid == e.id);
    return SizedBox(
        height: 115,
        width: 115,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CircleAvatar(
                backgroundImage: NetworkImage(
                   user.get('profilePicture'))),
            Positioned(
                right: 0,
                bottom: 0,
                child: SizedBox(
                    height: 46,
                    width: 46,
                    child: MaterialButton(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                          side: const BorderSide(color: Colors.white),
                        ),
                        color: hexStringToColor("FFF5F6F9"),
                        onPressed: () {
                          DataController().ProfilePictureHandler(ImageSource.camera);
                        },
                        child: Image.asset('assets/camera.png')))),
            Positioned(
              right:75,
              bottom: -0,
              child: SizedBox(
                height: 30,
                width: 30,
                child: MaterialButton(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Colors.white),
                  ),
                  color: hexStringToColor("FFF5F6F9"),
                  onPressed: (){
                    DataController().setBackProfile();
                  },
                  child: Image.asset('assets/trash_bin.png'),
                ),
              ),
            )
          ],
        ));
  }
}

class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem({
    Key? key,
    required this.text,
    required this.icon,
    required this.press,
  }) : super(key: key);

  final String text, icon;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: MaterialButton(
        padding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: hexStringToColor("FFF5F6F9"),
        onPressed: press,
        child: Row(
          children: [
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
            const Icon(Icons.arrow_forward_ios)
          ],
        ),
      ),
    );
  }
}




