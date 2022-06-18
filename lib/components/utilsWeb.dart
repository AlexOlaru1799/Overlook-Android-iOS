import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:location/location.dart';

import 'package:overlook/components/storage_service.dart';

final Storage storage = Storage();

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

  // }

}
