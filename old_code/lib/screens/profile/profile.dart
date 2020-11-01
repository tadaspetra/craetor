import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:craetor/models/globals.dart';
import 'package:craetor/screens/accountInfo/accountInfo.dart';
import 'package:craetor/widgets/post/eachPost.dart';
import 'package:flutter/material.dart';
import 'package:craetor/services/firebase/authProvider.dart';
import 'package:craetor/services/firebase/baseStore.dart';
import 'package:flutter/widgets.dart';
import 'package:craetor/models/userData.dart';

import 'dart:async';

class OurProfile extends StatefulWidget {
  final String uid;

  OurProfile({
    @required this.uid,
  });
  State<StatefulWidget> createState() => _OurProfileState();
}
//TickerProviderStateMixin used for transitions between the Tabs

class _OurProfileState extends State<OurProfile> with TickerProviderStateMixin {
  static const String routeName = 'profile';
  OurUserData _userData = OurUserData();
  TabController _tabController;

  List<DocumentSnapshot> _posts = List();
  DocumentSnapshot _lastPost;
  bool _atTheBottom = false;
  bool _scrollPending = false;

  String username = "loading";
  int index;
  bool _showFollow = false;
  bool _isFollowing = false;
  String _currentUser;
  int _currentFollowers = 0;
  int _currentCreations = 0;
  bool isFollowButtonDisabled = false;
  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         None

  Description:    Initializes a tab controller and retrieves the user's name when the profile is started
                  up and allows for the rebuild of the tabs to switch between the tab's widgets. Also performs
                  the determination of whether this is the current users profile or somebody elses.
                  And also if it is somebody elses, determines whether they are following them. The flags 
                  are set accordingly
  ---------------------------------------------------------------------------------------------------*/
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tabController = TabController(length: 2, vsync: this);
    var auth = OurAuthProvider.of(context).auth;

    auth.getCurrentUser().then((user) {
      _currentUser = user.uid;
      if (user.uid == widget.uid) {
        //current user on his own profile page
        _showFollow = false;
      } else {
        //current user on someone elses profile
        _showFollow = true;
        OurBaseStore().doesFollowExist(_currentUser, widget.uid).then((user) {
          setState(() {
            if (!user.exists || user == null) {
              _isFollowing = false;
            } else {
              _isFollowing = true;
            }
          });
        });
      }
      _updatePosts();
      OurBaseStore().getUserInformation(widget.uid).then((user) {
        setState(() {
          _userData.uid = user.documentID;
          _userData.firstName = user.data["firstName"];
          _userData.lastName = user.data["lastName"];
          username = _userData.firstName + " " + _userData.lastName;
          _userData.profilePicture = user.data["profilePicture"];

          _userData.bio = user.data["bio"];
          _userData.experience = user.data["experience"];
          _userData.topCategory = user.data["topCategory"];
          _userData.website = user.data["website"];
          _userData.email = user.data["email"];
          _userData.phoneNumber = user.data["phoneNumber"];
          _userData.education = user.data["education"];
          _userData.age = user.data["age"];
          _userData.workplace = user.data["workplace"];
          _userData.location = user.data["location"];
        });
      });
    });
    OurBaseStore().getFollowers(widget.uid).then((data) {
      setState(() {
        _currentFollowers = data.length;
      });
    });
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         None

  Description:    Discards any resources used by the tab controller. After this is called tab contoller
                  is not in a usable state so it is discarded
  ---------------------------------------------------------------------------------------------------*/
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _goToAccountInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OurAccountInfo(),
      ),
    );
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         None
  
  Description:    A future that used the refresh indicator
  ---------------------------------------------------------------------------------------------------*/
  Future<void> _updatePosts() async {
    List<DocumentSnapshot> _templist = List();
    _scrollPending = true;
    _templist = await OurBaseStore().getUserPosts(widget.uid);
    _currentCreations = _templist.length;
    if (_templist.length < fPOSTQUERYLENTH) {
      _atTheBottom = true;
    } else {
      _lastPost = _templist[fPOSTQUERYLENTH - 1];
      _atTheBottom = false;
    }
    setState(() {
      _posts = _templist;
      _scrollPending = false;
    });
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         None
  
  Description:    A future that uses scroll bottom detection
  ---------------------------------------------------------------------------------------------------*/
  Future<void> _addToPosts() async {
    List<DocumentSnapshot> _templist = List();
    _scrollPending = true;
    _templist = await OurBaseStore().getNextUserPosts(widget.uid, _lastPost);
    _currentCreations = _templist.length;
    if (_templist.length < fPOSTQUERYLENTH) {
      _atTheBottom = true;
    } else {
      _lastPost = _templist[fPOSTQUERYLENTH - 1];
      _atTheBottom = false;
    }
    setState(() {
      _posts.addAll(_templist);
      _scrollPending = false;
    });
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         Widget- Either displays button or empty widget

  Description:    If current user already following this user display "unfollow" button. If not yet 
                  following display "follow". This is only displayed if necessary. Ex: On your own
                  profile you should not see a follow button.
  ---------------------------------------------------------------------------------------------------*/
  Widget _followButton() {
    Widget retVal;
    if (_showFollow) {
      String _isFollowingText = "loading";
      if (_isFollowing) {
        _isFollowingText = "unfollow";
      } else {
        _isFollowingText = "follow";
      }
      retVal = FlatButton(
        child: Text(
          _isFollowingText,
          style: TextStyle(color: Theme.of(context).accentColor),
        ),
        onPressed: () {
          if (!isFollowButtonDisabled) {
            _updateFollow();
          }
        },
      );
    } else {
      retVal = Text("");
    }
    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         None

  Description:    Either remove or add like and notification to firebase
  ---------------------------------------------------------------------------------------------------*/
  void _updateFollow() {
    isFollowButtonDisabled = true;
    OurBaseStore().updateFollow(_currentUser, widget.uid, !_isFollowing).then((value) {
      setState(() {
        _isFollowing = !_isFollowing;
        if (_isFollowing) {
          OurBaseStore().addFollowNotification(_currentUser, widget.uid).then((data) {
            isFollowButtonDisabled = false;
          });
        } else {
          OurBaseStore().removeFollowNotification(_currentUser, widget.uid).then((data) {
            isFollowButtonDisabled = false;
          });
        }
      });
    });
  }
  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         Widget- Displays the Row for user's information

  Description:    Displays user info the BoxDecoration used as the profile image. Within the row there
                  is a Column for user's caption and the amount of creates and followers
  ---------------------------------------------------------------------------------------------------*/

  Widget _displayUserDescription() {
    double _width = MediaQuery.of(context).size.width;
    bool everythingLoaded = (_userData.profilePicture == null);
    Widget retVal;

    Text _quickInfo() {
      Text retVal;
      String followerText;
      String creationText;

      if (_currentFollowers == 1) {
        followerText = _currentFollowers.toString() + " follower  -  ";
      } else {
        followerText = _currentFollowers.toString() + " followers  -  ";
      }
      if (_currentCreations == 1) {
        creationText = _currentCreations.toString() + " creation";
      } else {
        creationText = _currentCreations.toString() + " creations";
      }
      retVal = Text(
        followerText + creationText,
        style: TextStyle(
          fontSize: 18.0,
        ),
      );
      return retVal;
    }

    Widget _profilePicture() {
      Widget localRetVal;

      if (_showFollow) {
        localRetVal = CircleAvatar(
          backgroundImage: everythingLoaded
              ? AssetImage("assets/usericon.png")
              : NetworkImage(_userData.profilePicture),
          radius: _width * .2,
        );
      } else {
        localRetVal = GestureDetector(
          onTap: _goToAccountInfo,
          child: CircleAvatar(
            backgroundImage: everythingLoaded
                ? AssetImage("assets/usericon.png")
                : NetworkImage(_userData.profilePicture),
            radius: _width * .2,
            child: Container(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                color: Colors.black.withOpacity(.6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "edit profile",
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ],
                ),
              ),
              alignment: Alignment.bottomCenter,
            ),
          ),
        );
      }
      return localRetVal;
    }

    retVal = Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(10.0),
              child: _profilePicture(),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: _quickInfo(),
            ),
          ],
        )
      ],
    );

    return retVal;
  }

/*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         Text- display the users first and last name

  Description:    Once both first and last name are loaded return a text widget with the contents
  ---------------------------------------------------------------------------------------------------*/
  Text _displayName() {
    return Text(
      (_userData.firstName == null ? "loading..." : _userData.firstName) +
          " " +
          (_userData.lastName == null ? "" : _userData.lastName),
      style: TextStyle(fontWeight: FontWeight.w700),
    );
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         Widget- Return user's additional information

  Description:    Return user's additional information
  ---------------------------------------------------------------------------------------------------*/

  Widget _displayMoreInfo() {
    Widget retVal;

    Widget _displayContent(String title, String data) {
      Widget retVal;

      if (data != null && data != "") {
        retVal = Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(
                child: Text(
                  data,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        );
      } else {
        retVal = Container();
      }

      return retVal;
    }

    _displayRow(String data) {
      Widget retVal;
      switch (data) {
        case "bio":
          retVal = _displayContent("bio: ", _userData.bio);
          break;
        case "experience":
          retVal = _displayContent("experience: ", _userData.experience);
          break;
        case "topCategory":
          if (_userData.topCategory == "none") {
            retVal = _displayContent("top category: ", null);
          } else {
            retVal = _displayContent("top category: ", _userData.topCategory);
          }
          break;
        case "website":
          retVal = _displayContent("website: ", _userData.website);
          break;
        case "email":
          retVal = _displayContent("email: ", _userData.email);
          break;
        case "phoneNumber":
          retVal = _displayContent("phone number: ", _userData.phoneNumber);
          break;
        case "education":
          retVal = _displayContent("education: ", _userData.education);
          break;
        case "age":
          retVal = _displayContent("age: ", _userData.age);
          break;
        case "workplace":
          retVal = _displayContent("workplace: ", _userData.workplace);
          break;
        case "location":
          retVal = _displayContent("location: ", _userData.location);
          break;
        default:
      }

      return retVal;
    }

    retVal = Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView(
        children: <Widget>[
          _displayRow("bio"),
          _displayRow("experience"),
          _displayRow("topCategory"),
          _displayRow("website"),
          _displayRow("email"),
          _displayRow("phoneNumber"),
          _displayRow("education"),
          _displayRow("age"),
          _displayRow("workplace"),
          _displayRow("location"),
        ],
      ),
    );
    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         Widget- returns a Listview in a FutureBuilder

  Description:    Returns a list of creations from the user. As you scroll down the posts will be loaded in.
  ---------------------------------------------------------------------------------------------------*/

  Widget _displayCreations() {
    Widget retVal;
    if (_posts.length == null) {
      return Center(
        child: Text("loading..."),
      );
    } else {
      retVal = NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if ((scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) &&
              !_scrollPending &&
              !_atTheBottom) {
            _addToPosts();
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
      );
    }
    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
  Description:    Display a top section that has user profile info, and when you scroll the tab
                  bar stays at the top. Below the tab bar you have options to see the users posts
                  or information about the user
  ---------------------------------------------------------------------------------------------------*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, value) {
            return [
              SliverAppBar(
                title: _displayName(),
                centerTitle: true,
                pinned: true,
                actions: <Widget>[
                  _followButton(),
                ],
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  _displayUserDescription(),
                ]),
              ),
              SliverAppBar(
                pinned: true,
                primary: false,
                automaticallyImplyLeading: false,
                title: TabBar(
                  tabs: [
                    Tab(text: "creations"),
                    Tab(text: "more info"),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _displayCreations(),
              _displayMoreInfo(),
            ],
          ),
        ),
      ),
    );
  }
}
