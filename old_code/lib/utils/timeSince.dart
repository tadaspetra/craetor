import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OurTimeSince {
  Text timeSince(Timestamp time) {
    Text retVal;
    int difference = Timestamp.now().seconds - time.seconds;
    if (difference < 60) {
      if (difference == 1) {
        retVal = Text("$difference second ago",
            style: TextStyle(
              color: Colors.grey[600], // TODO: Styling is static, make it dynamic
            ));
      } else {
        retVal = Text("$difference seconds ago",
            style: TextStyle(
              color: Colors.grey[600],
            ));
      }
    } else {
      if (difference < 3600) {
        difference = difference ~/ 60;
        if (difference == 1) {
          retVal = Text("$difference minute ago",
              style: TextStyle(
                color: Colors.grey[600],
              ));
        } else {
          retVal = Text("$difference minutes ago",
              style: TextStyle(
                color: Colors.grey[600],
              ));
        }
      } else {
        if (difference < 86400) {
          difference = difference ~/ 3600;
          if (difference == 1) {
            retVal = Text("$difference hour ago",
                style: TextStyle(
                  color: Colors.grey[600],
                ));
          } else {
            retVal = Text("$difference hours ago",
                style: TextStyle(
                  color: Colors.grey[600],
                ));
          }
        } else {
          if (difference < 31536000) {
            difference = difference ~/ 86400;
            if (difference == 1) {
              retVal = Text("$difference day ago",
                  style: TextStyle(
                    color: Colors.grey[600],
                  ));
            } else {
              retVal = Text("$difference days ago",
                  style: TextStyle(
                    color: Colors.grey[600],
                  ));
            }
          } else {
            difference = difference ~/ 31536000;
            if (difference == 1) {
              retVal = Text("$difference year ago",
                  style: TextStyle(
                    color: Colors.grey[600],
                  ));
            } else {
              retVal = Text("$difference years ago",
                  style: TextStyle(
                    color: Colors.grey[600],
                  ));
            }
          }
        }
      }
    }
    return retVal;
  }
}
