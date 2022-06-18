// ignore_for_file: prefer_const_constructors, unnecessary_new

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:overlook/components/firebase_api.dart';
import 'package:overlook/components/globals.dart';
import 'package:overlook/components/storage_service.dart';
import 'package:overlook/components/user.dart';
import 'package:overlook/constants.dart';
import 'package:overlook/main.dart';
import 'package:overlook/new/addImage.dart';
import 'package:overlook/new/favourites.dart';
import 'package:overlook/new/friends.dart';
import 'package:overlook/new/login.dart';
import 'package:overlook/new/messages.dart';
import 'package:overlook/new/newsfeed.dart';
import 'package:overlook/new/notifications.dart';
import 'package:overlook/new/popup_test.dart';
import 'package:overlook/new/profile.dart';
import 'package:overlook/new/settings.dart';
import 'package:overlook/new/videoconference.dart';

import 'package:shimmer/shimmer.dart';

class NavBar extends StatefulWidget {
  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  bool stopShimmer = false;
  Timer? _timer;
  @override
  void initState() {
    _timer = new Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() => displayNavbar = true);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return changedColors
        ? Drawer(
            backgroundColor: secondaryColor,
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('RegularUsers')
                  .doc(FirebaseApi.realUserUID)
                  .snapshots(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                var userDocument = snapshot.data;
                return ListView(
                  padding: EdgeInsets.zero,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    UserAccountsDrawerHeader(
                      accountName: Text(
                        userDocument!["username"],
                        style: GoogleFonts.openSans(
                            color: mainColor,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                      accountEmail: Text(
                        userDocument["email"],
                        style: GoogleFonts.openSans(
                          color: mainColor,
                          fontSize: 12,
                        ),
                      ),
                      currentAccountPicture: CircleAvatar(
                          backgroundColor: Colors.blue.shade300,
                          child: displayNavbar
                              ? ClipOval(
                                  child: Image.network(
                                    userDocument["profileImage"],
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Shimmer.fromColors(
                                  baseColor: mainColor,
                                  highlightColor: Colors.white,
                                  enabled: true,
                                  child: Container(
                                    //padding: EdgeInsets.all(90.0),
                                    width:
                                        MediaQuery.of(context).size.width / 2.2,
                                    height:
                                        MediaQuery.of(context).size.width / 2,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: mainColor,
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                            userDocument["profileImage"]),
                                      ),
                                    ),
                                  ),
                                )),
                      decoration: BoxDecoration(
                          color: secondaryColor,
                          image: DecorationImage(
                            image:
                                NetworkImage(userDocument["backgroundImage"]),
                            fit: BoxFit.cover,
                          )),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Profile',
                        style: GoogleFonts.openSans(
                          color: mainColor,
                          fontSize: 15,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return ProfilePage();
                            },
                          ),
                        );
                      },
                    ),

                    ListTile(
                      leading: Icon(
                        Icons.favorite,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Favourites',
                        style: GoogleFonts.openSans(
                          color: mainColor,
                          fontSize: 15,
                        ),
                      ),
                      onTap: () {
                        // await FirebaseFirestore.instance
                        //     .collection("posts")
                        //     .orderBy('createdAt', descending: true)
                        //     .where("userLikes",
                        //         arrayContains:
                        //             FirebaseApi.realUserLastData!.getUsername())
                        //     .snapshots();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Favourites(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.people,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Friends',
                        style: GoogleFonts.openSans(
                          color: mainColor,
                          fontSize: 15,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return friendsPage();
                            },
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.mail,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Messages',
                        style: GoogleFonts.openSans(
                          color: mainColor,
                          fontSize: 15,
                        ),
                      ),
                      onTap: () async {
                        //Navigator.of(context).pop();
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MessagesPage(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.image,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Share Image',
                        style: GoogleFonts.openSans(
                          color: mainColor,
                          fontSize: 15,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AddImage(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.featured_play_list_outlined,
                        color: Colors.white,
                      ),
                      title: Text(
                        'News Feed',
                        style: GoogleFonts.openSans(
                          color: mainColor,
                          fontSize: 15,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => NewsFeed(),
                          ),
                        );
                      },
                    ),
                    // ListTile(
                    //   leading: Icon(
                    //     Icons.notifications,
                    //     color: Colors.white,
                    //   ),
                    //   title: Text(
                    //     'Notifications',
                    //     style: GoogleFonts.arvo(color: mainColor, fontSize: 15),
                    //   ),
                    //   onTap: () {
                    //     // Navigator.of(context).push(
                    //     //   MaterialPageRoute(
                    //     //     builder: (context) => Notifications(),
                    //     //   ),
                    //     // );
                    //   },
                    //   trailing: ClipOval(
                    //     child: Container(
                    //       color: Colors.red.shade300,
                    //       width: 20,
                    //       height: 20,
                    //       child: Center(
                    //         child: Text(
                    //           '23',
                    //           style: TextStyle(
                    //             color: Colors.white,
                    //             fontSize: 12,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    //Divider(),
                    ListTile(
                      leading: Icon(
                        Icons.settings,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Settings',
                        style: GoogleFonts.openSans(
                          color: mainColor,
                          fontSize: 15,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SettingsPage(),
                          ),
                        );
                      },
                    ),
                    // ListTile(
                    //   leading: Icon(
                    //     Icons.policy,
                    //     color: Colors.white,
                    //   ),
                    //   title: Text(
                    //     'Policies',
                    //     style: GoogleFonts.arvo(color: mainColor, fontSize: 15),
                    //   ),
                    //   onTap: () {
                    //     Navigator.pop(context);
                    //     Navigator.of(context).push(
                    //       MaterialPageRoute(
                    //         builder: (context) => Popup(),
                    //       ),
                    //     );
                    //   },
                    // ),
                    //Divider(),
                    ListTile(
                        leading: Icon(
                          Icons.exit_to_app,
                          color: Colors.white,
                        ),
                        title: Text(
                          'Log out',
                          style: GoogleFonts.openSans(
                            color: mainColor,
                            fontSize: 15,
                          ),
                        ),
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return LoginPage();
                              },
                            ),
                          );
                        }),
                  ],
                );
              },
            ),
          )
        : Drawer(
            backgroundColor: secondaryColorSec,
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('RegularUsers')
                  .doc(FirebaseApi.realUserUID)
                  .snapshots(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                var userDocument = snapshot.data;
                return ListView(
                  padding: EdgeInsets.zero,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    UserAccountsDrawerHeader(
                      accountName: Text(userDocument!["username"]),
                      accountEmail: Text(userDocument["email"]),
                      currentAccountPicture: CircleAvatar(
                          backgroundColor: Colors.blue.shade300,
                          child: displayNavbar
                              ? ClipOval(
                                  child: Image.network(
                                    userDocument["profileImage"],
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Shimmer.fromColors(
                                  baseColor: mainColorSec,
                                  highlightColor: Colors.white,
                                  enabled: true,
                                  child: Container(
                                    //padding: EdgeInsets.all(90.0),
                                    width:
                                        MediaQuery.of(context).size.width / 2.2,
                                    height:
                                        MediaQuery.of(context).size.width / 2,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: mainColorSec,
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                            userDocument["profileImage"]),
                                      ),
                                    ),
                                  ),
                                )),
                      decoration: BoxDecoration(
                          color: Colors.blue.shade300,
                          image: DecorationImage(
                            image:
                                NetworkImage(userDocument["backgroundImage"]),
                            fit: BoxFit.cover,
                          )),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Profile',
                        style:
                            GoogleFonts.arvo(color: mainColorSec, fontSize: 15),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return ProfilePage();
                            },
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.favorite,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Favourites',
                        style:
                            GoogleFonts.arvo(color: mainColorSec, fontSize: 15),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Favourites(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.people,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Friends',
                        style:
                            GoogleFonts.arvo(color: mainColorSec, fontSize: 15),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return friendsPage();
                            },
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.mail,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Messages',
                        style:
                            GoogleFonts.arvo(color: mainColorSec, fontSize: 15),
                      ),
                      onTap: () async {
                        //Navigator.of(context).pop();
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MessagesPage(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.image,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Share Image',
                        style:
                            GoogleFonts.arvo(color: mainColorSec, fontSize: 15),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AddImage(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.featured_play_list_outlined,
                        color: Colors.white,
                      ),
                      title: Text(
                        'News Feed',
                        style:
                            GoogleFonts.arvo(color: mainColorSec, fontSize: 15),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => NewsFeed(),
                          ),
                        );
                      },
                    ),
                    // ListTile(
                    //   leading: Icon(
                    //     Icons.notifications,
                    //     color: Colors.white,
                    //   ),
                    //   title: Text(
                    //     'Notifications',
                    //     style:
                    //         GoogleFonts.arvo(color: mainColorSec, fontSize: 15),
                    //   ),
                    //   onTap: () => null,
                    //   trailing: ClipOval(
                    //     child: Container(
                    //       color: Colors.red.shade300,
                    //       width: 20,
                    //       height: 20,
                    //       child: Center(
                    //         child: Text(
                    //           '23',
                    //           style: TextStyle(
                    //             color: Colors.white,
                    //             fontSize: 12,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    //Divider(),
                    ListTile(
                      leading: Icon(
                        Icons.settings,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Settings',
                        style:
                            GoogleFonts.arvo(color: mainColorSec, fontSize: 15),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SettingsPage(),
                          ),
                        );
                      },
                    ),
                    // ListTile(
                    //   leading: Icon(
                    //     Icons.policy,
                    //     color: Colors.white,
                    //   ),
                    //   title: Text(
                    //     'Policies',
                    //     style:
                    //         GoogleFonts.arvo(color: mainColorSec, fontSize: 15),
                    //   ),
                    //   onTap: () => null,
                    // ),
                    // Divider(),
                    ListTile(
                        leading: Icon(
                          Icons.exit_to_app,
                          color: Colors.white,
                        ),
                        title: Text(
                          'Log out',
                          style: GoogleFonts.arvo(
                              color: mainColorSec, fontSize: 15),
                        ),
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return LoginPage();
                              },
                            ),
                          );
                        }),
                  ],
                );
              },
            ),
          );
  }
}
