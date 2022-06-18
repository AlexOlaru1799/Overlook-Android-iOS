// ignore_for_file: prefer_const_constructors, unnecessary_new

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:overlook/components/firebase_api.dart';
import 'package:overlook/constants.dart';
import 'package:overlook/new/changeProfile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../Screens/Profile/numbers_widget.dart';
import '../components/globals.dart';

bool stopShimmer = true;
double topDistanceForUserDetails = 200;
bool aboutSet = false;

const mainColorDef = Color(0xffEB5325);
const secondaryColorDef = Color.fromARGB(255, 14, 14, 14);

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isSwitched = false;

  @override
  void initState() {
    super.initState();

    isSwitched = changedColors;
  }

  @override
  Widget build(BuildContext context) {
    print(isSwitched.toString());
    return changedColors
        ? Scaffold(
            backgroundColor: secondaryColor,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(35),
              child: AppBar(
                title: Text(
                  ("Settings"),
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                elevation: 0.0,
                backgroundColor: secondaryColor,
                leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context)),
              ),
            ),
            body: Container(
              padding: EdgeInsets.all(10),
              child: Column(children: [
                Row(
                  children: [
                    Text(
                      "Alternative color pattern",
                      style: TextStyle(
                        fontSize: 20,
                        color: mainColor,
                      ),
                    ),
                    Spacer(),
                    Switch(
                        value: isSwitched,
                        activeColor: mainColor,
                        onChanged: (value) async {
                          final prefs = await SharedPreferences.getInstance();
                          setState(() {
                            isSwitched = value;

                            if (isSwitched == true) {
                              changedColors = true;
                              prefs.setInt('changedColors', 1);
                              print(":::" +
                                  prefs.getInt('changedColors').toString());
                            } else {
                              changedColors = false;
                              prefs.setInt('changedColors', 0);
                              print(":::" +
                                  prefs.getInt('changedColors').toString());
                            }
                          });
                        }),
                  ],
                )
              ]),
            ),
          )
        : Scaffold(
            backgroundColor: secondaryColorSec,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(35),
              child: AppBar(
                title: Text(
                  (FirebaseApi.realUserLastData!.getUsername()!) + "'s profile",
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                elevation: 0.0,
                backgroundColor: secondaryColorSec,
                leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context)),
              ),
            ),
            body: Container(
              padding: EdgeInsets.all(10),
              child: Column(children: [
                Row(
                  children: [
                    Text(
                      "Alternative color pattern",
                      style: TextStyle(
                        fontSize: 20,
                        color: mainColorSec,
                      ),
                    ),
                    Spacer(),
                    Switch(
                        value: isSwitched,
                        activeColor: mainColor,
                        onChanged: (value) async {
                          final prefs = await SharedPreferences.getInstance();
                          setState(() {
                            isSwitched = value;

                            if (isSwitched == true) {
                              changedColors = true;
                              prefs.setInt('changedColors', 1);
                              print(":::" +
                                  prefs.getInt('changedColors').toString());
                            } else {
                              changedColors = false;
                              prefs.setInt('changedColors', 0);
                              print(":::" +
                                  prefs.getInt('changedColors').toString());
                            }
                          });
                        }),
                  ],
                )
              ]),
            ),
          );
  }
}
