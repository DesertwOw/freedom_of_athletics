import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../services/DataController.dart';
import '../../services/auth_helper.dart';
import '../../widgets/clipper.dart';
import '../../widgets/my_account_widgets.dart';
import '../../widgets/selectors/admin_selector_for_adding_users_to_events.dart';
import '../../widgets/selectors/admin_selector_for_removing_participants_from_events.dart';

class EventViewForAdmin extends StatefulWidget {
  DocumentSnapshot event;

  EventViewForAdmin(this.event);

  @override
  State<EventViewForAdmin> createState() => _EventViewForAdminState();
}

class _EventViewForAdminState extends State<EventViewForAdmin> {

  DataController dataController = Get.find<DataController>();

   TextEditingController eventNameController = TextEditingController();
   TextEditingController locationController = TextEditingController();
   TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    eventNameController.text = widget.event.get('event_name');
    locationController.text = widget.event.get('location');
    descriptionController.text = widget.event.get('description');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    String eventImage = '';
    try {
      List media = widget.event.get('media') as List;
      Map mediaItem = media.first as Map;
      eventImage = mediaItem['url'];
    } catch (e) {
      eventImage = '';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipPath(
                  clipper: EventViewClipper(),
                  child: Container(
                    height: MediaQuery.of(context).size.height * .60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(eventImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${widget.event.get('event_name')}",
                    style: const TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Center(
                child: TextButton(onPressed: () => showDialog(
                    context: context,
                    builder: (context) {
                      return AdminSelectorForAddingUsersToEvents(widget.event);
                    }
                ),
                  child: Text('Add Participants'),
                ),
              ),
              SizedBox(height: 15,),
      Container(
        margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
        child: Column(
          children: [
            NameInputField(nameController: eventNameController,labelTexts: "Event Name", name: "Event Name"),
            const SizedBox(
              height:20,
            ),
            NameInputField(nameController: locationController,labelTexts: "Location", name: "Location"),
            const SizedBox(
              height:20,
            ),
            NameInputField(nameController: descriptionController, labelTexts: "Description", name: "Description"),
            const SizedBox(
              height:20,
            ),
          ],
        ),
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: TextButton(
              child: const Text("Update"),
              onPressed: () async {
                try {
                  UserHelper.updateEventData(widget.event.id, descriptionController.text, locationController.text, eventNameController.text);
                } catch (e) {
                  print(e);
                }
              },
            ),
          ),
          TextButton(onPressed: () => showDialog(
              context: context,
              builder: (context) {
                return AdminSelectorForRemovingParticipantsFromEvents(widget.event);
              }
          ),
            child: Text('Remove Participants'),
          ),
          TextButton(
            child: const Text("Delete this event"),
            onPressed: () async {
              try{
                UserHelper.DeleteEvent(widget.event.id);
              } catch(e){
                print(e);
              }
            },
          )
            ],)
        ],
      )
      )
    );
  }
}
