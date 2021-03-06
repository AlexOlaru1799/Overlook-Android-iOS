import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:overlook/constants.dart';
import 'package:flutter/services.dart';
import 'package:overlook/new/login.dart';

import 'package:overlook/new/register.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'dart:ui' as ui;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyCaoeYdYlEXb6KZvEAyo7LkxsW_He95LUQ",
          authDomain: "overlook-64769.firebaseapp.com",
          databaseURL:
              "https://overlook-64769-default-rtdb.europe-west1.firebasedatabase.app",
          projectId: "overlook-64769",
          storageBucket: "overlook-64769.appspot.com",
          messagingSenderId: "371197850",
          appId: "1:371197850:web:156a1bf5df1e5772519c23",
          measurementId: "G-LYJGJJ3PRY"),
    );
  } else {
    await Firebase.initializeApp(
        // options: FirebaseOptions(
        //     apiKey: "AIzaSyCaoeYdYlEXb6KZvEAyo7LkxsW_He95LUQ",
        //     authDomain: "overlook-64769.firebaseapp.com",
        //     databaseURL:
        //         "https://overlook-64769-default-rtdb.europe-west1.firebasedatabase.app",
        //     projectId: "overlook-64769",
        //     storageBucket: "overlook-64769.appspot.com",
        //     messagingSenderId: "371197850",
        //     appId: "1:371197850:web:156a1bf5df1e5772519c23",
        //     measurementId: "G-LYJGJJ3PRY"),
        );
  }

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );
  RenderErrorBox.backgroundColor = Colors.transparent;
  RenderErrorBox.textStyle = ui.TextStyle(color: Colors.transparent);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  //SystemChrome.setEnabledSystemUIOverlays();
  // ignore: use_key_in_widget_constructors

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Auth',
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: LoginPage(),
    );
  }
}
