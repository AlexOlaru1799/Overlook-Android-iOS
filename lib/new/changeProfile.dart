// ignore_for_file: unnecessary_new, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:overlook/Screens/Profile/numbers_widget.dart';
import 'package:overlook/components/firebase_api.dart';
import 'package:overlook/components/storage_service.dart';
import 'package:overlook/components/utils.dart';
import 'package:overlook/constants.dart';

String? aboutNEW;

class ChangeProfile extends StatelessWidget {
  const ChangeProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              onPressed: () => Navigator.pop(context)),
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

              return SingleChildScrollView(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    new Positioned(
                      top: 0,
                      right: 0,
                      left: 0,
                      child: Container(
                        height: MediaQuery.of(context).size.width / 2.2,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image:
                                NetworkImage(userDocument!["backgroundImage"]),
                          ),
                        ),
                      ),
                    ),

                    // ignore: unnecessary_new

                    new Positioned(
                      top: 50,
                      left: MediaQuery.of(context).size.width / 3.8,
                      child: Container(
                        //padding: EdgeInsets.all(90.0),
                        width: MediaQuery.of(context).size.width / 2.2,
                        height: MediaQuery.of(context).size.width / 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: mainColor,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(userDocument["profileImage"]),
                          ),
                        ),
                      ),
                    ),
                    new Positioned(
                      top: MediaQuery.of(context).size.height / 7,
                      left: MediaQuery.of(context).size.width / 1.17,
                      child: CircleAvatar(
                        backgroundColor: mainColor,
                        child: IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Utils2.imgFromGallery("background");
                            }),
                      ),
                    ),
                    new Positioned(
                      top: 150,
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
                              Utils2.imgFromGallery("profile");
                            },
                          ),
                        ),
                      ),
                    ),
                    new Positioned(
                        top: 225,
                        child: NumbersWidget(userDocument["FollowersNumber"],
                            userDocument["FollowingNumber"])),
                    Container(
                      height: 350,
                      margin: EdgeInsets.fromLTRB(10, 300, 0, 0),
                      alignment: Alignment.bottomLeft,
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
                                hintStyle: TextStyle(color: Colors.white)),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                            height: 5 * 24.0,
                            child: TextField(
                              style: TextStyle(
                                color: Colors.white,
                              ),
                              maxLines: 5,
                              decoration: InputDecoration(
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  border: InputBorder.none,
                                  label: Text(
                                    "About",
                                    style: TextStyle(
                                      color: mainColor,
                                      fontSize: 22,
                                    ),
                                  ),
                                  hintText: userDocument["about"],
                                  hintStyle: TextStyle(color: Colors.white)),
                              onChanged: (value) {
                                aboutNEW = value;
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: mainColor,
          onPressed: () {
            FirebaseApi.updateAboutForUser(aboutNEW!);
            Navigator.pop(context);
          },
          icon: const Icon(Icons.edit),
          label: const Text('Save Changes'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
