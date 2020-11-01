import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:craetor/screens/profile/profile.dart';
import 'package:craetor/screens/singlePost/singlePost.dart';
import 'package:craetor/utils/timeSince.dart';
import 'package:flutter/material.dart';

class OurEachNotification extends StatelessWidget {
  final DocumentSnapshot notificationInfo;

  OurEachNotification({
    this.notificationInfo,
  });

  /*---------------------------------------------------------------------------------------------------
  Inputs:         context - the context that we are working in
  
  Return:         None

  Description:    Navigates to the Profile screen that correlates to the uid
  ---------------------------------------------------------------------------------------------------*/
  void _toProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OurProfile(
          uid: notificationInfo['uid'],
        ),
      ),
    );
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         context - the context we are working in
  
  Return:         None

  Description:    Navigates to the Profile screen that correlates to the uid
  ---------------------------------------------------------------------------------------------------*/
  void _toPost(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OurSinglePost(
          postId: notificationInfo["postId"],
        ),
      ),
    );
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         context - the context we are working in that is passed to next function
  
  Return:         Widget - If like or comment notification type, returns a GestureDectector widget
                    with the preview of the post. Else return an empty Text to not show anything

  Description:    If notification type is like or comment, load a preview of the post, that the user
                  can click on and see the post in its own screen. If not one of the mentioned 
                  notification types, show a black text
  ---------------------------------------------------------------------------------------------------*/
  Widget showPostPicture(BuildContext context) {
    Widget retVal;
    if (notificationInfo["type"] == 0 || notificationInfo["type"] == 1) {
      retVal = GestureDetector(
        onTap: () => _toPost(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    notificationInfo["postPicture"],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      retVal = Text("");
    }
    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         RichText - a bold username paired with the a description of notification

  Description:    If notification type is like or follow, there will be standard message shown, but 
                  if notification type is comment it will also show you a preview of the comment. 
                  Notification gets cut off if it is too long, and return error if invalid notification type
  ---------------------------------------------------------------------------------------------------*/
  RichText showNotificationText() {
    RichText retVal;
    if (notificationInfo["type"] == 0) {
      //like type
      retVal = RichText(
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style: TextStyle(
            color: Colors.white,
          ),
          children: [
            TextSpan(
              text: notificationInfo["likerFirstName"] + " " + notificationInfo["likerLastName"],
              style: TextStyle(fontWeight: FontWeight.w900, fontFamily: "Manjari"),
            ),
            TextSpan(text: " liked your post"),
          ],
        ),
      );
    } else if (notificationInfo["type"] == 1) {
      // comment type
      retVal = RichText(
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style: TextStyle(
            color: Colors.white,
          ),
          children: [
            TextSpan(
              text: notificationInfo["commenterFirstName"] +
                  " " +
                  notificationInfo["commenterLastName"],
              style: TextStyle(fontWeight: FontWeight.w900, fontFamily: "Manjari"),
            ),
            TextSpan(text: " commented: " + notificationInfo["commentContent"]),
          ],
        ),
      );
    } else if (notificationInfo["type"] == 2) {
      // follower type
      retVal = RichText(
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style: TextStyle(
            color: Colors.white,
          ),
          children: [
            TextSpan(
              text: notificationInfo["followerFirstName"] +
                  " " +
                  notificationInfo["followerLastName"],
              style: TextStyle(fontWeight: FontWeight.w900, fontFamily: "Manjari"),
            ),
            TextSpan(text: " is following you"),
          ],
        ),
      );
    } else {
      retVal = RichText(
        text: TextSpan(
          text: "Error: Unknown Type: " + notificationInfo["type"].toString(),
        ),
      );
    }
    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
  Description:    Show a list tile of with a circle avatar of the person that created the notification
                  followed by a short description of the notification, and if it has a post associated to it
                  show a preview of the post
  ---------------------------------------------------------------------------------------------------*/
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        child: ListTile(
          leading: GestureDetector(
            onTap: () => _toProfile(context),
            child: CircleAvatar(
              backgroundImage: NetworkImage(notificationInfo["profilePicture"]),
            ),
          ),
          title: GestureDetector(
            onTap: () => _toProfile(context),
            child: showNotificationText(),
          ),
          subtitle: OurTimeSince().timeSince(notificationInfo["time"]),
          trailing: showPostPicture(context),
        ),
      ),
    );
  }
}
