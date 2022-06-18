import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypt/crypt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:location/location.dart';
import 'package:overlook/components/user.dart';
import 'package:overlook/components/utilsWeb.dart';

class FirebaseApiWeb {
  static Stream? realUserStream;
  static String? realUserUID;
  static myUser? realUserLastData;

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

    print("SUCCESS!!!!!!");

    // CollectionReference users =
    //     FirebaseFirestore.instance.collection('RegularUsers');

    // final hashedWithSalt = Crypt.sha256(pass);
    // var username = userCredential!.user!.email.toString().split('@')[0];
    // DateTime now = DateTime.now();

    // LocationData location = await Utils2.getLocationWithPermissions(context);

    // List<Map<String, dynamic>> list = <Map<String, dynamic>>[];

    // Storage storage = Storage();

    // File img = await storage.getImageFileFromAssets("profilePlaceholder.png");
    // storage.upldoadFile(img.path, username, "profile", "");

    // File img2 =
    //     await storage.getImageFileFromAssets("backgroundPlaceholder.jpg");
    // storage.upldoadFile(img2.path, username, "background", "");

    // await Future.delayed(const Duration(seconds: 3), () {});

    // String profileURL =
    //     await storage.downloadURLProfile(username, "profile", "");
    // String backgroundURL =
    //     await storage.downloadURLProfile(username, "background", "");

    // await users
    //     .doc(userCredential.user!.uid.toString())
    //     .set({
    //       'username': username,
    //       'imagesNumber': 0,
    //       'password': hashedWithSalt.toString(),
    //       'salt': hashedWithSalt.salt.toString(),
    //       'email': userCredential.user!.email.toString(),
    //       'UID': userCredential.user!.uid.toString(),
    //       'FollowersNumber': 0,
    //       'FollowingNumber': 0,
    //       'creationDate': now,
    //       'location': GeoPoint(location.latitude!, location.longitude!),
    //       'followers': list,
    //       'following': list,
    //       'posts': list,
    //       'profileImage': profileURL,
    //       'backgroundImage': backgroundURL,
    //       'about': "not specified",
    //     })
    //     .then((value) => print("User Added"))
    //     .catchError((error) => print("Failed to add user: $error"));

    // await Future.delayed(const Duration(seconds: 1), () {});

    // realUserUID = userCredential.user!.uid;

    // readDatabaseOnce(realUserUID!);

    // // ------------------------

    // FirebaseFirestore.instance
    //     .collection('RegularUsers')
    //     .doc(userCredential.user!.uid.toString())
    //     .get()
    //     .then((DocumentSnapshot documentSnapshot) {
    //   if (documentSnapshot.exists) {
    //     //print('Document data: ${documentSnapshot.data()}');
    //   } else {
    //     print('Document does not exist on the database');
    //   }
    // });

    // // ----------------------------

    // await Future.delayed(const Duration(seconds: 2), () {});

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => UserInformation()),
    // );
  }
}
