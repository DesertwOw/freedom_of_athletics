import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/services/auth_helper.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/DataController.dart';
import '../../utils/color_utils.dart';

class UpdateEventDialog extends StatefulWidget {
  final String eventName;
  final String description;
  final String eventLocation;
  final String eventDoc;

  UpdateEventDialog({
    required this.eventName,
    required this.description,
    required this.eventLocation,
    required this.eventDoc,
  });

  @override
  _UpdateEventDialogState createState() => _UpdateEventDialogState();
}

class _UpdateEventDialogState extends State<UpdateEventDialog> {
  late String _eventName;
  late String _description;
  late String _eventLocation;
  late String _eventDoc;
  late TextEditingController _eventNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _eventLocationController;

  @override
  void initState() {
    super.initState();
    _eventName = widget.eventName;
    _description = widget.description;
    _eventLocation = widget.eventLocation;
    _eventDoc = widget.eventDoc;
    _eventNameController = TextEditingController(text: _eventName);
    _descriptionController = TextEditingController(text: _description);
    _eventLocationController = TextEditingController(text: _eventLocation);
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _descriptionController.dispose();
    _eventLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AlertDialog(
        title: Text('Update event data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Event Name',
              ),
              controller: _eventNameController,
              onChanged: (value) {
                setState(() {
                  _eventName = value;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Location',
              ),
              controller: _eventLocationController,
              onChanged: (value) {
                setState(() {
                  _eventLocation = value;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Description',
              ),
              controller: _descriptionController,
              onChanged: (value) {
                setState(() {
                  _description = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Update'),
            onPressed: () {
              UserHelper.updateEventData(
                widget.eventDoc,
                _description,
                _eventLocation,
                _eventName,
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
