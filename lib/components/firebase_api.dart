// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypt/crypt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:location/location.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;

import 'package:overlook/components/storage_service.dart';
import 'package:overlook/components/user.dart';
import 'package:overlook/components/Utils.dart' if (kIsWeb) "";
import 'package:overlook/new/main_temp.dart';
import 'package:overlook/new/otherProfile.dart';

import 'package:sqflite/sqflite.dart';
import 'package:xml_parser/xml_parser.dart';

class FirebaseApi {
  static Stream? realUserStream;
  static String? realUserUID;
  static myUser? realUserLastData;

  static Future<int> getEvents() async {
    int eventNumber = 0;

    await FirebaseFirestore.instance
        .collection('events')
        .get()
        .then((value) => {eventNumber = value.docs.length});

    return eventNumber;
  }

  static Future<void> readDatabaseOnce(String UID) async {
    QuerySnapshot querySnap = await FirebaseFirestore.instance
        .collection('RegularUsers')
        .where('UID', isEqualTo: UID)
        .get();
    QueryDocumentSnapshot doc = querySnap.docs[0];

    myUser temp = myUser(doc["username"], doc["email"], doc["location"],
        doc["FollowersNumber"], doc["FollowingNumber"]);

    temp.setProfileURL(doc["profileImage"]);
    temp.setBackgroulURL(doc["backgroundImage"]);
    temp.updateAbout(doc["about"]);

    realUserLastData = temp;
  }

  static Future<void> userBasicLogin(
      String email, String pass, BuildContext context, String authType) async {
    LocationData location = await Utils2.getLocationWithPermissions(context);
    UserCredential? userCredential;
    if (authType == "email") {
      try {
        userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: pass);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
        }
      }
    } else if (authType == "facebook") {
      final LoginResult loginResult = await FacebookAuth.instance.login();

      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.token);

      userCredential = await FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential);
    } else if (authType == "google") {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
    }

    realUserStream = FirebaseFirestore.instance
        .collection('RegularUsers')
        .doc(userCredential!.user!.uid.toString())
        .snapshots();

    realUserUID = userCredential.user!.uid;

    await Future.delayed(const Duration(seconds: 2), () {});

    readDatabaseOnce(realUserUID!);

    // ------------------------

    FirebaseFirestore.instance
        .collection('RegularUsers')
        .doc(userCredential.user!.uid.toString())
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        //print('Document data: ${documentSnapshot.data()}');
      } else {
        print('Document does not exist on the database');
      }
    });

    await Future.delayed(const Duration(seconds: 2), () {});

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserInformation()),
    );
  }

  static Future<void> userBasicRegistration(
      String email, String pass, BuildContext context, String authType) async {
    UserCredential? userCredential;
    if (authType == "email") {
      try {
        userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: pass);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          Utils2.showAlertDialog(context, "Weak password",
              "The password provided is too weak.Try something that has 6+ characters");
          return;
        } else if (e.code == 'email-already-in-use') {
          Utils2.showAlertDialog(context, "Email already in use",
              "The account already exists for that email.");
          return;
        } else if (e.code == 'invalid-email') {
          Utils2.showAlertDialog(context, "Email format is wrong",
              "The email you provided is not in the right format! Check for spaces at the end and try again with this formmat emailname@emailprovider.region");
          return;
        }
        print(e.code);
      }
    } else if (authType == "facebook") {
      final LoginResult loginResult = await FacebookAuth.instance.login();
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.token);

      userCredential = await FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential);

      pass = userCredential.user!.uid.toString();

      if (userCredential.additionalUserInfo!.isNewUser == false) {
        Utils2.showAlertDialog(context, "Email already in use",
            "The account already exists for that email.");
        return;
      }
    } else if (authType == "google") {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      pass = userCredential.user!.uid.toString();

      if (userCredential.additionalUserInfo!.isNewUser == false) {
        Utils2.showAlertDialog(context, "Email already in use",
            "The account already exists for that email.");
        return;
      }
    }

    CollectionReference users =
        FirebaseFirestore.instance.collection('RegularUsers');

    final hashedWithSalt = Crypt.sha256(pass);
    var username = userCredential!.user!.email.toString().split('@')[0];
    DateTime now = DateTime.now();

    LocationData location = await Utils2.getLocationWithPermissions(context);

    List<Map<String, dynamic>> list = <Map<String, dynamic>>[];

    Storage storage = Storage();

    if (kIsWeb) {
      print("SUCCES!");
      const exampleUrl = 'https://picsum.photos/seed/picsum/200/300';
      final File _file = File(exampleUrl);
      final firebase_storage.FirebaseStorage storage =
          firebase_storage.FirebaseStorage.instance;

      final mountainImagesRef =
          storage.refFromURL("gs://overlook-64769.appspot.com");

      mountainImagesRef.putFile(_file);
    } else {
      File img = await storage.getImageFileFromAssets("profilePlaceholder.png");
      storage.upldoadFile(img.path, username, "profile", "");

      File img2 =
          await storage.getImageFileFromAssets("backgroundPlaceholder.jpg");
      storage.upldoadFile(img2.path, username, "background", "");

      await Future.delayed(const Duration(seconds: 3), () {});

      String profileURL =
          await storage.downloadURLProfile(username, "profile", "");
      String backgroundURL =
          await storage.downloadURLProfile(username, "background", "");

      await users
          .doc(userCredential.user!.uid.toString())
          .set({
            'username': username,
            'imagesNumber': 0,
            'password': hashedWithSalt.toString(),
            'salt': hashedWithSalt.salt.toString(),
            'email': userCredential.user!.email.toString(),
            'UID': userCredential.user!.uid.toString(),
            'FollowersNumber': 0,
            'FollowingNumber': 0,
            'creationDate': now,
            'location': GeoPoint(location.latitude!, location.longitude!),
            'followers': list,
            'following': list,
            'posts': list,
            'profileImage': profileURL,
            'backgroundImage': backgroundURL,
            'about': "not specified",
            'disabledLocation': false
          })
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user: $error"));

      await Future.delayed(const Duration(seconds: 1), () {});

      realUserUID = userCredential.user!.uid;

      readDatabaseOnce(realUserUID!);

      // ------------------------

      FirebaseFirestore.instance
          .collection('RegularUsers')
          .doc(userCredential.user!.uid.toString())
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          //print('Document data: ${documentSnapshot.data()}');
        } else {
          print('Document does not exist on the database');
        }
      });

      // ----------------------------

      await Future.delayed(const Duration(seconds: 2), () {});

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserInformation()),
      );
    }
  }

  static Future<void> updateAboutForUser(String aboutNEW) async {
    QuerySnapshot querySnap = await FirebaseFirestore.instance
        .collection('RegularUsers')
        .where('UID', isEqualTo: realUserUID)
        .get();
    QueryDocumentSnapshot doc = querySnap.docs[0];
    DocumentReference docRef = doc.reference;

    await docRef.update({
      "about": aboutNEW,
    });
  }

  static Future<void> seeOtherProfile(String UID, BuildContext context) async {
    QuerySnapshot querySnap = await FirebaseFirestore.instance
        .collection('RegularUsers')
        .where('UID', isEqualTo: UID)
        .get();
    QueryDocumentSnapshot docOther = querySnap.docs[0];
    DocumentReference docRef = docOther.reference;

    QuerySnapshot querySnap2 = await FirebaseFirestore.instance
        .collection('RegularUsers')
        .where('UID', isEqualTo: realUserUID)
        .get();
    QueryDocumentSnapshot docReal = querySnap2.docs[0];
    DocumentReference docRef2 = docReal.reference;

    List following = docReal["following"];

    bool tempBoolForFollowUnfollow;

    await Future.delayed(const Duration(milliseconds: 50), () {});

    if (following.contains(docOther["username"]) == true) {
      tempBoolForFollowUnfollow = false;
    } else {
      tempBoolForFollowUnfollow = true;
    }

    await Future.delayed(const Duration(milliseconds: 50), () {});

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return OtherProfilePage(
              docOther["UID"], tempBoolForFollowUnfollow, docOther["username"]);
        },
      ),
    );
  }

  static Future<bool> checkFollower(String guestUser) async {
    QuerySnapshot querySnap = await FirebaseFirestore.instance
        .collection('RegularUsers')
        .where('username',
            isEqualTo: FirebaseApi.realUserLastData!.getUsername())
        .get();
    QueryDocumentSnapshot doc = querySnap.docs[0];
    DocumentReference docRef = doc.reference;

    List followingList = doc["following"];

    int followingNr = doc["FollowingNumber"];

    followingNr++;

    if (followingList.contains(guestUser) == true) {
      return true;
    } else {
      return false;
    }
  }

  static Future<void> addFollower(String userGuest) async {
    QuerySnapshot querySnap = await FirebaseFirestore.instance
        .collection('RegularUsers')
        .where('username',
            isEqualTo: FirebaseApi.realUserLastData!.getUsername())
        .get();
    QueryDocumentSnapshot doc = querySnap.docs[0];
    DocumentReference docRef = doc.reference;

    List followingList = doc["following"];

    int followingNr = doc["FollowingNumber"];

    followingNr++;

    if (followingList.contains(userGuest) == false) {
      followingList.add(userGuest);
      docRef.update({"following": FieldValue.arrayUnion(followingList)});
      docRef.update({"FollowingNumber": followingNr});
    }

    QuerySnapshot querySnap2 = await FirebaseFirestore.instance
        .collection('RegularUsers')
        .where('username', isEqualTo: userGuest)
        .get();
    QueryDocumentSnapshot doc2 = querySnap2.docs[0];
    DocumentReference docRef2 = doc2.reference;

    List followersList = doc2["followers"];

    int followersNr = doc2["FollowersNumber"];
    followersNr++;

    if (followersList.contains(FirebaseApi.realUserLastData!.getUsername()) ==
        false) {
      followersList.add(FirebaseApi.realUserLastData!.getUsername());
      docRef2.update({"followers": FieldValue.arrayUnion(followersList)});
      docRef2.update({"FollowersNumber": followersNr});
    }
  }

  static Future<void> removeFollower(String guestUser) async {
    QuerySnapshot querySnap = await FirebaseFirestore.instance
        .collection('RegularUsers')
        .where('username',
            isEqualTo: FirebaseApi.realUserLastData!.getUsername())
        .get();
    QueryDocumentSnapshot doc = querySnap.docs[0];
    DocumentReference docRef = doc.reference;

    List followingList = [];
    followingList.add(guestUser);

    int followingNr = doc["FollowingNumber"];

    print("following - " + followingNr.toString() + "\n");

    followingNr--;

    if (followingList.contains(guestUser) == true) {
      followingList.add(guestUser);
      docRef.update({"following": FieldValue.arrayRemove(followingList)});
      docRef.update({"FollowingNumber": followingNr});
      print("following - " + followingNr.toString() + "\n");
    }

    QuerySnapshot querySnap2 = await FirebaseFirestore.instance
        .collection('RegularUsers')
        .where('username', isEqualTo: guestUser)
        .get();
    QueryDocumentSnapshot doc2 = querySnap2.docs[0];
    DocumentReference docRef2 = doc2.reference;

    List followersList = doc2["followers"];
    int followersNr = doc2["FollowersNumber"];

    followersNr--;

    if (followersList.contains(FirebaseApi.realUserLastData!.getUsername()) ==
        true) {
      followersList.add(FirebaseApi.realUserLastData!.getUsername());
      docRef2.update({"followers": FieldValue.arrayRemove(followersList)});
      docRef2.update({"FollowersNumber": followersNr});
    }
  }

  static Future<void> createRoom(String currentUsername) async {
    QuerySnapshot querySnap = await FirebaseFirestore.instance
        .collection('RegularUsers')
        .where('username', isEqualTo: currentUsername)
        .get();
    QueryDocumentSnapshot docOther = querySnap.docs[0];
    DocumentReference docOtherRef = docOther.reference;

    String otherUID = docOther["UID"];

    String roomName = realUserUID!.substring(0, 10) + otherUID.substring(0, 10);

    String roomNameVerification =
        otherUID.substring(0, 10) + realUserUID!.substring(0, 10);

    DocumentSnapshot check1 = await FirebaseFirestore.instance
        .collection("rooms")
        .doc(roomName)
        .get();

    DocumentSnapshot check2 = await FirebaseFirestore.instance
        .collection("rooms")
        .doc(roomNameVerification)
        .get();

    if (check1.exists == false && check2.exists == false) {
      DateTime now = DateTime.now();

      CollectionReference rooms =
          FirebaseFirestore.instance.collection('rooms');

      List list = [];

      list.add(realUserUID);
      list.add(otherUID);

      await rooms
          .doc(roomName)
          .set({
            'createdAT': now,
            'updatedAT': now,
            'UserUIDs': FieldValue.arrayUnion(list),
          })
          .then((value) => print("Room Created"))
          .catchError((error) => print("Failed to add room: $error"));

      FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomName)
          .collection('messages')
          .doc()
          .set(
              {"authorID": realUserUID, "createdAT": now, "text": "TEST MESS"});

      // FirebaseFirestore.instance
      //     .collection('rooms')
      //     .doc(roomName)
      //     .collection('messages')
      //     .doc()
      //     .set({"authorID": realUserUID, "createdAT": now, "text": "Hello"});
    }
  }

  static Future<void> sendMessage(String message, String guestUID) async {
    String roomName = realUserUID!.substring(0, 10) + guestUID.substring(0, 10);

    String roomNameVerification =
        guestUID.substring(0, 10) + realUserUID!.substring(0, 10);

    DocumentSnapshot check1 = await FirebaseFirestore.instance
        .collection("rooms")
        .doc(roomName)
        .get();

    DocumentSnapshot check2 = await FirebaseFirestore.instance
        .collection("rooms")
        .doc(roomNameVerification)
        .get();

    DateTime now = DateTime.now();

    if (check1.exists == true) {
      FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomName)
          .collection('messages')
          .doc()
          .set({
        "authorID": realUserUID,
        "createdAT": now,
        "text": message,
        "emote": 0
      });

      FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomName)
          .update({"lastMessage": now});
    } else if (check2.exists == true) {
      FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomNameVerification)
          .collection('messages')
          .doc()
          .set({
        "authorID": realUserUID,
        "createdAT": now,
        "text": message,
        "emote": 0
      });

      FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomNameVerification)
          .update({"lastMessage": now});
    }
  }

  static void sendEmote(int value, String id_mess, String id_room) {
    FirebaseFirestore.instance
        .collection("rooms")
        .doc(id_room)
        .collection("messages")
        .doc(id_mess)
        .update({"emote": value});
  }

  static Future<List> getFollowingList() async {
    QuerySnapshot querySnap = await FirebaseFirestore.instance
        .collection('RegularUsers')
        .where('UID', isEqualTo: realUserUID)
        .get();
    QueryDocumentSnapshot doc = querySnap.docs[0];
    DocumentReference docRef = doc.reference;

    List temp = await doc["following"];

    return temp;
  }

  static Future<String> getRoomUID(String guestUID) async {
    String roomName = realUserUID!.substring(0, 10) + guestUID.substring(0, 10);

    String roomNameVerification =
        guestUID.substring(0, 10) + realUserUID!.substring(0, 10);

    DocumentSnapshot check1 = await FirebaseFirestore.instance
        .collection("rooms")
        .doc(roomName)
        .get();

    DocumentSnapshot check2 = await FirebaseFirestore.instance
        .collection("rooms")
        .doc(roomNameVerification)
        .get();

    if (check1.exists == true) {
      return roomName;
    } else if (check2.exists == true) {
      return roomNameVerification;
    } else {
      return "null";
    }
  }

  static Future<String> getUserProfileImage(String ownerUsername) async {
    String? url;

    QuerySnapshot querySnap = await FirebaseFirestore.instance
        .collection('RegularUsers')
        .where('username', isEqualTo: ownerUsername)
        .get();
    QueryDocumentSnapshot doc = querySnap.docs[0];
    DocumentReference docRef = doc.reference;

    url = await doc["profileImage"];
    return url!;
  }

  static Future<bool> verifyLike(String postID) async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('posts').doc(postID).get();

    if (documentSnapshot["userLikes"]
        .contains(FirebaseApi.realUserLastData!.getUsername())) {
      return true;
    } else {
      return false;
    }
  }

  static Future<void> likePost(String postID) async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('posts').doc(postID).get();

    int likes = documentSnapshot['likes'];

    List userLikes = documentSnapshot['userLikes'];

    if (userLikes.contains(FirebaseApi.realUserLastData!.getUsername())) {
      likes = likes - 1;
      userLikes.remove(FirebaseApi.realUserLastData!.getUsername());
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postID)
          .update({"likes": likes, "userLikes": userLikes});
    } else {
      likes = likes + 1;
      userLikes.add(FirebaseApi.realUserLastData!.getUsername());
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postID)
          .update({"likes": likes, "userLikes": userLikes});
    }
  }

  static Future<void> addComment(
      String postID, String comment, String username) async {
    List userLikes = [];
    var date = DateTime.now();
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postID)
        .collection("comments")
        .add({
      "authorID": username,
      "comment": comment,
      "createdAT": date,
      "likes": 0,
      "usersLikes": userLikes
    });
  }

  static Future<void> likeComment(String commentID, String postID) async {
    var doc = await FirebaseFirestore.instance
        .collection('posts')
        .doc(postID)
        .collection("comments")
        .doc(commentID)
        .get();

    List likes = doc["usersLikes"];

    if (likes.contains(FirebaseApi.realUserLastData!.getUsername())) {
      likes.remove(FirebaseApi.realUserLastData!.getUsername());
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postID)
          .collection("comments")
          .doc(commentID)
          .update({"likes": FieldValue.increment(-1), "usersLikes": likes});
    } else {
      likes.add(FirebaseApi.realUserLastData!.getUsername());
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postID)
          .collection("comments")
          .doc(commentID)
          .update({"likes": FieldValue.increment(1), "usersLikes": likes});
    }
  }
}
