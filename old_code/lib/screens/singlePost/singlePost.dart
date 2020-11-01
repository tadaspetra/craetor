import 'package:craetor/services/firebase/baseStore.dart';
import 'package:craetor/widgets/post/eachPost.dart';
import 'package:flutter/material.dart';

class OurSinglePost extends StatefulWidget {
  final String postId;

  OurSinglePost({
    this.postId,
  });
  @override
  _OurSinglePostState createState() => _OurSinglePostState();
}

class _OurSinglePostState extends State<OurSinglePost> {
  Future _postData;

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         None
  
  Description:    Alternative to initState, Load in the post that corresponds to postId
  ---------------------------------------------------------------------------------------------------*/
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      _postData = OurBaseStore().getPostByPostId(widget.postId);
    });
  }

  /*---------------------------------------------------------------------------------------------------  
  Description:    Just loads the single post that is available once the post data is loaded in
  ---------------------------------------------------------------------------------------------------*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: _postData,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.none) {
            return Center(
              child: Text("loading..."),
            );
          } else {
            return OurEachPost(
              postInfo: snapshot.data,
            );
          }
        },
      ),
    );
  }
}
