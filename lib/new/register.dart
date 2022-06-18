// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlook/Screens/Login/components/or_divider.dart';
import 'package:overlook/Screens/Login/components/social_icon.dart';
import 'package:overlook/components/already_have_an_account_acheck.dart';
import 'package:overlook/components/firebase_api.dart'
    if (kIsWeb) "package:overlook/components/firebaseWeb.dart";
import 'package:overlook/components/utils.dart';
import 'package:overlook/new/login.dart';

import '../constants.dart';

String? _email;
String? _password;

class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);

  Future<void> register(String email, String password, BuildContext context,
      String authType) async {
    FirebaseApi.userBasicRegistration(email, password, context, authType);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: secondaryColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(children: [
            Text(
              "Overlook",
              style: GoogleFonts.lobster(
                color: mainColor,
                fontSize: 80,
              ),
            ),
            SizedBox(height: size.height * 0.005),
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: AssetImage('assets/gifs/flyingPlane.gif'),
                    fit: BoxFit.fill),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: size.width / 1.15,
              child: TextField(
                  style: TextStyle(color: mainColor),
                  decoration: InputDecoration(
                    filled: true,
                    hintText: "Enter your email",
                    hintStyle: GoogleFonts.openSans(
                      color: mainColor,
                      fontSize: 12,
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: mainColor, width: 1),
                        borderRadius: BorderRadius.circular(10)),
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: mainColor, width: 1),
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: ((value) {
                    _email = value;
                  })),
            ),
            SizedBox(height: 10),
            Container(
              width: size.width / 1.15,
              child: TextField(
                  obscureText: true,
                  style: TextStyle(color: mainColor),
                  decoration: InputDecoration(
                    filled: true,
                    hintText: "Enter your password",
                    hintStyle: GoogleFonts.openSans(
                      color: mainColor,
                      fontSize: 12,
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: mainColor, width: 1),
                        borderRadius: BorderRadius.circular(10)),
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: mainColor, width: 1),
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: ((value) {
                    _password = value;
                  })),
            ),
            SizedBox(height: 20),
            Container(
              width: 200,
              height: 50,
              child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(mainColor),
                    foregroundColor: MaterialStateProperty.all(secondaryColor),
                    overlayColor: MaterialStateProperty.all(Colors.white),
                    side: MaterialStateProperty.all(
                      const BorderSide(
                        color: secondaryColor,
                        width: 1.5,
                      ),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  onPressed: () {
                    register(_email!, _password!, context, "email");
                  },
                  child: Text(
                    "Register",
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  )),
            ),
            SizedBox(
              height: 20,
            ),
            AlreadyHaveAnAccountCheck(
              login: false,
              press: () {
                Navigator.pop(context);
              },
            ),
            OrDivider("OR Register With"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SocalIcon(
                  iconSrc: "assets/icons/facebook.svg",
                  press: () {
                    register("", "", context, "facebook");
                  },
                ),
                SocalIcon(
                  iconSrc: "assets/icons/google.svg",
                  press: () {
                    register("", "", context, "google");
                  },
                ),
              ],
            )
          ]),
        ),
      ),
    );
  }
}
