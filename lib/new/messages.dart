// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:overlook/components/firebase_api.dart';
import 'package:overlook/constants.dart';
import 'package:intl/intl.dart';
import 'package:overlook/new/singleChat.dart';

String searchChat = "";

class MessagesPage extends StatelessWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(35),
        child: AppBar(
          title: Text(
            "Your open chats",
            style: TextStyle(
              fontSize: 15,
            ),
          ),
          elevation: 0.0,
          backgroundColor: Color.fromARGB(255, 32, 32, 32),
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                searchChat = "";
                Navigator.pop(context);
              }),
        ),
      ),
      body: Container(
          color: secondaryColor,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(5, 5, 0, 0),
                height: MediaQuery.of(context).size.height / 10,
                width: MediaQuery.of(context).size.width,
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("rooms")
                        .orderBy("lastMessage", descending: true)
                        .where("UserUIDs",
                            arrayContains: FirebaseApi.realUserUID)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      return GridView.builder(
                          scrollDirection: Axis.horizontal,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 200,
                                  childAspectRatio: 1,
                                  crossAxisSpacing: 2,
                                  mainAxisSpacing: 35),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: ((context, index) {
                            String? otherUID;
                            DocumentSnapshot document =
                                snapshot.data!.docs[index];
                            String docUID = document.reference.id;
                            if (FirebaseApi.realUserUID ==
                                document["UserUIDs"][0]) {
                              otherUID = document["UserUIDs"][1];
                            } else {
                              otherUID = document["UserUIDs"][0];
                            }

                            return StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection("RegularUsers")
                                    .where("UID", isEqualTo: otherUID)
                                    .snapshots(),
                                builder: (BuildContext context3,
                                    AsyncSnapshot<
                                            QuerySnapshot<Map<String, dynamic>>>
                                        snapshot3) {
                                  DocumentSnapshot document2 =
                                      snapshot3.data!.docs[0];

                                  return Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    singleChat(
                                                        otherUID!,
                                                        document2["username"],
                                                        docUID)),
                                          );
                                        },
                                        child: CircleAvatar(
                                          radius: 20,
                                          backgroundColor: mainColor,
                                          child: CircleAvatar(
                                              radius: 40.0,
                                              backgroundColor: mainColor,
                                              child: ClipOval(
                                                child: Image.network(
                                                  document2["profileImage"],
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      2,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  fit: BoxFit.cover,
                                                ),
                                              )),
                                        ),
                                      ),
                                      Text(
                                        document2["username"],
                                        style: TextStyle(
                                            color: mainColor,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                35),
                                      )
                                    ],
                                  );
                                });
                          }));
                    }),
              ),
              Divider(
                color: thirdColor,
                height: 20,
                thickness: 1.5,
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  child: Row(children: [
                    Flexible(
                      child: TextFormField(
                        style: TextStyle(color: thirdColor),
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color: thirdColor),
                          labelText: 'Search chat...',
                          focusColor: mainColor,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: thirdColor),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: mainColor),
                          ),
                        ),
                        onChanged: (value) {
                          searchChat = value;
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.search_rounded),
                      color: mainColor,
                    ),
                  ]),
                ),
              ),
              Flexible(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("rooms")
                      .orderBy("lastMessage", descending: true)
                      .where("UserUIDs", arrayContains: FirebaseApi.realUserUID)
                      .snapshots(),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasError)
                      return new Text('Error: ${snapshot.error}');
                    else {
                      return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: ((context, index) {
                            DocumentSnapshot document =
                                snapshot.data!.docs[index];
                            String docUID = document.reference.id;
                            String? otherUID;
                            if (FirebaseApi.realUserUID ==
                                document["UserUIDs"][0]) {
                              otherUID = document["UserUIDs"][1];
                            } else {
                              otherUID = document["UserUIDs"][0];
                            }

                            //return Text(document["createdAT"].toString());

                            return StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection("rooms")
                                  .doc(docUID)
                                  .collection("messages")
                                  .orderBy("createdAT", descending: true)
                                  .snapshots(),
                              builder: (BuildContext context2,
                                  AsyncSnapshot<
                                          QuerySnapshot<Map<String, dynamic>>>
                                      snapshot2) {
                                if (snapshot2.hasError) {
                                  return Text("Error!");
                                } else {
                                  DocumentSnapshot document2 =
                                      snapshot2.data!.docs[0];

                                  Timestamp timestamp = document2['createdAT'];
                                  DateTime date = timestamp.toDate();
                                  var _today = DateTime.parse(date.toString());
                                  var _formatToday =
                                      DateFormat.yMMMd().format(date);

                                  bool? realAuthor;
                                  if (document2["authorID"] ==
                                      FirebaseApi.realUserUID) {
                                    realAuthor = true;
                                  } else {
                                    realAuthor = false;
                                  }

                                  String lastMessage = "";
                                  String shortName = "";

                                  if (document2["text"] != "") {
                                    if (document2["text"].length > 10) {
                                      lastMessage =
                                          document2["text"].substring(0, 10) +
                                              "...";
                                    } else {
                                      lastMessage = document2["text"];
                                    }

                                    return StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection("RegularUsers")
                                          .where("UID", isEqualTo: otherUID)
                                          .snapshots(),
                                      builder: (BuildContext context3,
                                          AsyncSnapshot<
                                                  QuerySnapshot<
                                                      Map<String, dynamic>>>
                                              snapshot3) {
                                        DocumentSnapshot document3 =
                                            snapshot3.data!.docs[0];
                                        String otherUsername =
                                            document3["username"];

                                        if (searchChat != "") {
                                          if (otherUsername
                                              .contains(searchChat)) {
                                            if (otherUsername.length > 10) {
                                              shortName = "They";
                                            } else {
                                              shortName = otherUsername;
                                            }
                                            if (snapshot3.hasError) {
                                              return Text("Error!");
                                            } else {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 5, 0, 0),
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: secondaryColor,
                                                    elevation: 0,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              singleChat(
                                                                  otherUID!,
                                                                  otherUsername,
                                                                  docUID)),
                                                    );
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: secondaryColor,
                                                        border: Border.all(
                                                          color: mainColor,
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10))),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        children: [
                                                          Column(
                                                            children: [
                                                              CircleAvatar(
                                                                radius: 25,
                                                                backgroundColor:
                                                                    mainColor,
                                                                child:
                                                                    CircleAvatar(
                                                                        radius:
                                                                            35.0,
                                                                        backgroundColor:
                                                                            mainColor,
                                                                        child:
                                                                            ClipOval(
                                                                          child:
                                                                              Image.network(
                                                                            document3["profileImage"],
                                                                            width:
                                                                                50,
                                                                            height:
                                                                                50,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        )),
                                                              ),
                                                              Text(
                                                                document3[
                                                                    "username"],
                                                                style: TextStyle(
                                                                    fontSize: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        30),
                                                              ),
                                                            ],
                                                          ),
                                                          Spacer(),
                                                          realAuthor!
                                                              ? Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          0.0),
                                                                  child:
                                                                      Container(
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Text(
                                                                          "You: " +
                                                                              lastMessage,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                MediaQuery.of(context).size.width / 30,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              5,
                                                                        ),
                                                                        Text(
                                                                          _formatToday,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                )
                                                              : Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          0.0),
                                                                  child:
                                                                      Container(
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Text(
                                                                          shortName +
                                                                              ": " +
                                                                              lastMessage,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                MediaQuery.of(context).size.width / 30,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              5,
                                                                        ),
                                                                        Text(
                                                                          _formatToday,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                12,
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
                                                ),
                                              );
                                            }
                                          } else {
                                            return SizedBox();
                                          }
                                        } else {
                                          if (otherUsername.length > 10) {
                                            shortName = "They";
                                          } else {
                                            shortName = otherUsername;
                                          }
                                          if (snapshot3.hasError) {
                                            return Text("Error!");
                                          } else {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 5, 0, 0),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  primary: secondaryColor,
                                                  elevation: 0,
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            singleChat(
                                                                otherUID!,
                                                                otherUsername,
                                                                docUID)),
                                                  );
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: secondaryColor,
                                                      border: Border.all(
                                                        color: mainColor,
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10))),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      children: [
                                                        Column(
                                                          children: [
                                                            CircleAvatar(
                                                              radius: 25,
                                                              backgroundColor:
                                                                  mainColor,
                                                              child:
                                                                  CircleAvatar(
                                                                      radius:
                                                                          35.0,
                                                                      backgroundColor:
                                                                          mainColor,
                                                                      child:
                                                                          ClipOval(
                                                                        child: Image
                                                                            .network(
                                                                          document3[
                                                                              "profileImage"],
                                                                          width:
                                                                              50,
                                                                          height:
                                                                              50,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                      )),
                                                            ),
                                                            Text(
                                                              document3[
                                                                  "username"],
                                                              style: TextStyle(
                                                                  fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      30),
                                                            ),
                                                          ],
                                                        ),
                                                        Spacer(),
                                                        realAuthor!
                                                            ? Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        0.0),
                                                                child:
                                                                    Container(
                                                                  child: Column(
                                                                    children: [
                                                                      Text(
                                                                        "You: " +
                                                                            lastMessage,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              MediaQuery.of(context).size.width / 30,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            5,
                                                                      ),
                                                                      Text(
                                                                        _formatToday,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                            : Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        0.0),
                                                                child:
                                                                    Container(
                                                                  child: Column(
                                                                    children: [
                                                                      Text(
                                                                        shortName +
                                                                            ": " +
                                                                            lastMessage,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              MediaQuery.of(context).size.width / 30,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            5,
                                                                      ),
                                                                      Text(
                                                                        _formatToday,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              12,
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
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    );
                                  } else {
                                    return SizedBox(
                                      height: 1,
                                      width: 1,
                                    );
                                  }
                                }
                              },
                            );
                          }));
                    }
                  },
                ),
              ),
            ],
          )),
    );
  }
}
