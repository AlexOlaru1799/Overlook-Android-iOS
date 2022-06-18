// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart' if (kIsWeb) "";
import 'package:location/location.dart';

import 'package:overlook/components/firebase_api.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:overlook/components/navbar.dart';

import 'package:overlook/components/utils.dart' if (kIsWeb) "";
import 'package:overlook/constants.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

import 'package:overlook/new/profile.dart';

var eventTypes = [
  "Cultural",
  "Social Gathering",
  "Party",
  "Opening",
  "Sports",
];

bool cameraFollow = true;

final pages = [
  Container(),
  Container(),
  Container(),
];

int pointerNumber = 1;
bool loaded = false;

Size size = WidgetsBinding.instance!.window.physicalSize;
int postIndex = 0;

List followings = [];

bool changed = false;

bool localDisabledLocation = true;
Timer? timer;

GeoPoint? lastLoc;

bool loadCameraOnce = true;

bool showOthers = false;

bool showEvents = true;

BitmapDescriptor? iconImage;

class UserInformation extends StatefulWidget {
  @override
  _UserInformationState createState() => _UserInformationState();

  static final style = TextStyle(
    fontSize: 10,
    fontFamily: "Billy",
    fontWeight: FontWeight.w600,
  );
}

List<Marker> _markers = <Marker>[];

class _UserInformationState extends State<UserInformation> {
  static GoogleMapController? _googleMapController;
  Set<Marker> markers = Set();
  String dropValue = "Cultural";
  @override
  void initState() {
    initFunction();

    liquidController = LiquidController();

    super.initState();
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) {
      checkForUpdatedPosition();
      updateOthersLocations();
    });
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<void> updateOthersLocations() async {
    if (showOthers == true) {
      FirebaseFirestore.instance
          .collection('RegularUsers')
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) async {
          final oldMarkerIndex = markers.firstWhere(
              (element) => element.markerId.value == doc["username"],
              orElse: () => Marker(markerId: MarkerId("null")));

          //print("==>" + oldMarkerIndex.markerId.toString());

          var temp2 = await Utils2.convertImageFileToCustomBitmapDescriptor(
              doc["profileImage"], doc["username"]);

          if (doc["disabledLocation"] == true) {
            markers.remove(markers.firstWhere(
                (element) => element.markerId.value == doc["username"]));
          } else {
            if (oldMarkerIndex.markerId.toString() == "MarkerId(null)") {
              //print("=HERE!");
              Utils2.getMarkerIcon(doc["profileImage"], 100).then((value) {
                Marker tempMarker = Marker(
                    markerId: MarkerId(doc["username"]),
                    position: LatLng(
                        doc["location"].latitude, doc["location"].longitude),
                    icon: temp2,
                    infoWindow: InfoWindow(title: doc["username"]),
                    onTap: () {
                      FirebaseApi.seeOtherProfile(doc["UID"], context);
                    });

                if (mounted) {
                  setState(() {
                    markers.add(tempMarker);
                  });
                }
              });
            } else {
              if (calculateDistance(
                      oldMarkerIndex.position.latitude,
                      oldMarkerIndex.position.longitude,
                      doc["location"].latitude,
                      doc["location"].longitude) >
                  0.0005) {
                markers.remove(markers.firstWhere(
                    (element) => element.markerId.value == doc["username"]));
                Utils2.getMarkerIcon(doc["profileImage"], 100).then((value) {
                  Marker tempMarker = Marker(
                      markerId: MarkerId(doc["username"]),
                      position: LatLng(
                          doc["location"].latitude, doc["location"].longitude),
                      icon: temp2,
                      infoWindow: InfoWindow(title: doc["username"]),
                      onTap: () {
                        FirebaseApi.seeOtherProfile(doc["UID"], context);
                      });

                  if (mounted) {
                    setState(() {
                      markers.add(tempMarker);
                    });
                  }
                });
              }
            }
          }
        });
      });
    }
  }

  Future<void> checkForUpdatedPosition() async {
    LocationData location = await Utils2.getLocationWithPermissions(context);
    GeoPoint tempLoc = GeoPoint(location.latitude!, location.longitude!);
    QuerySnapshot querySnap = await FirebaseFirestore.instance
        .collection('RegularUsers')
        .where('username',
            isEqualTo: FirebaseApi.realUserLastData!.getUsername())
        .get();
    QueryDocumentSnapshot doc = querySnap.docs[0];
    DocumentReference docRef = doc.reference;
    GeoPoint tempLatLong = doc["location"];

    if (calculateDistance(location.latitude!, location.longitude!,
            tempLatLong.latitude, tempLatLong.longitude) >
        0.005) {
      // print("=====" +
      //     calculateDistance(location.latitude!, location.longitude!,
      //             tempLatLong.latitude, tempLatLong.longitude)
      //         .toString());
      await docRef.update({
        "location": tempLoc,
      });

      if (cameraFollow == true) {
        _googleMapController?.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(tempLatLong.latitude, tempLatLong.longitude),
            zoom: 18,
          ),
        ));
      }
    }
    setState(() {
      // change state according to result of request
    });
  }

  int page = 0;
  LiquidController? liquidController;

  void showEvents(BuildContext context) async {
    //showOthers = true;
    FirebaseFirestore.instance
        .collection('events')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) async {
        GeoPoint temp = doc["location"];

        String eventType = doc["eventType"];
        String assetPath = "";

        if (eventType == "Sports") {
          assetPath = "assets/images/sportIcon.jpg";
        } else if (eventType == "Cultural") {
          assetPath = "assets/images/culturalIcon.jpg";
        } else if (eventType == "Opening") {
          assetPath = "assets/images/openingIcon.jpg";
        } else if (eventType == "Social") {
          assetPath = "assets/images/socialIcon.jpg";
        } else {
          assetPath = "assets/images/partyIcon.jpg";
        }

        final Uint8List markerIcon =
            await Utils2.getBytesFromAsset(assetPath, 100);

        String docID = doc.id;
        String markerID = "event_" + docID;
        print("Marker added : " + markerID);

        var tempMarkerEvents = Marker(
            markerId: MarkerId(markerID),
            position: LatLng(temp.latitude, temp.longitude),
            icon: BitmapDescriptor.fromBytes(markerIcon),
            infoWindow: InfoWindow(
                title: doc["eventType"] + " Event by " + doc["creator"]),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) =>
                    _buildPopupDialogEvent(context, docID),
              );
            });

        if (mounted) {
          setState(() {
            markers.add(tempMarkerEvents);
          });
        }
      });
    });
  }

  void hideOthers() async {
    FirebaseFirestore.instance
        .collection('RegularUsers')
        .where("username",
            isNotEqualTo: FirebaseApi.realUserLastData!.getUsername())
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) async {
        //print("==>" + oldMarkerIndex.markerId.toString());

        String markerID = doc["username"];
        print("Marker deleted : " + markerID);

        markers.remove(markers
            .firstWhere((element) => element.markerId.value == markerID));
      });
    });
  }

  void hideEvents() async {
    FirebaseFirestore.instance
        .collection('events')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) async {
        //print("==>" + oldMarkerIndex.markerId.toString());

        String docID = doc.id;
        String markerID = "event_" + docID;
        print("Marker deleted : " + markerID);

        markers.remove(markers.firstWhere(
            (element) => element.markerId.value == "event_" + doc.id));
      });
    });
  }

  void initFunction() async {
    var tempMarker;

    if (kIsWeb == false) {
      FirebaseFirestore.instance
          .collection('RegularUsers')
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) async {
          GeoPoint temp = doc["location"];

          var temp2 = await Utils2.convertImageFileToCustomBitmapDescriptor(
              doc["profileImage"], doc["username"]);

          Utils2.getMarkerIcon(doc["profileImage"], 100).then((value) {
            tempMarker = Marker(
                markerId: MarkerId(doc["username"]),
                position: LatLng(temp.latitude, temp.longitude),
                icon: temp2,
                infoWindow: InfoWindow(title: doc["username"]),
                onTap: () {
                  FirebaseApi.seeOtherProfile(doc["UID"], context);
                });

            if (mounted) {
              setState(() {
                if (doc["username"] ==
                    FirebaseApi.realUserLastData!.getUsername()) {
                  iconImage = temp2;
                  GeoPoint tempLatLong = doc["location"];
                  if (cameraFollow == true) {
                    _googleMapController
                        ?.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target:
                            LatLng(tempLatLong.latitude, tempLatLong.longitude),
                        zoom: 18,
                      ),
                    ));
                  }
                }
              });
            }
          });
        });
      });
    }
  }

  final pages = [
    Container(
      color: secondaryColor,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: size.width,
            height: size.height / 12,
            child: Image(
                image: AssetImage('assets/gifs/EarthMoon.gif'),
                fit: BoxFit.contain),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "See what other users nearby are up to!",
            style: TextStyle(fontSize: 12, color: mainColor),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  CupertinoIcons.plus_app_fill,
                  color: mainColor,
                  size: 30,
                  semanticLabel: 'Text to announce in accessibility modes',
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    Container(
      color: mainColor,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: size.width,
            height: size.height / 12,
            child: Image(
                image: AssetImage('assets/gifs/CityDriver.gif'),
                fit: BoxFit.contain),
          ),
          Text(
            "Find out about the newest events around you!",
            style: TextStyle(fontSize: 12, color: secondaryColor),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  CupertinoIcons.calendar,
                  color: secondaryColor,
                  size: 30,
                  semanticLabel: 'Text to announce in accessibility modes',
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ];

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - (page - index).abs(),
      ),
    );
    double zoom = 1.0 + (2.0 - 1.0) * selectedness;
    return Container(
      width: 25.0,
      child: Center(
        child: Material(
          color: Colors.white,
          type: MaterialType.circle,
          child: Container(
            width: 8.0 * zoom,
            height: 8.0 * zoom,
          ),
        ),
      ),
    );
  }

  // seeOtherPeople

  Widget _buildPopupDialog(BuildContext context, bool disabled) {
    String message = "";
    if (disabled != false) {
      message = "Your location is now visible!";
    } else {
      message = "Your location is now disabled!";
    }
    return AlertDialog(
      title: const Text('Popup example'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(message),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
              primary: mainColor,
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              textStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildPopupDialogAddEvent(
      BuildContext context, GeoPoint loc, String username) {
    String description = "";
    String eventType = "";

    String chosenDate = "Event Date";
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return SingleChildScrollView(
        child: AlertDialog(
          title: const Text('Add Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Enter the information about your event",
                style: GoogleFonts.openSans(
                  fontSize: 15,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  filled: true,
                  hintText: "event description",
                  hintStyle: GoogleFonts.openSans(
                    color: mainColor,
                    fontSize: 15,
                  ),
                ),
                onChanged: (value) {
                  description = value;
                },
              ),
              DropdownButton<String>(
                value: dropValue,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                style: const TextStyle(color: secondaryColor),
                underline: Container(
                  height: 2,
                  color: mainColor,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    dropValue = newValue!;
                    eventType = newValue;
                  });
                },
                items: <String>[
                  'Cultural',
                  'Sports',
                  'Social',
                  'Party',
                  'Opening'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              DateTimePicker(
                initialValue: '',
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                dateLabelText: 'Date',
                onChanged: (val) {
                  print(val);
                  chosenDate = val.toString();
                  print("---" + chosenDate);
                },
                validator: (val) {
                  print(val);

                  return null;
                },
              ),
            ],
          ),
          actions: <Widget>[
            Row(
              children: [
                Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    CollectionReference users =
                        FirebaseFirestore.instance.collection('events');
                    List<Map<String, dynamic>> list = <Map<String, dynamic>>[];
                    await users
                        .doc()
                        .set({
                          'creator': username,
                          'coming': list,
                          'date': chosenDate,
                          'description': description,
                          'eventType': eventType,
                          'location': loc
                        })
                        .then((value) => print("User Added"))
                        .catchError(
                            (error) => print("Failed to add user: $error"));
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                      primary: mainColor,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      textStyle: GoogleFonts.openSans(
                        color: mainColor,
                        fontSize: 15,
                      )),
                  child: const Text('Add Event'),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: mainColor,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    textStyle: GoogleFonts.openSans(
                      color: mainColor,
                      fontSize: 15,
                    ),
                  ),
                  child: const Text('Close'),
                ),
                Spacer(),
              ],
            )
          ],
        ),
      );
    });
  }

  Widget _buildPopupDialog2(BuildContext context, bool disabled) {
    String message = "";
    if (disabled == false) {
      message = "Camera lock is now disabled!";
    } else {
      message = "Camera lock is now enabled!";
    }
    return AlertDialog(
      title: const Text('Popup example'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(message),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
              primary: mainColor,
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              textStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildPopupDialogEvent(BuildContext context, String id) {
    int width = (MediaQuery.of(context).size.width / 20).round();
    return StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection('events').doc(id).snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          var doc = snapshot.data;
          List coming = doc!["coming"];
          bool emptyComing = false;

          bool alreadyParticipating = true;

          if (coming.isEmpty == true) {
            emptyComing = true;
          }

          if (coming.contains(FirebaseApi.realUserLastData!.getUsername())) {
            alreadyParticipating = false;
          }

          for (int i = 0; i < coming.length; i++) {
            print("coming : " + i.toString() + " - " + coming[i]);
          }
          return AlertDialog(
            titleTextStyle: GoogleFonts.lobster(
              color: mainColor,
              fontSize: 20,
            ),
            title: Text(
              doc["eventType"] + " Event by " + doc["creator"],
              style: GoogleFonts.openSans(
                color: mainColor,
                fontSize: 15,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      doc["date"],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      doc["description"],
                      style: GoogleFonts.openSans(
                        color: secondaryColor,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: emptyComing
                          ? Text("Be the first one to participate!")
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Participating:",
                                  style: GoogleFonts.openSans(
                                    color: secondaryColor,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  height: 100,
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: coming.length,
                                      itemBuilder: (context, index) {
                                        return Center(
                                          child: Text(
                                            coming[index],
                                            style: GoogleFonts.openSans(
                                              color: mainColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                              ],
                            ),
                    )
                  ],
                )
              ],
            ),
            actions: <Widget>[
              Row(
                children: [
                  alreadyParticipating
                      ? ElevatedButton(
                          onPressed: () async {
                            DocumentSnapshot doc2 = await FirebaseFirestore
                                .instance
                                .collection('events')
                                .doc(id)
                                .get();

                            DocumentReference docRef2 = doc2.reference;
                            List newList = doc2["coming"];

                            if (newList.contains(FirebaseApi.realUserLastData!
                                    .getUsername()) ==
                                false) {
                              newList.add(
                                  FirebaseApi.realUserLastData!.getUsername());
                              docRef2.update(
                                  {"coming": FieldValue.arrayUnion(newList)});
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              primary: mainColor,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              textStyle: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          child: const Text('Participate'),
                        )
                      : ElevatedButton(
                          onPressed: () async {
                            DocumentSnapshot doc2 = await FirebaseFirestore
                                .instance
                                .collection('events')
                                .doc(id)
                                .get();

                            DocumentReference docRef2 = doc2.reference;
                            List newList = [];
                            newList.add(
                                FirebaseApi.realUserLastData!.getUsername());

                            if (newList.contains(FirebaseApi.realUserLastData!
                                    .getUsername()) ==
                                true) {
                              newList.add(
                                  FirebaseApi.realUserLastData!.getUsername());
                              docRef2.update(
                                  {"coming": FieldValue.arrayRemove(newList)});
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              primary: mainColor,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              textStyle: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          child: const Text("Can't make it.."),
                        ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                        primary: mainColor,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        textStyle: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    child: const Text('Close'),
                  ),
                ],
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // to hide system navigation bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    var tempMarker;

    if (kIsWeb) {
      return Container();
    } else {
      Completer<GoogleMapController> _controller = Completer();
      return Scaffold(
          resizeToAvoidBottomInset: false,
          floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
          drawer: NavBar(),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(45),
            child: AppBar(
              elevation: 0.0,
              backgroundColor: secondaryColor,
            ),
          ),
          body: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 1.8,
                // child:
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("RegularUsers")
                      .where("username",
                          isEqualTo:
                              FirebaseApi.realUserLastData!.getUsername())
                      .snapshots(),
                  builder: (context, AsyncSnapshot<dynamic> snapshot) {
                    print(snapshot);
                    if (snapshot.hasData) {
                      //Extract the location from document
                      DocumentSnapshot doc = snapshot.data!.docs[0];
                      GeoPoint location =
                          snapshot.data!.docs.first.get("location");

                      lastLoc = location;

                      // Check if location is valid
                      if (location == null) {
                        return Text("There was no location data");
                      }

                      // Remove any existing markers
                      //markers.clear();

                      final latLng =
                          LatLng(location.latitude, location.longitude);

                      // Add new marker with markerId.
                      markers.add(Marker(
                          markerId: MarkerId(doc["username"]),
                          position: latLng,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfilePage()),
                            );
                          },
                          icon: iconImage!));

                      // If google map is already created then update camera position with animation

                      return GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(
                            target:
                                LatLng(location.latitude, location.longitude)),
                        // Markers to be pointed
                        markers: markers,
                        onMapCreated: (controller) {
                          // Assign the controller value to use it later
                          _googleMapController = controller;
                          if (loadCameraOnce == true) {
                            _googleMapController
                                ?.animateCamera(CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target:
                                    LatLng(latLng.latitude, latLng.longitude),
                                zoom: 18,
                              ),
                            ));
                            loadCameraOnce = false;
                          }
                        },
                      );
                    }
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
              Expanded(
                child: LiquidSwipe(
                  pages: pages,
                  slideIconWidget: Icon(Icons.arrow_back_ios),
                  onPageChangeCallback: pageChangeCallback,
                  waveType: WaveType.liquidReveal,
                  liquidController: liquidController,
                  enableSideReveal: true,
                  ignoreUserGestureWhileAnimating: true,
                ),
              ),
            ],
          ),
          floatingActionButton: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: FloatingActionButton(
                  onPressed: (() {}),
                  child: SpeedDial(
                    spaceBetweenChildren: 0,
                    direction: SpeedDialDirection.down,
                    icon: CupertinoIcons.plus_app_fill,
                    spacing: 0,
                    backgroundColor: mainColor,
                    overlayOpacity: 0,
                    children: [
                      SpeedDialChild(
                          child: Center(
                              child: Icon(
                            CupertinoIcons.group_solid,
                          )),
                          label: "People Nearby",
                          labelStyle: TextStyle(fontSize: 8),
                          backgroundColor: mainColor,
                          onTap: () async {
                            showOthers = true;
                            FirebaseFirestore.instance
                                .collection('RegularUsers')
                                .get()
                                .then((QuerySnapshot querySnapshot) {
                              querySnapshot.docs.forEach((doc) async {
                                GeoPoint temp = doc["location"];

                                BitmapDescriptor myBitmap = await Utils2
                                    .convertImageFileToCustomBitmapDescriptor(
                                        doc["profileImage"], doc["username"]);

                                Utils2.getMarkerIcon(doc["profileImage"], 100)
                                    .then((value) {
                                  tempMarker = Marker(
                                      markerId: MarkerId(doc["username"]),
                                      position:
                                          LatLng(temp.latitude, temp.longitude),
                                      icon: myBitmap,
                                      infoWindow:
                                          InfoWindow(title: doc["username"]),
                                      onTap: () {
                                        FirebaseApi.seeOtherProfile(
                                            doc["UID"], context);
                                      });

                                  if (mounted) {
                                    setState(() {
                                      if (doc["disabledLocation"] == false) {
                                        markers.add(tempMarker);
                                      }
                                    });
                                  }
                                });
                              });
                            });
                          }),
                      SpeedDialChild(
                          child: Center(
                              child: Icon(
                            CupertinoIcons.xmark_circle_fill,
                          )),
                          label: "Hide People Nearby",
                          labelStyle: TextStyle(fontSize: 8),
                          backgroundColor: mainColor,
                          onTap: () async {
                            showOthers = false;
                            hideOthers();
                          }),
                      SpeedDialChild(
                          child: Center(
                              child: Icon(
                            CupertinoIcons.location_slash_fill,
                          )),
                          label: "Hide Your Location",
                          labelStyle: TextStyle(fontSize: 8),
                          backgroundColor: mainColor,
                          onTap: () async {
                            QuerySnapshot querySnap = await FirebaseFirestore
                                .instance
                                .collection('RegularUsers')
                                .where('username',
                                    isEqualTo: FirebaseApi.realUserLastData!
                                        .getUsername())
                                .get();
                            QueryDocumentSnapshot doc = querySnap.docs[0];
                            DocumentReference docRef = doc.reference;

                            if (doc["disabledLocation"] == true) {
                              await docRef.update({
                                "disabledLocation": false,
                              });
                            } else {
                              await docRef.update({
                                "disabledLocation": true,
                              });
                            }

                            showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  _buildPopupDialog(
                                      context, doc["disabledLocation"]),
                            );
                          }),
                      SpeedDialChild(
                          child: Center(
                              child: Icon(
                            CupertinoIcons.video_camera_solid,
                          )),
                          label: "Disable/Activate Camera Follow",
                          labelStyle: TextStyle(fontSize: 8),
                          backgroundColor: mainColor,
                          onTap: () async {
                            if (cameraFollow == true) {
                              cameraFollow = false;
                            } else {
                              cameraFollow = true;
                            }
                            showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  _buildPopupDialog2(context, cameraFollow),
                            );
                          }),
                      SpeedDialChild(
                          child: Center(
                              child: Icon(
                            CupertinoIcons.search_circle_fill,
                          )),
                          label: "Go to my Location",
                          labelStyle: TextStyle(fontSize: 8),
                          backgroundColor: mainColor,
                          onTap: () async {
                            QuerySnapshot querySnap = await FirebaseFirestore
                                .instance
                                .collection('RegularUsers')
                                .where('username',
                                    isEqualTo: FirebaseApi.realUserLastData!
                                        .getUsername())
                                .get();
                            QueryDocumentSnapshot doc = querySnap.docs[0];
                            GeoPoint loc = doc["location"];
                            _googleMapController
                                ?.animateCamera(CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(loc.latitude, loc.longitude),
                                zoom: 18,
                              ),
                            ));
                          }),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: FloatingActionButton(
                  onPressed: (() {}),
                  child: SpeedDial(
                    spaceBetweenChildren: 0,
                    direction: SpeedDialDirection.down,
                    icon: CupertinoIcons.calendar,
                    spacing: 0,
                    backgroundColor: mainColor,
                    overlayOpacity: 0,
                    children: [
                      SpeedDialChild(
                          child: Center(
                              child: Icon(
                            CupertinoIcons.bolt_fill,
                          )),
                          label: "See Events Nearby",
                          labelStyle: TextStyle(fontSize: 8),
                          backgroundColor: mainColor,
                          onTap: () async {
                            print("Marker SEE EVENTS!");
                            showEvents(context);
                          }),
                      SpeedDialChild(
                          child: Center(
                              child: Icon(
                            CupertinoIcons.bolt_slash_fill,
                          )),
                          label: "Hide Events Nearby",
                          labelStyle: TextStyle(fontSize: 8),
                          backgroundColor: mainColor,
                          onTap: () async {
                            hideEvents();
                          }),
                      SpeedDialChild(
                          child: Center(
                              child: Icon(
                            CupertinoIcons.calendar_badge_plus,
                          )),
                          label: "Add an event!",
                          labelStyle: TextStyle(fontSize: 8),
                          backgroundColor: mainColor,
                          onTap: () async {
                            QuerySnapshot querySnap2 = await FirebaseFirestore
                                .instance
                                .collection('RegularUsers')
                                .where('username',
                                    isEqualTo: FirebaseApi.realUserLastData!
                                        .getUsername())
                                .get();
                            QueryDocumentSnapshot doc = querySnap2.docs[0];
                            DocumentReference docRef2 = doc.reference;
                            GeoPoint loc = doc["location"];

                            showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  _buildPopupDialogAddEvent(
                                      context, loc, doc["username"]),
                            );
                          }),
                    ],
                  ),
                ),
              ),
            ],
          ));
    }
  }

  pageChangeCallback(int lpage) {
    setState(() {
      page = lpage;
    });
  }
}
