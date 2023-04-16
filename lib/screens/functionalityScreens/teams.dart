import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/screens/functionalityScreens/sport_team_selection.dart';

class Teams extends StatelessWidget {
  const Teams({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
       body:  SportTeamSelection(),
        ),
      );
  }
}



