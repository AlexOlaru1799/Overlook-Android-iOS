// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:overlook/components/firebase_api.dart';
import 'package:overlook/constants.dart';
import 'package:overlook/main.dart';

String searchText = "";

class friendsPage extends StatelessWidget {
  const friendsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return changedColors
        ? Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(35),
              child: AppBar(
                title: Text(
                  "Your friends",
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                elevation: 0.0,
                backgroundColor: Color.fromARGB(255, 32, 32, 32),
                leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white38,
                    ),
                    onPressed: () {
                      searchText = "";
                      Navigator.pop(context);
                    }),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    color: secondaryColor,
                    height: MediaQuery.of(context).size.height / 10,
                    width: MediaQuery.of(context).size.width,
                    child: Row(children: [
                      //TextField(),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Container(
                          height: 100,
                          width: MediaQuery.of(context).size.width / 1.5,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search user..',
                              hintStyle: TextStyle(color: mainColor),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: mainColor),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: mainColor),
                              ),
                            ),
                            style: TextStyle(color: Colors.white),
                            onChanged: ((value) => searchText = value),
                          ),
                        ),
                      ),
                      Spacer(),
                      Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Icon(
                            Icons.search_rounded,
                            color: mainColor,
                            size: 50,
                          ))
                    ]),
                  ),
                  Container(
                    color: secondaryColor,
                    height: MediaQuery.of(context).size.height / 1.15,
                    width: MediaQuery.of(context).size.width,
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("RegularUsers")
                          .doc(FirebaseApi.realUserUID)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                              snapshot) {
                        if (snapshot.hasError)
                          return new Text('Error: ${snapshot.error}');
                        else {
                          List followingList = snapshot.data!["following"];
                          print(followingList);
                          return ListView.builder(
                            itemCount: followingList.length,
                            itemBuilder: (context, index) {
                              //return Text(followingList[index]);
                              return StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection("RegularUsers")
                                    .where("username",
                                        isEqualTo: followingList[index])
                                    .snapshots(),
                                builder: (BuildContext context2,
                                    AsyncSnapshot<
                                            QuerySnapshot<Map<String, dynamic>>>
                                        snapshot2) {
                                  DocumentSnapshot document =
                                      snapshot2.data!.docs[0];
                                  String username = document["username"];
                                  String email = document["email"];
                                  double username_len = 17;
                                  double email_len = 17;
                                  if (username.length.toDouble() > 20) {
                                    username_len =
                                        username.length.toDouble() * 2 / 5;
                                  }
                                  if (email.length.toDouble() > 15) {
                                    email_len =
                                        1 / email.length.toDouble() * 250;
                                  }
                                  if (snapshot2.hasError) {
                                    return Text("Error!");
                                  } else {
                                    //return Text(document["username"]);

                                    if (searchText != "") {
                                      if (document["username"]
                                          .contains(searchText)) {
                                        return Container(
                                          height: 120,
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                5, 5, 5, 8),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                FirebaseApi.seeOtherProfile(
                                                    document["UID"], context);
                                              },
                                              child: Column(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(
                                                          color: mainColor,
                                                          width: 3,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    15))),
                                                    height: 100,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5),
                                                      child: Row(
                                                        children: [
                                                          CircleAvatar(
                                                            radius: 33,
                                                            backgroundColor:
                                                                mainColor,
                                                            child: CircleAvatar(
                                                                radius: 30.0,
                                                                backgroundColor:
                                                                    Colors.blue
                                                                        .shade300,
                                                                child: ClipOval(
                                                                  child: Image
                                                                      .network(
                                                                    document[
                                                                        "profileImage"],
                                                                    width: 120,
                                                                    height: 120,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                )),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    5,
                                                                    25,
                                                                    1,
                                                                    0),
                                                            child: Column(
                                                              children: [
                                                                Text(
                                                                  document[
                                                                      "username"],
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        username_len,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color:
                                                                        secondaryColor,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  document[
                                                                      "email"],
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        email_len,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white,
                                                                    decoration:
                                                                        TextDecoration
                                                                            .underline,
                                                                    decorationStyle:
                                                                        TextDecorationStyle
                                                                            .double,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        return SizedBox();
                                      }
                                    } else {
                                      bool colorTemp;
                                      if (index % 2 == 0) {
                                        colorTemp = false;
                                      } else {
                                        colorTemp = true;
                                      }
                                      return Container(
                                        height: 120,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 5, 5, 5),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                primary: secondaryColor,
                                                onPrimary: secondaryColor,
                                                textStyle: TextStyle(
                                                    fontSize: 30,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            onPressed: () {
                                              FirebaseApi.seeOtherProfile(
                                                  document["UID"], context);
                                            },
                                            child: Column(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                      color: colorTemp
                                                          ? mainColor
                                                          : secondaryColor,
                                                      border: Border.all(
                                                        color: Colors.white,
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  15))),
                                                  height: 100,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    child: Row(
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 37,
                                                          backgroundColor:
                                                              secondaryColor,
                                                          child: CircleAvatar(
                                                              radius: 35.0,
                                                              backgroundColor:
                                                                  Colors.blue
                                                                      .shade300,
                                                              child: ClipOval(
                                                                child: Image
                                                                    .network(
                                                                  document[
                                                                      "profileImage"],
                                                                  width: 135,
                                                                  height: 135,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              )),
                                                        ),
                                                        Spacer(),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  5, 25, 1, 0),
                                                          child: Column(
                                                            children: [
                                                              Text(
                                                                document[
                                                                    "username"],
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      username_len,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                              Text(
                                                                document[
                                                                    "email"],
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      email_len,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .underline,
                                                                  decorationStyle:
                                                                      TextDecorationStyle
                                                                          .double,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        Spacer(),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        : Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(35),
              child: AppBar(
                title: Text(
                  "Your friends",
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                elevation: 0.0,
                backgroundColor: Color.fromARGB(255, 32, 32, 32),
                leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white38,
                    ),
                    onPressed: () => Navigator.pop(context)),
              ),
            ),
            body: Container(
              color: secondaryColorSec,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("RegularUsers")
                    .doc(FirebaseApi.realUserUID)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.hasError)
                    return new Text('Error: ${snapshot.error}');
                  else {
                    List followingList = snapshot.data!["following"];
                    return ListView.builder(
                      itemCount: followingList.length,
                      itemBuilder: (context, index) {
                        //return Text(followingList[index]);
                        return StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("RegularUsers")
                              .where("username",
                                  isEqualTo: followingList[index])
                              .snapshots(),
                          builder: (BuildContext context2,
                              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                                  snapshot2) {
                            DocumentSnapshot document = snapshot2.data!.docs[0];
                            String username = document["username"];
                            String email = document["email"];
                            double username_len = 17;
                            double email_len = 17;
                            if (username.length.toDouble() > 20) {
                              username_len = username.length.toDouble() * 2 / 5;
                            }
                            if (email.length.toDouble() > 20) {
                              email_len = email.length.toDouble() * 2 / 10;
                            }
                            if (snapshot2.hasError) {
                              return Text("Error!");
                            } else {
                              //return Text(document["username"]);
                              return Container(
                                height: 120,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(5, 5, 5, 8),
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            color: mainColorSec,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 3,
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15))),
                                        height: 100,
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 33,
                                                backgroundColor:
                                                    secondaryColorSec,
                                                child: CircleAvatar(
                                                    radius: 30.0,
                                                    backgroundColor:
                                                        Colors.blue.shade300,
                                                    child: ClipOval(
                                                      child: Image.network(
                                                        document[
                                                            "profileImage"],
                                                        width: 120,
                                                        height: 120,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    )),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        5, 25, 1, 0),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      document["username"],
                                                      style: TextStyle(
                                                        fontSize: username_len,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: thirdColor,
                                                      ),
                                                    ),
                                                    Text(
                                                      document["email"],
                                                      style: TextStyle(
                                                        fontSize: email_len,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: thirdColor,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                        decorationStyle:
                                                            TextDecorationStyle
                                                                .double,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Spacer(),
                                              ElevatedButton(
                                                onPressed: () {
                                                  FirebaseApi.seeOtherProfile(
                                                      document["UID"], context);
                                                },
                                                child: Text("See profile"),
                                                style: ElevatedButton.styleFrom(
                                                  primary: secondaryColorSec,
                                                  onPrimary: Colors.white,
                                                  side: BorderSide(
                                                      color: secondaryColorSec,
                                                      width: 2),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          );
  }
}
