import 'package:cloud_firestore/cloud_firestore.dart';

class OurFeedQuery {
  DocumentSnapshot lastPost;
  bool active;
  OurFeedQuery({
    this.lastPost,
    this.active,
  });
}
