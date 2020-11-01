import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:craetor/models/globals.dart';
import 'package:craetor/screens/feed/local_widgets/feedQuery.dart';
import 'package:craetor/services/firebase/authProvider.dart';
import 'package:craetor/services/firebase/baseStore.dart';
import 'package:craetor/widgets/indicators/refreshIndicator.dart';
import 'package:craetor/widgets/post/eachPost.dart';
import 'package:flutter/material.dart';

class OurFeed extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OurFeedState();
}

class _OurFeedState extends State<OurFeed> {
  String email = "loading...";
  int fMAXQUERYLENGTH = 10;

  List<OurFeedQuery> _lastPosts = List();
  List<DocumentSnapshot> _posts = List();
  List<String> _following = List();
  bool _atTheBottom = false;
  bool _scrollPending = false;

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         None
  
  Description:    Alternative to initState, Load in the posts from users that the current user is following
  ---------------------------------------------------------------------------------------------------*/
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateFeed();
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         None
  
  Description:    A future used the refresh indicator
  ---------------------------------------------------------------------------------------------------*/
  Future<void> _updateFeed() async {
    List<DocumentSnapshot> _tempList = List();
    List<DocumentSnapshot> _tempFollowing = List();
    _following = List();
    _posts = List();
    _lastPosts = List();
    _scrollPending = true;

    var auth = OurAuthProvider.of(context).auth;
    auth.getCurrentUser().then((user) async {
      _tempFollowing = await OurBaseStore().getFollowing(user.uid);
      _tempFollowing.asMap().forEach((index, data) {
        _following.add(_tempFollowing[index].documentID);
      });
      int _loopLength = (_following.length / fMAXQUERYLENGTH).ceil();
      for (int i = 0; i < _loopLength; i++) {
        // goes through all followers once and gets recent posts
        // from groups of 10 followers
        OurFeedQuery _feedQuery = OurFeedQuery();
        List<DocumentSnapshot> _eachTemp = List();
        if (i == _loopLength - 1) {
          //the last loop iteration will not have a full list
          if ((_following.length % fMAXQUERYLENGTH) == 0) {
            //in case followers count divisible exactly by 10 followers
            _eachTemp = await OurBaseStore().getFeed(
                _following.sublist(fMAXQUERYLENGTH * i, (fMAXQUERYLENGTH * i + fMAXQUERYLENGTH)));
          } else {
            // last loop, not full list of 10
            _eachTemp = await OurBaseStore().getFeed(_following.sublist(
                fMAXQUERYLENGTH * i, fMAXQUERYLENGTH * i + (_following.length % fMAXQUERYLENGTH)));
          }
        } else {
          // not last loop, full list of 10
          _eachTemp = await OurBaseStore().getFeed(
              _following.sublist(fMAXQUERYLENGTH * i, (fMAXQUERYLENGTH * i + fMAXQUERYLENGTH)));
        }

        if (_eachTemp.length < fPOSTQUERYLENTH) {
          // for each iteration of 10 followers get the feed info for that group
          _feedQuery.active = false;
        } else {
          _feedQuery.active = true;
          _feedQuery.lastPost = _eachTemp[fPOSTQUERYLENTH - 1];
        }
        _lastPosts.add(_feedQuery); // add feed info and query for 10 followers to total list.
        _tempList.addAll(_eachTemp);
      }
      if (_tempList.length < fPOSTQUERYLENTH) {
        _atTheBottom = true;
      } else {
        _atTheBottom = false;
      }
      _tempList.sort((a, b) {
        return b.data["time"].compareTo(a.data["time"]);
      });

      setState(() {
        _posts = _tempList;
        _scrollPending = false;
      });
    });
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         None
  
  Description:    A future used the refresh indicator
  ---------------------------------------------------------------------------------------------------*/
  Future<void> _addToFeed() async {
    List<DocumentSnapshot> _tempList = List();
    _scrollPending = true;

    int _loopLength = (_following.length / fMAXQUERYLENGTH).ceil();
    for (int i = 0; i < _loopLength; i++) {
      if (_lastPosts[i].active) {
        // from groups of 10 followers
        OurFeedQuery _feedQuery = OurFeedQuery();
        List<DocumentSnapshot> _eachTemp = List();
        if (i == _loopLength - 1) {
          //the last loop iteration will not have a full list
          if ((_following.length % fMAXQUERYLENGTH) == 0) {
            _eachTemp = await OurBaseStore().getNextFeed(
                _following.sublist(fMAXQUERYLENGTH * i, (fMAXQUERYLENGTH * i + fMAXQUERYLENGTH)),
                _lastPosts[i].lastPost);
          } else {
            _eachTemp = await OurBaseStore().getNextFeed(
                _following.sublist(fMAXQUERYLENGTH * i,
                    fMAXQUERYLENGTH * i + (_following.length % fMAXQUERYLENGTH)),
                _lastPosts[i].lastPost);
          }
        } else {
          _eachTemp = await OurBaseStore().getNextFeed(
              _following.sublist(fMAXQUERYLENGTH * i, (fMAXQUERYLENGTH * i + fMAXQUERYLENGTH)),
              _lastPosts[i].lastPost);
        }

        if (_eachTemp.length < fPOSTQUERYLENTH) {
          _feedQuery.active = false;
        } else {
          _feedQuery.active = true;
          _feedQuery.lastPost = _eachTemp[fPOSTQUERYLENTH - 1];
        }
        _lastPosts[i] = _feedQuery;
        _tempList.addAll(_eachTemp);
      }
    }
    if (_tempList.length < fPOSTQUERYLENTH) {
      _atTheBottom = true;
    } else {
      _atTheBottom = false;
    }
    _tempList.sort((a, b) {
      return b.data["time"].compareTo(a.data["time"]);
    });

    setState(() {
      _posts.addAll(_tempList);
      _scrollPending = false;
    });
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         Widget - main feed section that user uses
  
  Description:    Returns a list of posts that gets added to as you scroll down, and refreshes when
                  you pull down from the top.
  ---------------------------------------------------------------------------------------------------*/
  Widget _mainSection() {
    Widget retVal;

    if (_posts.length == null) {
      return Center(
        child: Text("loading..."),
      );
    } else {
      retVal = retVal = NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if ((scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) &&
              !_scrollPending &&
              !_atTheBottom) {
            _addToFeed();
            _scrollPending = true;
            SnackBar _snackbar = SnackBar(
              backgroundColor: Colors.black,
              content: Text(
                "loading more posts...",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
              duration: Duration(seconds: 1),
            );
            Scaffold.of(context).showSnackBar(_snackbar);
          }
          return true;
        },
        child: MyRefreshIndicator(
          onRefresh: () async {
            _scrollPending = true;
            await _updateFeed();
            return;
          },
          child: (_posts.length == 0)
              ? Center(
                  child: Text("no posts found :("),
                )
              : ListView.builder(
                  itemCount: _posts.length,
                  itemBuilder: (BuildContext context, int index) {
                    return OurEachPost(
                      postInfo: _posts[index],
                    );
                  },
                ),
        ),
      );
    }

    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
  Description:    Scaffold that contains an appbar and in the body will show a
                  text that it is loading until the post data is retrieved, then it will build a ListView 
                  of the posts displayed in our post format. If you pull down from the top the contents
                  will refresh
  ---------------------------------------------------------------------------------------------------*/
  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: Key("first"),
      appBar: AppBar(
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            "assets/logo_v4.png",
            width: (_screenWidth * .3),
          ),
        ),
      ),
      body: _mainSection(),
    );
  }
}
