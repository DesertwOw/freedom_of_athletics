import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/services/auth_helper.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/DataController.dart';
import '../../utils/color_utils.dart';

class UpdateTeamDialog extends StatefulWidget {
  final String teamName;
  final String description;
  final String sportCategory;
  final String teamDoc;
  final String shortName;

  UpdateTeamDialog({
    required this.teamName,
    required this.description,
    required this.sportCategory,
    required this.teamDoc,
    required this.shortName,
  });

  @override
  _UpdateTeamDialogState createState() => _UpdateTeamDialogState();
}

class _UpdateTeamDialogState extends State<UpdateTeamDialog> {
  late String _teamName;
  late String _description;
  late String _sportCategory;
  late String _teamDoc;
  late String _shortName;
  late TextEditingController _shortNameController;
  late TextEditingController _teamNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _sportCategoryController;

  @override
  void initState() {
    super.initState();
    _teamName = widget.teamName;
    _description = widget.description;
    _sportCategory = widget.sportCategory;
    _shortName = widget.shortName;
    _teamDoc = widget.teamDoc;
    _teamNameController = TextEditingController(text: _teamName);
    _descriptionController = TextEditingController(text: _description);
    _sportCategoryController = TextEditingController(text: _sportCategory);
    _shortNameController = TextEditingController(text: _shortName);
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _descriptionController.dispose();
    _shortNameController.dispose();
    _sportCategoryController.dispose();
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
              controller: _teamNameController,
              onChanged: (value) {
                setState(() {
                  _teamName = value;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Short Name',
              ),
              controller: _shortNameController,
              onChanged: (value) {
                setState(() {
                  _shortName = value;
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
            TextField(
              decoration: InputDecoration(
                labelText: 'Sport Category',
              ),
              controller: _sportCategoryController,
              onChanged: (value) {
                setState(() {
                  _sportCategory = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Update'),
            onPressed: () {
              UserHelper.updateTeamData(
                widget.teamDoc,
                _description,
                _shortName,
                _sportCategory,
                _teamName
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
