import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:freedom_of_athletics/createDifferentTeams/create_baseball_team.dart';
import 'package:freedom_of_athletics/createDifferentTeams/create_cricket_team.dart';
import 'package:freedom_of_athletics/createDifferentTeams/create_football_team.dart';
import 'package:freedom_of_athletics/createDifferentTeams/create_handball_team.dart';
import 'package:freedom_of_athletics/createDifferentTeams/create_icehockey_team.dart';
import 'package:freedom_of_athletics/createDifferentTeams/create_lacrosse_team.dart';
import 'package:freedom_of_athletics/createDifferentTeams/create_rugby_team.dart';
import 'package:freedom_of_athletics/createDifferentTeams/create_volleyball_team.dart';
import 'package:freedom_of_athletics/createDifferentTeams/create_waterpolo_team.dart';
import 'package:freedom_of_athletics/screens/functionalityScreens/profile.dart';
import 'package:freedom_of_athletics/createDifferentTeams/create_basketball_team.dart';
import 'package:freedom_of_athletics/screens/organizer_home.dart';
import 'package:freedom_of_athletics/services/DataController.dart';
import 'package:get/get.dart';
import 'package:freedom_of_athletics/utils/carousel_localdata_feed.dart';

class SportTeamSelection extends StatefulWidget {

  @override
  State<SportTeamSelection> createState() => _SportTeamSelectionState();
}

class _SportTeamSelectionState extends State<SportTeamSelection> {
  int _current = 0;
  dynamic _selectedIndex = {};

  final CarouselController carouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    Get.put(DataController());
    return Scaffold(
      floatingActionButton: _selectedIndex.length > 0
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              PageRouteBuilder(
                  transitionDuration: const Duration(seconds: 1),
                  transitionsBuilder:
                      (context, animation, animationTime, child) {
                    animation = CurvedAnimation(
                        parent: animation, curve: Curves.elasticIn);
                    return ScaleTransition(
                        alignment: Alignment.center,
                        scale: animation,
                        child: child);
                  },
                  pageBuilder: (context, animation, animationTime) {
                    switch (_current) {
                      case 0:
                        return const CreateBasketballTeam();
                      case 1:
                        return const CreateFootbalTeam();
                      case 2:
                        return const CreateVolleyballTeam();
                      case 3:
                        return const CreateWaterpoloTeam();
                      case 4:
                        return const CreateHandballTeam();
                      case 5:
                        return const CreateRugbyTeam();
                      case 6:
                        return const CreateIceHockeyTeam();
                      case 7:
                        return const CreateBaseballTeam();
                      case 8:
                        return const CreateCricketTeam();
                      case 9:
                        return const CreateLacrosseTeam();
                      default:
                        return OrganizerHome();
                    }
                  }));
        },
        child: const Icon(Icons.arrow_forward_ios),
      )
          : null,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Create your own Sport Team',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: CarouselSlider(
            carouselController: carouselController,
            options: CarouselOptions(
                height: 450.0,
                aspectRatio: 16 / 9,
                viewportFraction: 0.70,
                enlargeCenterPage: true,
                pageSnapping: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                }),
            items: sports.map((sport) {
              return Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _current = sports.indexOf(sport);
                        if (_selectedIndex == sport) {
                          _selectedIndex = {};
                        } else {
                          _selectedIndex = sport;
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: _selectedIndex == sport ? Border.all(color: Colors.blue.shade500, width: 3) : null,
                          boxShadow: _selectedIndex == sport ? [
                            BoxShadow(
                                color: Colors.blue.shade100,
                                blurRadius: 30,
                                offset: const Offset(0, 10)
                            )
                          ] : [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 5)
                            )
                          ]
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              height: 320,
                              margin: const EdgeInsets.only(top: 10),
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Image.network(sport['image'], fit: BoxFit.cover),
                            ),
                            const SizedBox(height: 20,),
                            Text(sport['title'], style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),),
                            const SizedBox(height: 20,),
                            Text(sport['description'], style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600
                            ),),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList()
        ),
      ),
    );
  }
}
