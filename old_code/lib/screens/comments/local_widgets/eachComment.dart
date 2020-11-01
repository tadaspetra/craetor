import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:craetor/screens/profile/profile.dart';
import 'package:flutter/material.dart';

class OurEachComment extends StatelessWidget {
  final DocumentSnapshot documentSnapshot;

  OurEachComment({
    this.documentSnapshot,
  });

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         None

  Description:    Navigates to the Profile screen that correlates to the uid
  ---------------------------------------------------------------------------------------------------*/
  void _toProfile(BuildContext context, String uid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OurProfile(
          uid: uid,
        ),
      ),
    );
  }

  /*---------------------------------------------------------------------------------------------------
  Description:    Show comments in a similar stype to the top of a post. It should have the profile picture
                  of the commentor and their name clickable to go to their profile.
  ---------------------------------------------------------------------------------------------------*/

  @override
  Widget build(BuildContext context) {
    bool everythingLoaded = (documentSnapshot["firstName"] == null) ||
        (documentSnapshot["lastName"] == null) ||
        (documentSnapshot["profilePicture"] == null);

    Widget _textPart() {
      String usersName = everythingLoaded
          ? ""
          : (documentSnapshot["firstName"] + " " + documentSnapshot["lastName"]);
      return Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap: () => _toProfile(context, documentSnapshot["uid"]),
              child: Column(
                children: <Widget>[
                  Container(
                    child: Text(
                      usersName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
              child: Text(
                documentSnapshot["comment"],
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
          child: GestureDetector(
            onTap: () => _toProfile(context, documentSnapshot["uid"]),
            child: CircleAvatar(
              backgroundImage: everythingLoaded
                  ? AssetImage("assets/usericon.png")
                  : NetworkImage(documentSnapshot["profilePicture"]),
            ),
          ),
        ),
        _textPart(),
      ],
    );
  }
}
