import 'package:flutter/material.dart';

import '../../utils/carousel_localdata_feed.dart';

class PictureSelectionDialog extends StatefulWidget {
  final List<String> pictures;

  PictureSelectionDialog({required this.pictures});

  @override
  _PictureSelectionDialogState createState() => _PictureSelectionDialogState();
}

class _PictureSelectionDialogState extends State<PictureSelectionDialog> {
  String? _selectedPicture;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GridView.builder(
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            shrinkWrap: true,
            itemCount: widget.pictures.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPicture = widget.pictures[index];
                  });
                },
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.pictures[index]),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(
                      color: _selectedPicture == widget.pictures[index]
                          ? Colors.green
                          : Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),
          if (_selectedPicture != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(_selectedPicture);
              },
              child: Text('Accept'),
            ),
        ],
      ),
    );
  }
}


class PictureSelectionButton extends StatefulWidget {
  @override
  _PictureSelectionButtonState createState() => _PictureSelectionButtonState();
}

class _PictureSelectionButtonState extends State<PictureSelectionButton> {
  String? _selectedPicture;





  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () async {
            final result = await showDialog(
              context: context,
              builder: (_) => PictureSelectionDialog(pictures: pictures),
            );

            setState(() {
              _selectedPicture = result;
            });
          },
          child: Text('Select Picture'),
        ),
        SizedBox(height: 20),
        if (_selectedPicture != null)
          Image.network(
            _selectedPicture!,
            width: 150,
            height: 150,
          ),
      ],
    );
  }
}
