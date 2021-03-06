import 'package:flutter/material.dart';
import 'package:overlook/constants.dart';
import 'package:overlook/new/comments.dart';

class Popup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Image Popup example')),
        backgroundColor: Colors.grey[800],
        body: CircleAvatar(
            child: GestureDetector(
                // onTap: () async {
                //   await showDialog(
                //       context: context, builder: (_) => ImageDialog());
                // },
                ),
            radius: 50.0,
            //Photo by Tamas Tuzes-Katai on Unsplash
            backgroundImage: AssetImage('assets/tamas.jpg')));
  }
}

class ImageDialog extends StatelessWidget {
  String postID = "";
  String imageURL = "";
  String likes = "";
  bool alternateColor = false;

  ImageDialog(String _post, String imageURL, String _likes, bool alt) {
    this.postID = _post;
    this.imageURL = imageURL;
    this.likes = _likes;
    alternateColor = alt;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: alternateColor
          ? Container(
              color: mainColor,
              width: 300,
              height: 350,
              child: Column(
                children: [
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                        color: secondaryColor,
                        image: DecorationImage(
                            image: NetworkImage(imageURL),
                            fit: BoxFit.contain)),
                  ),
                  Container(
                    color: secondaryColor,
                    child: Row(
                      children: [
                        Container(
                          child: Row(children: [
                            IconButton(
                              icon: Icon(Icons.thumb_up_alt_rounded),
                              color: mainColor,
                              onPressed: () {},
                            ),
                            Text(likes, style: TextStyle(color: Colors.white)),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Likes",
                              style: TextStyle(color: Colors.white),
                            ),
                          ]),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Comments(postID)));
                          },
                          child: Row(
                            children: [
                              Icon(Icons.comment_rounded, color: mainColor),
                              SizedBox(
                                width: 5,
                              ),
                              Text("Comments",
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          : Container(
              color: mainColorSec,
              width: 300,
              height: 350,
              child: Column(
                children: [
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                        color: secondaryColorSec,
                        image: DecorationImage(
                            image: NetworkImage(imageURL),
                            fit: BoxFit.contain)),
                  ),
                  Container(
                    color: secondaryColorSec,
                    child: Row(
                      children: [
                        Container(
                          child: Row(children: [
                            IconButton(
                              icon: Icon(Icons.thumb_up_alt_rounded),
                              color: mainColorSec,
                              onPressed: () {},
                            ),
                            Text(likes, style: TextStyle(color: Colors.white)),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Likes",
                              style: TextStyle(color: Colors.white),
                            ),
                          ]),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Comments(postID)));
                          },
                          child: Row(
                            children: [
                              Icon(Icons.comment_rounded, color: mainColorSec),
                              SizedBox(
                                width: 5,
                              ),
                              Text("Comments",
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
