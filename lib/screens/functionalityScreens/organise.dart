import 'dart:io';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:freedom_of_athletics/models/dateFormatter.dart';
import 'package:freedom_of_athletics/services/DataController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/services/auth_helper.dart';
import 'package:freedom_of_athletics/widgets/custom_app_bar.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/color_utils.dart';
import '../../widgets/reusable_widget.dart';
import 'package:freedom_of_athletics/models/media.dart';

class Organize extends StatefulWidget {
  @override
  State<Organize> createState() => _OrganizeState();
}

class _OrganizeState extends State<Organize>
    with SingleTickerProviderStateMixin {
  DateTime? date = DateTime.now();
  List<Map<String,dynamic>> mediaUrls = [];

  List<EventMediaModel> media = [];

  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController eventNameController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TimeOfDay startTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 0, minute: 0);
  int? selectedNumber;


  void resetControllers() {
    dateController.clear();
    timeController.clear();
    eventNameController.clear();
    locationController.clear();
    descriptionController.clear();
    endTimeController.clear();
    startTimeController.clear();
    startTime = const TimeOfDay(hour: 0, minute: 0);
    endTime = const TimeOfDay(hour: 0, minute: 0);
    setState(() {});
  }

  var isCreatingEvent = false.obs;
  var selectedDate;

  startTimeMethod(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      startTime = picked;
      startTimeController.text =
          '${startTime.hourOfPeriod > 9 ? "" : '0'}${startTime.hour > 12 ? '${startTime.hour - 12}' : startTime.hour}:${startTime.minute > 9 ? startTime.minute : '0${startTime.minute}'} ${startTime.hour > 12 ? 'PM' : 'AM'}';
    }
    setState(() {});
  }

  endTimeMethod(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      endTime = picked;
      endTimeController.text =
          '${endTime.hourOfPeriod > 9 ? "" : "0"}${endTime.hour > 9 ? "" : "0"}${endTime.hour > 12 ? '${endTime.hour - 12}' : endTime.hour}:${endTime.minute > 9 ? endTime.minute : '0${endTime.minute}'} ${endTime.hour > 12 ? 'PM' : 'AM'}';
    }
    setState(() {});
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    timeController.text = '${date!.hour}:${date!.minute}:${date!.second}';
    dateController.text = '${date!.day}-${date!.month}-${date!.year}';
  }

  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: customAppBar()),
            Text('Create your event',style: TextStyle(fontSize: 26,fontWeight: FontWeight.bold),),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    const Text(
                      'Upload your file',
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.white),
                      onPressed: () {
                        imageDialog(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
                        child: _selectedImage == null
                            ? Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.3),
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Iconsax.folder_open,
                                  color: hexStringToColor("7EC8E3"),
                                  size: 40,
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                const Text(
                                  'Select your file',
                                  style: TextStyle(fontSize: 15, color: Colors.black),
                                ),
                              ],
                            ),
                          )

                            : Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(_selectedImage!),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.8),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  imageDialog(context);
                                },
                                icon: Icon(
                                  Icons.edit,
                                  color: hexStringToColor("7EC8E3"),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                const SizedBox(
                      height: 15,
                    ),
                    myTextField(
                      bool: false,
                      icon: 'assets/4DotIcon.png',
                      text: 'Event Name',
                      controller: eventNameController,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    myTextField(
                      bool: false,
                      icon: 'assets/location.png',
                      text: "Location",
                      controller: locationController,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 100,
                            child: DatePicker(
                              DateTime.now(),
                              initialSelectedDate: DateTime.now(),
                              selectionColor: Colors.blueAccent,
                              selectedTextColor: Colors.white,
                              onDateChange: (date) {
                                setState(() {
                                  String stringDate = date.toString();
                                  selectedDate = formatDate(stringDate);
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        iconTitleContainer(
                            path: 'assets/time.png',
                            text: 'Start Time',
                            controller: startTimeController,
                            isReadOnly: true,
                            validator: (input) {},
                            onPress: () {
                              startTimeMethod(context);
                            }),
                        iconTitleContainer(
                            path: 'assets/time.png',
                            text: 'End Time',
                            isReadOnly: true,
                            controller: endTimeController,
                            validator: (input) {},
                            onPress: () {
                              endTimeMethod(context);
                            }),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Player's count:"),


                        DropdownButton<int>(
                          value: selectedNumber,
                          onChanged: (int? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedNumber = newValue;
                              });
                            }
                          },
                          items: List<int>.generate(40, (index) => index + 1)
                              .map<DropdownMenuItem<int>>((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString()),
                            );
                          }).toList(),
                        ),],
                    ),
                    Row(
                      children: [
                        myText(
                            text: 'Description/Instruction',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            )),

                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 149,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(width: 1, color: Colors.black),
                      ),
                      child: TextFormField(
                        maxLines: 5,
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.only(top: 25, left: 15, right: 15),
                          hintStyle: TextStyle(
                            color: Colors.black,
                          ),
                          hintText:
                              'Write a summary and any details your invitee should know about the event...',
                        ),
                      ),
                    ),
                    SizedBox(
                      height: Get.height * 0.03,
                    ),
                    Obx(() => isCreatingEvent.value
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : SizedBox(
                            height: 42,
                            width: double.infinity,
                            child: elevatedButton(
                                onpress: () async {
                                  isCreatingEvent(true);

                                  Get.put(DataController());
                                  DataController dataController = Get.find();

                                  for (int i = 0; i < media.length; i++) {
                                    String imageUrl = await dataController
                                        .uploadImageToFirebase(media[i].image!);
                                    mediaUrls.add({
                                      'url': imageUrl
                                    });
                                  }

                                  Map<String, dynamic> eventData = {
                                    'event_name': eventNameController.text,
                                    'event_creator_name' : dataController.myDocument?.get('firstname'),
                                    'location': locationController.text,
                                    'date': selectedDate,
                                    'start_time': startTimeController.text,
                                    'end_time': endTimeController.text,
                                    'description': descriptionController.text,
                                    'media': mediaUrls,
                                    'maximum_players' : selectedNumber,
                                    'uid': FirebaseAuth.instance.currentUser!.uid,
                                  };
                                  await dataController
                                      .createEvent(eventData)
                                      .then((value) {
                                        UserHelper.createParticipantsSubCollection(FirebaseAuth.instance.currentUser!.uid,dataController.myDocument?.get('firstname'),dataController.myDocument?.get('profilePicture'),eventNameController.text,FirebaseAuth.instance.currentUser!.uid);
                                    isCreatingEvent(false);
                                    resetControllers();
                                  });
                                },
                                text: 'Create Event'),
                          )),
                    SizedBox(
                      height: Get.height * 0.03,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

void imageDialog(BuildContext context) {
  showDialog(
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Media Source"),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () async {
                await getImageDialog(ImageSource.gallery);
              },
              icon: const Icon(Icons.image),
            ),
            IconButton(
              onPressed: () async {
                await getImageDialog(ImageSource.camera);
              },
              icon: const Icon(Icons.camera_alt),
            ),
          ],
        ),
      );
    },
    context: context,
  );
}

Future<void> getImageDialog(ImageSource source) async {
  final ImagePicker _picker = ImagePicker();
  final XFile? image = await _picker.pickImage(
    source: source,
  );
  if (image != null) {
    media.add(EventMediaModel(
      image: File(image.path),
    ));
    _selectedImage = File(image.path);
  }
  setState(() {});
  Get.back();
}}
