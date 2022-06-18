// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:overlook/components/firebase_api.dart';
import 'package:overlook/constants.dart';
import 'package:overlook/new/comments.dart';
import 'package:overlook/new/singleChat.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import '../components/utils.dart';

import 'dart:async';

import 'dart:io';

List<Post> posts = [];
List followings = [];

class NewsFeed extends StatefulWidget {
  const NewsFeed({Key? key}) : super(key: key);

  @override
  State<NewsFeed> createState() => _NewsFeedState();
}

void waitForFollowing() async {
  followings = await FirebaseApi.getFollowingList();
}

class _NewsFeedState extends State<NewsFeed> {
  @override
  void initState() {
    super.initState();
    Timer _timer3 = new Timer(const Duration(milliseconds: 2250), () {
      setState(() {
        loadNews = true;
        print("done");
      });
    });
    setState(() {
      waitForFollowing();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(35),
        child: AppBar(
          title: Text(
            "News Feed",
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
                loadNews = false;
                Navigator.pop(context);
              }),
        ),
      ),
      body: Row(
        children: [
          Container(
              color: secondaryColor,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("posts")
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasError)
                    return new Text('Error: ${snapshot.error}');
                  else {
                    return SingleChildScrollView(
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: ((context, index) {
                          DocumentSnapshot document =
                              snapshot.data!.docs[index];
                          Timestamp timestamp = document['createdAt'];
                          DateTime date = timestamp.toDate();
                          String postID = document.id;
                          String postType = document["postType"];
                          String actionText = "";

                          if (postType == "addImage") {
                            actionText = " has posted a new photo!";
                          }

                          if (postType == "profileChange") {
                            actionText = " has changed their profile picture!";
                          }

                          var _today = DateTime.parse(date.toString());
                          var _formatToday =
                              DateFormat.yMMMMEEEEd().format(date);

                          return StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection("RegularUsers")
                                  .where("username",
                                      isEqualTo: document["owner"])
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<dynamic> snapshot) {
                                if (snapshot.hasData) {
                                  DocumentSnapshot document2 =
                                      snapshot.data!.docs[0];
                                  if (followings.contains(document["owner"])) {
                                    return Card(
                                      child: Container(
                                        height: 350,
                                        color: secondaryColor,
                                        child: Column(children: <Widget>[
                                          ListTile(
                                            leading: loadNews
                                                ? CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(document2[
                                                            "profileImage"]),
                                                  )
                                                : Shimmer.fromColors(
                                                    baseColor: mainColor,
                                                    highlightColor:
                                                        Colors.white,
                                                    enabled: true,
                                                    child: CircleAvatar(
                                                      backgroundImage:
                                                          NetworkImage(document2[
                                                              "profileImage"]),
                                                    )),
                                            title: Text.rich(
                                              TextSpan(
                                                  style: TextStyle(
                                                    color: mainColor,
                                                    fontSize: 14,
                                                  ),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                        text: document["owner"],
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: mainColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    TextSpan(text: actionText),
                                                  ]),
                                            ),
                                            subtitle: Text(_formatToday,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                )), // make different actions for posts such as profile update/ post
                                          ),
                                          Expanded(
                                              child: loadNews
                                                  ? Container(
                                                      decoration: BoxDecoration(
                                                          image:
                                                              DecorationImage(
                                                        image: NetworkImage(
                                                            document[
                                                                "imageURL"]),
                                                        fit: BoxFit.fitHeight,
                                                      )),
                                                    )
                                                  : Shimmer.fromColors(
                                                      baseColor: mainColor,
                                                      highlightColor:
                                                          Colors.white,
                                                      enabled: true,
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                                image:
                                                                    DecorationImage(
                                                          image: NetworkImage(
                                                              document[
                                                                  "imageURL"]),
                                                          fit: BoxFit.cover,
                                                        )),
                                                      ))),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                12, 2, 0, 0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                document["text"],
                                                style: TextStyle(
                                                  color: mainColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: Icon(Icons
                                                        .thumb_up_alt_outlined),
                                                    color: mainColor,
                                                    onPressed: () {
                                                      FirebaseApi.likePost(
                                                          postID);
                                                    },
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                      document["likes"]
                                                          .toString(),
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    "Likes",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Comments(
                                                                  postID)));
                                                },
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.comment_rounded,
                                                        color: mainColor),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text("Comments",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)),
                                                  ],
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () async {
                                                  String imageURL =
                                                      document["imageURL"];

                                                  final url =
                                                      Uri.parse(imageURL);
                                                  final response =
                                                      await http.get(url);
                                                  final bytes =
                                                      response.bodyBytes;

                                                  final temp =
                                                      await getTemporaryDirectory();
                                                  final path =
                                                      '${temp.path}/image.jpg';
                                                  File(path)
                                                      .writeAsBytesSync(bytes);

                                                  await Share.shareFiles([path],
                                                      text: document["text"] +
                                                          "\n\n" +
                                                          "Shared by " +
                                                          document["owner"] +
                                                          " on Overlook!" +
                                                          "Get the app now! \n" +
                                                          "http://wwww.overlook.com");
                                                },
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.link_rounded,
                                                      color: mainColor,
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text("Share",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 13,
                                          ),
                                        ]),
                                      ),
                                    );
                                  } else if (document["owner"] ==
                                      FirebaseApi.realUserLastData!
                                          .getUsername()) {
                                    return Card(
                                      child: Container(
                                        height: 450,
                                        color: secondaryColor,
                                        child: Column(children: <Widget>[
                                          ListTile(
                                            leading: loadNews
                                                ? CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(document2[
                                                            "profileImage"]),
                                                  )
                                                : Shimmer.fromColors(
                                                    baseColor: mainColor,
                                                    highlightColor:
                                                        Colors.white,
                                                    enabled: true,
                                                    child: CircleAvatar(
                                                      backgroundImage:
                                                          NetworkImage(document2[
                                                              "profileImage"]),
                                                    )),
                                            title: Text.rich(
                                              TextSpan(
                                                  style: TextStyle(
                                                    color: mainColor,
                                                    fontSize: 14,
                                                  ),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                        text: document["owner"],
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: mainColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    TextSpan(text: actionText),
                                                  ]),
                                            ),
                                            subtitle: Text(_formatToday,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                )), // make different actions for posts such as profile update/ post
                                          ),
                                          Expanded(
                                              child: loadNews
                                                  ? Container(
                                                      decoration: BoxDecoration(
                                                          image:
                                                              DecorationImage(
                                                        image: NetworkImage(
                                                            document[
                                                                "imageURL"]),
                                                        fit: BoxFit.contain,
                                                      )),
                                                    )
                                                  : Shimmer.fromColors(
                                                      baseColor: mainColor,
                                                      highlightColor:
                                                          Colors.white,
                                                      enabled: true,
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                                image:
                                                                    DecorationImage(
                                                          image: NetworkImage(
                                                              document[
                                                                  "imageURL"]),
                                                          fit: BoxFit.cover,
                                                        )),
                                                      ))),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                12, 2, 0, 0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                document["text"],
                                                style: TextStyle(
                                                  color: mainColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: Icon(Icons
                                                        .thumb_up_alt_outlined),
                                                    color: mainColor,
                                                    onPressed: () {
                                                      FirebaseApi.likePost(
                                                          postID);
                                                    },
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                      document["likes"]
                                                          .toString(),
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    "Likes",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Comments(
                                                                  postID)));
                                                },
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.comment_rounded,
                                                        color: mainColor),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text("Comments",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)),
                                                  ],
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () async {
                                                  String imageURL =
                                                      document["imageURL"];

                                                  final url =
                                                      Uri.parse(imageURL);
                                                  final response =
                                                      await http.get(url);
                                                  final bytes =
                                                      response.bodyBytes;

                                                  final temp =
                                                      await getTemporaryDirectory();
                                                  final path =
                                                      '${temp.path}/image.jpg';
                                                  File(path)
                                                      .writeAsBytesSync(bytes);

                                                  await Share.shareFiles([path],
                                                      text: document["text"] +
                                                          "\n\n" +
                                                          "Shared by " +
                                                          document["owner"] +
                                                          " on Overlook!" +
                                                          "Get the app now! \n" +
                                                          "http://wwww.overlook.com");
                                                },
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.link_rounded,
                                                      color: mainColor,
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text("Share",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 13,
                                          ),
                                        ]),
                                      ),
                                    );
                                  } else {
                                    return SizedBox(
                                      height: 1,
                                    );
                                  }
                                } else {
                                  return SizedBox(
                                    height: 1,
                                  );
                                }
                              });
                        }),
                      ),
                    );
                  }
                },
              )),
        ],
      ),
    );
  }
}
