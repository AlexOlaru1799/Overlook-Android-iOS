// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlook/Screens/Login/components/or_divider.dart';
import 'package:overlook/Screens/Login/components/social_icon.dart';
import 'package:overlook/components/already_have_an_account_acheck.dart';
import 'package:overlook/components/firebase_api.dart';
import 'package:overlook/constants.dart';
import 'package:overlook/main.dart';
import 'package:overlook/new/register.dart';

String? _email;
String? _password;

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  Future<void> login(String email, String password, BuildContext context,
      String authType) async {
    FirebaseApi.userBasicLogin(email, password, context, authType);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
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
                fontSize: 65,
              ),
            ),
            Text(
              "Welcome back!",
              style: GoogleFonts.lobster(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            SizedBox(height: 10),
            SizedBox(height: size.height * 0.005),
            Container(
              width: 350,
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/gifs/connectedWorld.gif'),
                    fit: BoxFit.contain),
                borderRadius: BorderRadius.all(Radius.circular(100)),
              ),
            ),
            SizedBox(height: 5),
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
            SizedBox(height: 10),
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
                    login(_email!, _password!, context, "email");
                  },
                  child: Text(
                    "Login",
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  )),
            ),
            SizedBox(
              height: 40,
            ),
            AlreadyHaveAnAccountCheck(
              login: true,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return RegisterPage();
                    },
                  ),
                );
              },
            ),
            OrDivider("OR Login With"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SocalIcon(
                  iconSrc: "assets/icons/facebook.svg",
                  press: () {
                    login("", "", context, "facebook");
                  },
                ),
                SocalIcon(
                  iconSrc: "assets/icons/google.svg",
                  press: () {
                    login("", "", context, "google");
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
