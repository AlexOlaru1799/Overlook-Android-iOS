import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart'
    if (kIsWeb) "";
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'dart:ui' as ui;

import 'package:overlook/components/firebase_api.dart';
import 'package:overlook/components/storage_service.dart';
import 'package:overlook/constants.dart';

final Storage storage = Storage();

class Post {
  String? description;
  DateTime? time;
  String? URL;
  GeoPoint? location;

  Post(String desc, String url, DateTime _time, GeoPoint loc) {
    this.description = desc;
    this.location = loc;
    this.URL = url;
    this.time = _time;
  }

  String? getURL() {
    return this.URL;
  }

  String? getDescription() {
    return this.description;
  }

  GeoPoint? getLocation() {
    return this.location;
  }

  DateTime? getTime() {
    return this.time;
  }
}

class Utils2 {
  static void showAlertDialog(
      BuildContext context, String title, String message) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static Future<LocationData> getLocationWithPermissions(
      BuildContext context) async {
    Location location = new Location();
    PermissionStatus? _permissionGranted;

    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        // set up the AlertDialog
        // set up the button
        Widget okButton = TextButton(
          child: Text("OK"),
          onPressed: () {},
        );
        AlertDialog alert = AlertDialog(
          title: Text("Location Permissions"),
          content: Text(
              "In order to use this application you need to allow permissions for location."),
          actions: [
            okButton,
          ],
        );

        // show the dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          },
        );
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        // set up the AlertDialog
        // set up the button
        Widget okButton = TextButton(
          child: Text("OK"),
          onPressed: () {},
        );
        AlertDialog alert = AlertDialog(
          title: Text("Location Permissions"),
          content: Text(
              "In order to use this application you need to allow permissions for location."),
          actions: [
            okButton,
          ],
        );

        // show the dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          },
        );
      }
    }

    return location.getLocation();
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
      targetHeight: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  static Future<ui.Image> getImageFromPath(String imagePath) async {
    File imageFile = File(imagePath);

    Uint8List imageBytes = imageFile.readAsBytesSync();

    final Completer<ui.Image> completer = new Completer();

    ui.decodeImageFromList(imageBytes, (ui.Image img) {
      return completer.complete(img);
    });

    return completer.future;
  }

  static Future<BitmapDescriptor> convertImageFileToCustomBitmapDescriptor(
      String url, String title,
      {int size = 150,
      bool addBorder = true,
      Color borderColor = mainColor,
      double borderSize = 10,
      Color titleColor = Colors.white,
      Color titleBackgroundColor = mainColor}) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color;
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    final double radius = size / 2;

    File imageFile = await DefaultCacheManager().getSingleFile(url);

    //make canvas clip path to prevent image drawing over the circle
    final Path clipPath = Path();
    clipPath.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
        Radius.circular(100)));
    clipPath.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size * 8 / 10, size.toDouble(), size * 3 / 10),
        Radius.circular(100)));
    canvas.clipPath(clipPath);

    //paintImage
    final Uint8List imageUint8List = await imageFile.readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(imageUint8List);
    final ui.FrameInfo imageFI = await codec.getNextFrame();
    paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
        image: imageFI.image);

    if (addBorder) {
      //draw Border
      paint..color = borderColor;
      paint..style = PaintingStyle.stroke;
      paint..strokeWidth = borderSize;
      canvas.drawCircle(Offset(radius, radius), radius, paint);
    }

    if (title != null) {
      if (title.length > 15) {
        title = title.substring(0, 15);
      }
      //draw Title background
      paint..color = titleBackgroundColor;
      paint..style = PaintingStyle.fill;
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(
                  0, size * 8 / 10, (size + 50).toDouble(), size * 3 / 10),
              Radius.circular(20)),
          paint);

      //draw Title
      textPainter.text = TextSpan(
          text: title,
          style: TextStyle(
            fontSize: radius / 3.5,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ));
      textPainter.layout();
      textPainter.paint(
          canvas,
          Offset(radius - textPainter.width / 2,
              size * 9.5 / 10 - textPainter.height / 2));
    }

    //convert canvas as PNG bytes
    final _image = await pictureRecorder
        .endRecording()
        .toImage(size, (size * 1.1).toInt());
    final data = await _image.toByteData(format: ui.ImageByteFormat.png);

    //convert PNG bytes as BitmapDescriptor
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  static Future<BitmapDescriptor> getMarkerIcon2(
      String imagePath, Size size) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Radius radius = Radius.circular(size.width / 2);

    final Paint tagPaint = Paint()..color = Colors.blue;
    final double tagWidth = 40.0;

    final Paint shadowPaint = Paint()..color = Colors.blue.withAlpha(100);
    final double shadowWidth = 15.0;

    final Paint borderPaint = Paint()..color = Colors.white;
    final double borderWidth = 3.0;

    final double imageOffset = shadowWidth + borderWidth;

    // Add shadow circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0.0, 0.0, size.width, size.height),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        shadowPaint);

    // Add border circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(shadowWidth, shadowWidth,
              size.width - (shadowWidth * 2), size.height - (shadowWidth * 2)),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        borderPaint);

    // Add tag circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(size.width - tagWidth, 0.0, tagWidth, tagWidth),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        tagPaint);

    // Add tag text
    TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: '1',
      style: TextStyle(fontSize: 20.0, color: Colors.white),
    );

    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(size.width - tagWidth / 2 - textPainter.width / 2,
            tagWidth / 2 - textPainter.height / 2));

    // Oval for the image
    Rect oval = Rect.fromLTWH(imageOffset, imageOffset,
        size.width - (imageOffset * 2), size.height - (imageOffset * 2));

    // Add path for oval image
    canvas.clipPath(Path()..addOval(oval));

    // Add image
    ui.Image image = await getImageFromPath(
        imagePath); // Alternatively use your own method to get the image
    paintImage(canvas: canvas, image: image, rect: oval, fit: BoxFit.fitWidth);

    // Convert canvas to image
    final ui.Image markerAsImage = await pictureRecorder
        .endRecording()
        .toImage(size.width.toInt(), size.height.toInt());

    // Convert image to bytes
    final ByteData? byteData =
        await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List uint8List = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List);
  }

  static Future<Uint8List> getMarkerIcon(String url, int markerSize) async {
    var markerImageFile;
    if (kIsWeb == false) {
      markerImageFile = await DefaultCacheManager().getSingleFile(url);
    }

    var markerImageByte = await markerImageFile.readAsBytes();
    var markerImageCodec = await instantiateImageCodec(
      markerImageByte,
      targetWidth: markerSize,
      targetHeight: markerSize,
    );
    var frameInfo = await markerImageCodec.getNextFrame();
    var byteData = await frameInfo.image.toByteData(
      format: ImageByteFormat.png,
    );
    var resizedMarkerImageBytes = byteData!.buffer.asUint8List();
    return resizedMarkerImageBytes;
  }

  // static Future<void> loadImageFirstTime() async {
  //   Storage storage = new Storage();
  //   String profileIMG = await storage.downloadURLProfile(
  //       user!.getUsername() as String, "profile");
  //   String backgroundIMG = await storage.downloadURLProfile(
  //       user!.getUsername() as String, "background");

  //   print("===>" + profileIMG);

  //   QuerySnapshot querySnap = await FirebaseFirestore.instance
  //       .collection('RegularUsers')
  //       .where('username', isEqualTo: user!.getUsername() as String)
  //       .get();
  //   QueryDocumentSnapshot doc = querySnap.docs[0];
  //   DocumentReference docRef = doc.reference;

  //   if (doc["profileImage"] == "null" && doc["backgroundImage"] == "null") {
  //     docRef.update({
  //       "profileImage": profileIMG,
  //       "backgroundImage": backgroundIMG,
  //     });
  //   } else {
  //     profileIMG = doc["profileImage"];
  //     backgroundIMG = doc["backgroundImage"];
  //   }

  //   setState(() {
  //     profileURL = profileIMG;
  //     backgroundURL = backgroundIMG;
  //   });
  // }

  static List<Post> orderList(List<Post> list) {
    list.sort((a, b) => a.time!.compareTo(b.time!));

    return list;
  }

  static Future imgFromGallery(String option) async {
    File? _photo;
    final ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    String tempURL;

    if (pickedFile != null) {
      _photo = File(pickedFile.path);

      if (_photo == null) return;

      print("Waiting to send\n");

      try {
        storage.upldoadFile(_photo.path,
            FirebaseApi.realUserLastData!.getUsername()!, option, "");
      } catch (e) {
        print('error occured');
      }

      await Future.delayed(const Duration(seconds: 2), () {});

      if (option == "profile") {
        tempURL = await storage.downloadURLProfile(
            FirebaseApi.realUserLastData!.getUsername()!, option, "");

        await Future.delayed(const Duration(seconds: 2), () {});

        QuerySnapshot querySnap = await FirebaseFirestore.instance
            .collection('RegularUsers')
            .where('UID', isEqualTo: FirebaseApi.realUserUID)
            .get();
        QueryDocumentSnapshot doc = querySnap.docs[0];
        DocumentReference docRef = doc.reference;

        docRef.update({"profileImage": tempURL});

        QuerySnapshot querySnap2 = await FirebaseFirestore.instance
            .collection('RegularUsers')
            .where('username',
                isEqualTo: FirebaseApi.realUserLastData!.getUsername())
            .get();
        QueryDocumentSnapshot doc2 = querySnap.docs[0];
        DocumentReference docRef2 = doc.reference;

        String docID = docRef2.id;

        int currentImage = doc["imagesNumber"];
        int lastNr = currentImage;

        DateTime now = DateTime.now();

        GeoPoint location = doc["location"];

        List userLikes = [];

        String postID = docID + "_profile";

        String imageDesc = "";

        FirebaseFirestore.instance.collection('posts').doc(postID).set({
          "createdAt": now,
          "postLocation": location,
          "imageURL": tempURL,
          "text": imageDesc,
          "owner": FirebaseApi.realUserLastData!.getUsername(),
          "userLikes": userLikes,
          "likes": 0,
          "postType": "profileChange"
        });

        FirebaseFirestore.instance
            .collection('posts')
            .doc(postID)
            .collection('comments')
            .doc()
            .set({
          "authorID": "",
          "createdAT": now,
          "comment": "TEST MESS",
          "likes": 0
        });
      } else {
        tempURL = await storage.downloadURLProfile(
            FirebaseApi.realUserLastData!.getUsername()!, option, "");

        await Future.delayed(const Duration(seconds: 2), () {});

        QuerySnapshot querySnap = await FirebaseFirestore.instance
            .collection('RegularUsers')
            .where('username',
                isEqualTo: FirebaseApi.realUserLastData!.getUsername()!)
            .get();
        QueryDocumentSnapshot doc = querySnap.docs[0];
        DocumentReference docRef = doc.reference;

        docRef.update({"backgroundImage": tempURL});
      }
    } else {
      print('No image selected.');
      tempURL = "";
    }
  }
}
