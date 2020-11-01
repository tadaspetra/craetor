import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OurPost {
  String uid;
  List<TextEditingController> descriptions;
  TextEditingController coverDescription;
  int imageCount;
  List<File> images;
  File coverImage;
  Timestamp time;
  int likeCount;
  String category;
  OurPost({
    this.uid,
    this.descriptions,
    this.imageCount,
    this.images,
    this.time,
    this.likeCount,
    this.category,
  });
}
