// ignore_for_file: prefer_const_constructors, unnecessary_new

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:overlook/components/firebase_api.dart';
import 'package:overlook/constants.dart';
import 'package:overlook/new/changeProfile.dart';
import 'package:overlook/new/popup_test.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../Screens/Profile/numbers_widget.dart';
import '../components/globals.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'dart:ui' as ui;

int followers = 0;
int following = 0;
int posts = 0;

bool stopShimmer = true;
double topDistanceForUserDetails = 200;
bool aboutSet = false;
bool postsSet = true;

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    print("INIT");
    if (Globals.getFirstLoadProfile() == false) {
      Timer _timer = new Timer(const Duration(milliseconds: 2000), () {
        setState(() {
          stopShimmer = false;

          Globals.changeFirstLoadProfile();
        });
      });
      Timer _timer3 = new Timer(const Duration(milliseconds: 3500), () {
        setState(() {
          displayPostsProfile = true;
        });
      });
    } else {
      stopShimmer = false;
      Timer _timer2 = new Timer(const Duration(milliseconds: 1500), () {
        setState(() {
          displayPostsProfile = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return changedColors
        ? Scaffold(
            backgroundColor: secondaryColor,
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
                backgroundColor: secondaryColor,
                leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      displayPostsProfile = false;
                      Navigator.pop(context);
                    }),
              ),
            ),
            body: Scaffold(
              backgroundColor: secondaryColor,
              body: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('RegularUsers')
                      .doc(FirebaseApi.realUserUID)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Text("Loading");
                    }

                    var userDocument = snapshot.data;

                    if (userDocument!["about"] != "") {
                      aboutSet = true;
                    }
                    followers = userDocument["followers"].length;
                    following = userDocument["following"].length;
                    posts = userDocument["posts"].length;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        new Positioned(
                          top: 0,
                          right: 0,
                          left: 0,
                          child: stopShimmer
                              ? Shimmer.fromColors(
                                  baseColor: Colors.grey,
                                  highlightColor: Colors.white,
                                  enabled: stopShimmer,
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.width / 2.2,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                            userDocument["profileImage"]),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  height:
                                      MediaQuery.of(context).size.width / 2.2,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                          userDocument["backgroundImage"]),
                                    ),
                                  ),
                                ),
                        ),

                        // ignore: unnecessary_new

                        new Positioned(
                          top: 50,
                          left: MediaQuery.of(context).size.width / 3.8,
                          child: stopShimmer
                              ? Shimmer.fromColors(
                                  baseColor: Colors.grey,
                                  highlightColor: Colors.white,
                                  enabled: stopShimmer,
                                  child: Container(
                                    //padding: EdgeInsets.all(90.0),
                                    width:
                                        MediaQuery.of(context).size.width / 2.2,
                                    height:
                                        MediaQuery.of(context).size.width / 2,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: mainColor,
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                            userDocument["profileImage"]),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  //padding: EdgeInsets.all(90.0),
                                  width:
                                      MediaQuery.of(context).size.width / 2.2,
                                  height: MediaQuery.of(context).size.width / 2,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: mainColor,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                          userDocument["profileImage"]),
                                    ),
                                  ),
                                ),
                        ),

                        new Positioned(
                          top: 160,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 370, left: 150),
                            child: CircleAvatar(
                              backgroundColor: mainColor,
                              child: IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChangeProfile()),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        new Positioned(
                            top: 225,
                            child: NumbersWidget(
                                userDocument["FollowersNumber"],
                                userDocument["FollowingNumber"])),
                        Container(
                          height: 120,
                          margin: EdgeInsets.fromLTRB(5, 20, 5, 0),
                          alignment: Alignment.bottomLeft,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                TextField(
                                  readOnly: true,
                                  decoration: InputDecoration(
                                      label: Text(
                                        "Username",
                                        style: TextStyle(
                                          color: mainColor,
                                          fontSize: 22,
                                        ),
                                      ),
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always,
                                      hintText: userDocument["username"],
                                      hintStyle:
                                          TextStyle(color: Colors.white)),
                                ),
                                aboutSet
                                    ? TextField(
                                        readOnly: true,
                                        decoration: InputDecoration(
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                            label: Text(
                                              "About",
                                              style: TextStyle(
                                                color: mainColor,
                                                fontSize: 22,
                                              ),
                                            ),
                                            hintText: userDocument["about"],
                                            hintStyle:
                                                TextStyle(color: Colors.white)),
                                      )
                                    : SizedBox(
                                        height: 20,
                                      ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(5, 420, 5, 0),
                          height: 250,
                          child: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('posts')
                                  .where("owner",
                                      isEqualTo: userDocument["username"])
                                  .where("postType",
                                      isNotEqualTo: "profileChange")
                                  .orderBy("postType", descending: true)
                                  .orderBy("createdAt", descending: true)
                                  .snapshots(),
                              builder: (BuildContext context2,
                                  AsyncSnapshot<
                                          QuerySnapshot<Map<String, dynamic>>>
                                      snapshot2) {
                                int docLen = snapshot2.data!.docs.length;

                                return GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithMaxCrossAxisExtent(
                                            maxCrossAxisExtent: 150,
                                            childAspectRatio: 1,
                                            crossAxisSpacing: 20,
                                            mainAxisSpacing: 20),
                                    itemCount: docLen,
                                    itemBuilder: (BuildContext ctx, index) {
                                      DocumentSnapshot document2 =
                                          snapshot2.data!.docs[index];

                                      String postID = document2.id;
                                      String likes =
                                          document2["likes"].toString();

                                      print(document2["owner"]);

                                      return displayPostsProfile
                                          ? GestureDetector(
                                              onTap: () async {
                                                await showDialog(
                                                    context: context,
                                                    builder: (_) => ImageDialog(
                                                        postID,
                                                        document2["imageURL"],
                                                        likes,
                                                        true));
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                  image: NetworkImage(
                                                      document2["imageURL"]),
                                                  fit: BoxFit.cover,
                                                )),
                                              ),
                                            )
                                          : Shimmer.fromColors(
                                              baseColor: mainColor,
                                              highlightColor: Colors.white,
                                              enabled: true,
                                              child: Container(
                                                //padding: EdgeInsets.all(90.0),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2.2,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2,
                                                decoration: BoxDecoration(
                                                  color: mainColor,
                                                  image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: NetworkImage(
                                                        document2["imageURL"]),
                                                  ),
                                                ),
                                              ),
                                            );
                                    });
                              }),
                        ),
                      ],
                    );
                  }),
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
                    onPressed: () {
                      displayPostsProfile = false;
                      Navigator.pop(context);
                    }),
              ),
            ),
            body: Scaffold(
              backgroundColor: secondaryColorSec,
              body: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('RegularUsers')
                      .doc(FirebaseApi.realUserUID)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Text("Loading");
                    }

                    var userDocument = snapshot.data;
                    if (userDocument!["about"] != "") {
                      aboutSet = true;
                    }
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        new Positioned(
                          top: 0,
                          right: 0,
                          left: 0,
                          child: stopShimmer
                              ? Shimmer.fromColors(
                                  baseColor: Colors.grey,
                                  highlightColor: Colors.white,
                                  enabled: stopShimmer,
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.width / 2.2,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                            userDocument["profileImage"]),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  height:
                                      MediaQuery.of(context).size.width / 2.2,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                          userDocument["backgroundImage"]),
                                    ),
                                  ),
                                ),
                        ),

                        // ignore: unnecessary_new

                        new Positioned(
                          top: 50,
                          left: MediaQuery.of(context).size.width / 3.8,
                          child: stopShimmer
                              ? Shimmer.fromColors(
                                  baseColor: Colors.grey,
                                  highlightColor: Colors.white,
                                  enabled: stopShimmer,
                                  child: Container(
                                    //padding: EdgeInsets.all(90.0),
                                    width:
                                        MediaQuery.of(context).size.width / 2.2,
                                    height:
                                        MediaQuery.of(context).size.width / 2,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: mainColorSec,
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                            userDocument["profileImage"]),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  //padding: EdgeInsets.all(90.0),
                                  width:
                                      MediaQuery.of(context).size.width / 2.2,
                                  height: MediaQuery.of(context).size.width / 2,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: mainColorSec,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                          userDocument["profileImage"]),
                                    ),
                                  ),
                                ),
                        ),

                        new Positioned(
                          top: 160,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 370, left: 150),
                            child: CircleAvatar(
                              backgroundColor: mainColorSec,
                              child: IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChangeProfile()),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        new Positioned(
                            top: 225,
                            child: NumbersWidget(
                                userDocument["FollowersNumber"],
                                userDocument["FollowingNumber"])),
                        Container(
                          height: 120,
                          margin: EdgeInsets.fromLTRB(5, 20, 5, 0),
                          alignment: Alignment.bottomLeft,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                TextField(
                                  readOnly: true,
                                  decoration: InputDecoration(
                                      label: Text(
                                        "Username",
                                        style: TextStyle(
                                          color: mainColorSec,
                                          fontSize: 22,
                                        ),
                                      ),
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always,
                                      hintText: userDocument["username"],
                                      hintStyle:
                                          TextStyle(color: Colors.white)),
                                ),
                                aboutSet
                                    ? TextField(
                                        readOnly: true,
                                        decoration: InputDecoration(
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                            label: Text(
                                              "About",
                                              style: TextStyle(
                                                color: mainColorSec,
                                                fontSize: 22,
                                              ),
                                            ),
                                            hintText: userDocument["about"],
                                            hintStyle:
                                                TextStyle(color: Colors.white)),
                                      )
                                    : SizedBox(
                                        height: 20,
                                      ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(5, 420, 5, 0),
                          height: 250,
                          child: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('posts')
                                  .orderBy("createdAt", descending: true)
                                  .where("owner",
                                      isEqualTo: userDocument["username"])
                                  .snapshots(),
                              builder: (BuildContext context2,
                                  AsyncSnapshot<
                                          QuerySnapshot<Map<String, dynamic>>>
                                      snapshot2) {
                                int docLen = snapshot2.data!.docs.length;

                                return GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithMaxCrossAxisExtent(
                                            maxCrossAxisExtent: 150,
                                            childAspectRatio: 1,
                                            crossAxisSpacing: 20,
                                            mainAxisSpacing: 20),
                                    itemCount: docLen,
                                    itemBuilder: (BuildContext ctx, index) {
                                      DocumentSnapshot document2 =
                                          snapshot2.data!.docs[index];

                                      String postID = document2.id;
                                      String likes =
                                          document2["likes"].toString();

                                      print(document2["owner"]);

                                      return displayPostsProfile
                                          ? GestureDetector(
                                              onTap: () async {
                                                await showDialog(
                                                    context: context,
                                                    builder: (_) => ImageDialog(
                                                        postID,
                                                        document2["imageURL"],
                                                        likes,
                                                        false));
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                  image: NetworkImage(
                                                      document2["imageURL"]),
                                                  fit: BoxFit.cover,
                                                )),
                                              ),
                                            )
                                          : Shimmer.fromColors(
                                              baseColor: mainColorSec,
                                              highlightColor: Colors.white,
                                              enabled: true,
                                              child: Container(
                                                //padding: EdgeInsets.all(90.0),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2.2,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2,
                                                decoration: BoxDecoration(
                                                  color: mainColorSec,
                                                  image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: NetworkImage(
                                                        document2["imageURL"]),
                                                  ),
                                                ),
                                              ),
                                            );
                                    });
                              }),
                        ),

                        // Positioned(
                        //   top: 550,
                        //   child: Container(
                        //     color: Colors.red,
                        //     height: 200,
                        //   ),
                        // )
                        // Expanded(
                        //   child: StreamBuilder(
                        //       stream: FirebaseFirestore.instance
                        //           .collection('RegularUsers')
                        //           .doc(FirebaseApi.realUserUID)
                        //           .collection("posts")
                        //           .orderBy("createdAt", descending: true)
                        //           .snapshots(),
                        //       builder: (BuildContext context2,
                        //           AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        //               snapshot2) {
                        //         int docLen = snapshot2.data!.docs.length;

                        //         for (int i = 0; i < docLen; i++) {
                        //           DocumentSnapshot document2 = snapshot2.data!.docs[i];
                        //           return Image.network(document2["imageURL"]);
                        //         }
                        //         return SizedBox();
                        //       }),
                        // ),
                      ],
                    );
                  }),
            ),
          );
  }
}
