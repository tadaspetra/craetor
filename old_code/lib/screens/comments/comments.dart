import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:craetor/models/globals.dart';
import 'package:craetor/services/firebase/baseStore.dart';
import 'package:craetor/widgets/indicators/refreshIndicator.dart';
import 'package:craetor/screens/comments/local_widgets/eachComment.dart';
import 'package:flutter/material.dart';

class OurComments extends StatefulWidget {
  final String postId;
  final String currentUid;
  final dynamic firstPostPicture;
  final String postOwnerUid;

  OurComments({
    this.postId,
    this.currentUid,
    this.firstPostPicture,
    this.postOwnerUid,
  });
  State<StatefulWidget> createState() => _OurCommentsState();
}

class _OurCommentsState extends State<OurComments> {
  List<DocumentSnapshot> _comments = List();
  DocumentSnapshot _lastComment;
  bool _atTheBottom = false;
  bool _scrollPending = false;

  static TextEditingController _commentController = TextEditingController();
  String get _textValueComment => _commentController.text;
  String _firstName;
  String _lastName;
  String _profilePicture;

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         None

  Description:    Everytime something changes the comments get loaded in. And also reset the controller
                  so that you dont see the past comment typed in.
  ---------------------------------------------------------------------------------------------------*/
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _commentController.text = "";
    _updateComments();
    OurBaseStore().getUserInformation(widget.currentUid).then((user) {
      _firstName = user.data["firstName"];
      _lastName = user.data["lastName"];
      _profilePicture = user.data["profilePicture"];
    });
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         None

  Description:    When you refresh the page, load in a certain number of things
  ---------------------------------------------------------------------------------------------------*/
  Future<void> _updateComments() async {
    List<DocumentSnapshot> _templist = List();
    _scrollPending = true;
    _templist = await OurBaseStore().getComments(widget.postId);
    if (_templist.length < fCOMMENTQUERYLENGTH) {
      _atTheBottom = true;
    } else {
      _lastComment = _templist[fCOMMENTQUERYLENGTH - 1];
      _atTheBottom = false;
    }
    setState(() {
      _comments = _templist;
      _scrollPending = false;
    });
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         None

  Description:    When you scroll add more comments as you go down
  ---------------------------------------------------------------------------------------------------*/
  Future<void> _addToComments() async {
    List<DocumentSnapshot> _templist = List();
    _scrollPending = true;
    _templist = await OurBaseStore().getNextComments(widget.postId, _lastComment);
    if (_templist.length < fCOMMENTQUERYLENGTH) {
      _atTheBottom = true;
    } else {
      _lastComment = _templist[fCOMMENTQUERYLENGTH - 1];
      _atTheBottom = false;
    }
    setState(() {
      _comments.addAll(_templist);
      _scrollPending = false;
    });
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         None

  Description:    Add the comment and notification for comment to firebase with the specific inputs.
  ---------------------------------------------------------------------------------------------------*/
  void _addComment() {
    if (_textValueComment == "" || _textValueComment == null) {
      //print("You need to add a comment");
    } else if (_textValueComment.length > 2000) {
      //TODO: Figure out correct value that would be too long
      //and add user interface to see the prints
      //print("Your comment is longer then 1000 characters")
    } else {
      OurBaseStore().addComment(
        widget.postId,
        widget.currentUid,
        _textValueComment,
        _firstName,
        _lastName,
        _profilePicture,
      );
      if (widget.currentUid != widget.postOwnerUid) {
        OurBaseStore().addCommentNotification(
          widget.currentUid,
          widget.postId,
          widget.firstPostPicture,
          widget.postOwnerUid,
          _textValueComment,
        );
      }
      _commentController.clear();
      _updateComments();
    }
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         Widget - all the comments from the post

  Description:    Displays loading until all the data is received and then once it is
                  received, show the comments. If there are no comments display a message and also enable
                  refreshing on pull down. As you scroll more comments will be loaded in
  ---------------------------------------------------------------------------------------------------*/
  Widget _allComments() {
    Widget retVal;
    if (_comments.length == null) {
      return Center(
        child: Text("loading..."),
      );
    } else {
      retVal = NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if ((scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) &&
              !_scrollPending &&
              !_atTheBottom) {
            _addToComments();
            _scrollPending = true;
            SnackBar _snackbar = SnackBar(
              backgroundColor: Theme.of(context).cardColor,
              behavior: SnackBarBehavior.floating,
              content: Container(
                child: Text(
                  "loading more comments...",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
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
            await _updateComments();
            return;
          },
          child: (_comments.length == 0)
              ? Center(
                  child: Text("no comments found :("),
                )
              : ListView.builder(
                  itemCount: _comments.length,
                  itemBuilder: (BuildContext context, int index) {
                    return OurEachComment(
                      documentSnapshot: _comments[index],
                    );
                  },
                ),
        ),
      );
    }
    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         Widget - A way for the user to submit a comment

  Description:    Shows a textfield to enter a comment and a button to submit that comment
  ---------------------------------------------------------------------------------------------------*/
  Widget _displayAddComment() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.white38,
            blurRadius: 5.0, // has the effect of softening the shadow
            offset: Offset(
              0.0, // horizontal, move right 10
              2.0, // vertical, move down 10
            ),
          )
        ],
      ),
      child: Row(
        children: <Widget>[
          Flexible(
            child: Container(
              padding: EdgeInsets.only(left: 10.0, top: 25.0),
              child: TextField(
                controller: _commentController,
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                minLines: 1,
                decoration: InputDecoration.collapsed(hintText: "add comment here..."),
                textCapitalization: TextCapitalization.sentences,
                maxLength: 2000,
              ),
            ),
          ),
          FlatButton(
            child: Text("submit"),
            textColor: Theme.of(context).accentColor,
            onPressed: () => _addComment(),
          ),
        ],
      ),
    );
  }

  /*---------------------------------------------------------------------------------------------------
  Description:    Display all the comments for that post, with the commentors name. Before it loads it will
                  show the loading screen. Also you can add more comments at the bottom.
  ---------------------------------------------------------------------------------------------------*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "comments",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: _allComments(),
          ),
          _displayAddComment(),
        ],
      ),
    );
  }
}
