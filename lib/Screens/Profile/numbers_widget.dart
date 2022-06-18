import 'package:flutter/material.dart';
import 'package:overlook/constants.dart';

class NumbersWidget extends StatelessWidget {
  @override
  int? followers;
  int? following;
  NumbersWidget(int followers, int following) {
    this.followers = followers;
    this.following = following;
  }

  void updateNumbersFollowers(int followers) {
    this.followers = followers;
  }

  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buildButton(context, this.following.toString(), 'Following'),
          buildDivider(),
          buildButton(context, this.followers.toString(), 'Followers'),
        ],
      );
  Widget buildDivider() => Container(
        height: 24,
        child: VerticalDivider(),
      );

  Widget buildButton(BuildContext context, String value, String text) =>
      MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 4),
        onPressed: () {},
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            changedColors
                ? Text(
                    value,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: mainColor),
                  )
                : Text(
                    value,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: mainColorSec),
                  ),
            SizedBox(height: 2),
            Text(
              text,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.white),
            ),
          ],
        ),
      );
}
