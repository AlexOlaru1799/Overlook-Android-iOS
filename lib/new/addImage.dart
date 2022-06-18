// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:overlook/components/firebase_api.dart';
import 'package:overlook/constants.dart';
import 'package:overlook/main.dart';
import 'package:overlook/new/main_temp.dart';
import 'package:path/path.dart';
import 'package:overlook/components/storage_service.dart';

final Storage storage = Storage();

class AddImage extends StatefulWidget {
  const AddImage({Key? key}) : super(key: key);

  @override
  State<AddImage> createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  String tempImage = "assets/images/tempPhoto.jpg";
  XFile? fileChosen;
  bool chosenImage = false;
  TextEditingController textarea = TextEditingController();
  String imageDesc = "";

  @override
  Widget build(BuildContext context) {
    File? _photo;
    final ImagePicker _picker = ImagePicker();

    Future uploadFile(String option, String imageName) async {
      if (_photo == null) return;

      print("Waiting to send\n");

      try {
        storage.upldoadFile(
            _photo!.path,
            FirebaseApi.realUserLastData!.getUsername() as String,
            option,
            imageName);
      } catch (e) {
        print('error occured');
      }
    }

    Future PreimgFromGallery(String option) async {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      setState(() {
        if (pickedFile != null) {
          tempImage = pickedFile.path;
          fileChosen = pickedFile;
          print("======> " + tempImage);
          chosenImage = true;
        }
      });
    }

    Future imgFromGallery(String option, XFile pickedFile) async {
      String tempURL = "";

      if (pickedFile != null) {
        _photo = File(pickedFile.path);

        QuerySnapshot querySnap = await FirebaseFirestore.instance
            .collection('RegularUsers')
            .where('username',
                isEqualTo: FirebaseApi.realUserLastData!.getUsername())
            .get();
        QueryDocumentSnapshot doc = querySnap.docs[0];
        DocumentReference docRef = doc.reference;

        int currentImage = doc["imagesNumber"];
        int lastNr = currentImage;
        currentImage = currentImage + 1;

        String imageName = "post" + currentImage.toString();

        await docRef.update({
          "imagesNumber": currentImage,
        });

        await uploadFile(option, imageName);

        Timer(const Duration(milliseconds: 3000), () async {
          if (option == "posts") {
            tempURL = await storage.downloadURLProfile(
                FirebaseApi.realUserLastData!.getUsername() as String,
                option,
                imageName);

            List posts = doc["posts"];
            String docID = docRef.id;
            posts.add(tempURL);
            GeoPoint location = doc["location"];
            docRef.update({"posts": FieldValue.arrayUnion(posts)});

            DateTime now = DateTime.now();

            List userLikes = [];

            FirebaseFirestore.instance
                .collection('RegularUsers')
                .doc(docID)
                .collection('posts')
                .doc(imageName)
                .set({
              "createdAt": now,
              "postLocation": location,
              "imageURL": tempURL,
              "text": imageDesc,
              "userLikes": userLikes,
              "likes": 0
            });

            String postID = docID + lastNr.toString();

            FirebaseFirestore.instance.collection('posts').doc(postID).set({
              "createdAt": now,
              "postLocation": location,
              "imageURL": tempURL,
              "text": imageDesc,
              "owner": FirebaseApi.realUserLastData!.getUsername(),
              "userLikes": userLikes,
              "likes": 0,
              "postType": "addImage"
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
          }
        });
      } else {
        print('No image selected.');
        tempURL = "";
      }
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(35),
        child: AppBar(
          title: Text(
            "Share image",
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
      body: SingleChildScrollView(
        child: Container(
          color: secondaryColor,
          //height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(5),
                child: Container(
                    height: 125,
                    child: chosenImage
                        ? Image.file(File(tempImage))
                        : Image.asset(tempImage)),
              ),
              Container(
                height: MediaQuery.of(context).size.height / 15,
                width: MediaQuery.of(context).size.width / 2,
                color: Colors.black,
                child: ElevatedButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Add an Image",
                            style: GoogleFonts.openSans(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.photo,
                          color: Colors.white,
                        ),
                        Spacer()
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: mainColor,
                    ),
                    onPressed: () => {PreimgFromGallery("posts")}),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                height: MediaQuery.of(context).size.height / 6,
                width: MediaQuery.of(context).size.width / 1.15,
                child: TextField(
                  controller: textarea,
                  keyboardType: TextInputType.multiline,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Enter description",
                    hintStyle: GoogleFonts.openSans(
                      color: mainColor,
                      fontSize: 12,
                    ),
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: mainColor, width: 1),
                        borderRadius: BorderRadius.circular(10)),
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: mainColor, width: 1),
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (value) {
                    imageDesc = value;
                  },
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height / 15,
                width: MediaQuery.of(context).size.width / 1.15,
                child: ElevatedButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Post",
                            style: GoogleFonts.openSans(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Icon(
                          FontAwesomeIcons.arrowAltCircleRight,
                          color: Colors.white,
                          size: 30,
                        ),
                        Spacer()
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: mainColor,
                    ),
                    onPressed: () {
                      imgFromGallery("posts", fileChosen!);
                      setState(() {
                        chosenImage = false;
                        tempImage = "assets/images/tempPhoto.jpg";
                      });

                      textarea.clear();
                    }),
              ),
              Container(
                height: MediaQuery.of(context).size.height / 2.2,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/gifs/locationTracking.gif'),
                      fit: BoxFit.contain),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
