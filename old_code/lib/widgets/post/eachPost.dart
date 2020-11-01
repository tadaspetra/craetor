import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:craetor/screens/comments/comments.dart';
import 'package:craetor/screens/profile/profile.dart';
import 'package:craetor/services/firebase/authProvider.dart';
import 'package:craetor/services/firebase/baseAuth.dart';
import 'package:craetor/services/firebase/baseStore.dart';
import 'package:craetor/utils/timeSince.dart';
import 'package:flutter/material.dart';

class OurEachPost extends StatefulWidget {
  final DocumentSnapshot postInfo;
  OurEachPost({
    this.postInfo,
  });
  @override
  State<StatefulWidget> createState() => _OurEachPostState();
}

class _OurEachPostState extends State<OurEachPost> {
  String ownerFirstName;
  String ownerLastName;
  String ownerProfilePicture;
  String usersName = "";
  int _currentIndex = 0;
  bool _isLiked = false;
  bool _initiallyLiked = false;
  int initialLikeCount = 0;
  OurBaseAuth auth;
  String _currentUserUid;
  String _currentDescription = "";

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         None

  Description:    Navigates to the Profile screen that correlates to the uid
  ---------------------------------------------------------------------------------------------------*/
  void _toProfile(String uid) {
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
  Inputs:         None
  
  Return:         None
  
  Description:    Whenever the post is being loaded in, you want to get that posters information. Then you
                  want to check if the current user has already liked this post so you know whether like
                  button has to be filled in. We also want to take the like count and put it in a local
                  variable, because the like count that gets passed into this post is not going to change.
                  The whole widget won't be reloaded, only the like Count will be so we have to separate it out
                  from the likeCount we were passed in.
  ---------------------------------------------------------------------------------------------------*/
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    auth = OurAuthProvider.of(context).auth;
    OurBaseStore().getUserInformation(widget.postInfo.data["uid"]).then((user) {
      if (this.mounted) {
        setState(() {
          ownerFirstName = user.data["firstName"];
          ownerLastName = user.data["lastName"];
          ownerProfilePicture = user.data["profilePicture"];
          usersName = (ownerFirstName + " " + ownerLastName);
        });
      }
    });
    auth.getCurrentUser().then((user) {
      _currentUserUid = user.uid;
      OurBaseStore().doesLikeExist(widget.postInfo.documentID, user.uid).then((user) {
        if (this.mounted) {
          setState(() {
            if (!user.exists || user == null) {
              _isLiked = false;
              _initiallyLiked = false;
            } else {
              _isLiked = true;
              _initiallyLiked = true;
            }
            initialLikeCount = widget.postInfo.data["likeCount"];
          });
        }
      });
    });
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         Widget - returns the posters information in the top bar
  
  Description:    Once the posters information is retreived by the future call, display the profile picture
                  along with the first and last name of the user. If the top section is clicked, go to that
                  posters profile
  ---------------------------------------------------------------------------------------------------*/
  Widget _topSection() {
    bool everythingLoaded =
        (ownerFirstName == null) || (ownerLastName == null) || (ownerProfilePicture == null);

    Widget _textPart() {
      return Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap: () => _toProfile(widget.postInfo.data["uid"]),
              child: Column(
                children: <Widget>[
                  Container(
                    child: Text(
                      usersName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
              child: Row(
                children: <Widget>[
                  OurTimeSince().timeSince(widget.postInfo.data["time"]),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.only(right: 15.0),
                    child: Text(
                      (_currentIndex + 1).toString() +
                          "/" +
                          (widget.postInfo.data["images"].length + 1).toString(),
                      style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                      color: _currentDescription == ""
                          ? Colors.transparent
                          : Colors.grey[600].withOpacity(.5),
                      width: 2.0),
                ),
              ),
              padding: EdgeInsets.only(left: 10),
              child: Text(_currentDescription),
            ),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          onTap: () => _toProfile(widget.postInfo.data["uid"]),
          child: Container(
            padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
            child: CircleAvatar(
              backgroundImage: everythingLoaded
                  ? AssetImage("assets/usericon.png")
                  : NetworkImage(ownerProfilePicture),
            ),
          ),
        ),
        _textPart(),
      ],
    );
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         Widget - returns pictures and descriptions associated with the pictures
  
  Description:    Creates a carousel that you can swipe across and see all the pictures. The descriptions
                  get rebuilt whenever a swipe happens. You can double tap on the image to like the photo
                  Notice the set up of this carousel is different from the submitCreation screen, since 
                  the list is of a different type.
  ---------------------------------------------------------------------------------------------------*/
  Widget _mainCarousel() {
    List<String> imageList = List.from(widget.postInfo.data["images"]);
    imageList.insert(0, widget.postInfo.data["coverImage"]);
    List<String> descriptionList = List.from(widget.postInfo.data["descriptions"]);
    descriptionList.insert(0, widget.postInfo.data["coverDescription"]);
    bool infiteScroll = false;
    if (imageList.length > 1) {
      infiteScroll = true;
    }
    if (descriptionList.isEmpty) {
      _currentDescription = "";
    } else {
      _currentDescription = descriptionList[_currentIndex];
    }

    return Column(
      children: <Widget>[
        GestureDetector(
          onDoubleTap: () {
            _updateLike();
            //TODO: Add animation over picture to show user that they liked it
          },
          child: CarouselSlider(
            height: MediaQuery.of(context).size.width,
            viewportFraction: 1.0,
            initialPage: 0,
            enableInfiniteScroll: infiteScroll, // this makes it so we can only scroll one way
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index; //TODO: Can use this to display which slide you are on
                _currentDescription = descriptionList[_currentIndex];
              });
            },
            items: imageList.map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    child: Image.network(i),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         None

  Description:    Updates the likes to change accordingly from the previously stored value in the database. 
                  If it was initially liked, the logic is a bit different given that it needs to decrease the value.
                  Add/remove notification if it was liked or disliked
  ---------------------------------------------------------------------------------------------------*/
  void _updateLike() {
    auth.getCurrentUser().then((user) {
      setState(() {
        if (_initiallyLiked) {
          _isLiked = !_isLiked;
          _initiallyLiked = false;
          OurBaseStore().updateLike(widget.postInfo.documentID, _isLiked, user.uid);
          initialLikeCount = widget.postInfo.data["likeCount"] - 1;
          if (user.uid != widget.postInfo.data["uid"]) {
            OurBaseStore().removeLikeNotification(
              user.uid,
              widget.postInfo.documentID,
              widget.postInfo.data["uid"],
            );
          }
        } else {
          _isLiked = !_isLiked;
          OurBaseStore().updateLike(widget.postInfo.documentID, _isLiked, user.uid);
          if (user.uid != widget.postInfo.data["uid"]) {
            if (_isLiked) {
              OurBaseStore().addLikeNotification(
                user.uid,
                widget.postInfo.documentID,
                widget.postInfo.data["coverImage"],
                widget.postInfo.data["uid"],
              );
            } else {
              OurBaseStore().removeLikeNotification(
                user.uid,
                widget.postInfo.documentID,
                widget.postInfo.data["uid"],
              );
            }
          }
        }
      });
    });
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         Widget - shows the comments, likes, and how long ago it was posted

  Description:    Once the data is loaded, all the information is displayed. The logic for showing the like
                  button and like count is done so that it can change independedly from the rest of the post,
                  and also initialLikeCount never changes. Unless it was initially liked then it will decrement once.
  ---------------------------------------------------------------------------------------------------*/
  Widget _statSection() {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  child: Row(
                    children: <Widget>[
                      _isLiked
                          ? Icon(
                              Icons.favorite,
                              color: Theme.of(context).accentColor,
                              size: 30.0,
                            )
                          : Icon(
                              Icons.favorite_border,
                              color: Theme.of(context).secondaryHeaderColor,
                              size: 30.0,
                            ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          "like",
                          style: TextStyle(
                            color: _isLiked
                                ? Theme.of(context).accentColor
                                : Theme.of(context).secondaryHeaderColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () => _updateLike(),
                ),
                FlatButton(
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.chat_bubble_outline,
                        color: Theme.of(context).secondaryHeaderColor,
                        size: 30.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          "comment",
                          style: TextStyle(
                            color: Theme.of(context).secondaryHeaderColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OurComments(
                          postId: widget.postInfo.documentID,
                          currentUid: _currentUserUid,
                          postOwnerUid: widget.postInfo.data["uid"],
                          //first picture passed for if comment notification needs to be sent out
                          firstPostPicture: widget.postInfo.data["coverImage"][0],
                        ),
                      ),
                    ),
                  }, // send to comment screen
                ),
                //like count below, currently like count will not be shown
                //Text((initialLikeCount + ((_isLiked && !_initiallyLiked) ? 1 : 0)).toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /*---------------------------------------------------------------------------------------------------
  Description:    Builds up the post top to bottom and then puts a little extra padding at the bottom.
                  You don't want to put padding at the top because then the first post will have some 
                  separation from the appbar(or other things above).
  ---------------------------------------------------------------------------------------------------*/
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _topSection(),

        _mainCarousel(),
        _statSection(),

        //_commentSection(),
        SizedBox(
          height: 20.0,
        )
      ],
    );
  }
}
