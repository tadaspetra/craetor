import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:craetor/models/globals.dart';
import 'package:craetor/screens/profile/profile.dart';
import 'package:craetor/widgets/indicators/refreshIndicator.dart';
import 'package:craetor/widgets/post/eachPost.dart';
import 'package:flutter/material.dart';
import 'package:craetor/services/firebase/baseStore.dart';
import 'dart:async';

class OurDiscover extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OurDiscoverState();
}

class _OurDiscoverState extends State<OurDiscover> {
  List<DocumentSnapshot> _posts = List();
  static TextEditingController _searchController = TextEditingController();
  String dropdownValue = 'all categories';
  bool _inSearch = false;
  DocumentSnapshot _lastPost;
  bool _atTheBottom = false;
  bool _scrollPending = false;

  List<DocumentSnapshot> _searchResults;
  String _currentSearch;
  DocumentSnapshot _lastSearch;
  bool _atTheBottomSearch = false;
  bool _scrollPendingSearch = false;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    //This makes it so we have control of when the data is reloaded. If we don't do this
    //the FutureBuilder will execute whenever page is loaded. If he have a page above and
    //pop it off it will reload. When we have it updated this way we have control on reload

    _updateDiscover();
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         None
  
  Description:    A future used the refresh indicator
  ---------------------------------------------------------------------------------------------------*/
  Future<void> _updateDiscover() async {
    List<DocumentSnapshot> _templist = List();
    _scrollPending = true;
    if (dropdownValue == "all categories") {
      _templist = await OurBaseStore().getPosts();
    } else {
      _templist = await OurBaseStore().getPostsByCategory(dropdownValue);
    }
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
  
  Description:    A future used the scroll Bottom detection
  ---------------------------------------------------------------------------------------------------*/
  Future<void> _addToDiscover() async {
    List<DocumentSnapshot> _templist = List();
    if (dropdownValue == "all categories") {
      _templist = await OurBaseStore().getNextPosts(_lastPost);
    } else {
      _templist = await OurBaseStore().getNextPostsByCategory(dropdownValue, _lastPost);
    }
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
  Inputs:         fullName - the first and last name of the user
  
  Return:         None

  Description:    The fullName that was provided, will remove any spaces in the name, and return the search
                  results in the local list. Also set state to display the window for searching instead
                  of discovering
  ---------------------------------------------------------------------------------------------------*/
  void _handleSearch(String fullName) async {
    List<DocumentSnapshot> _temp = List();
    String searchName = fullName.replaceAll(RegExp(r"\s+\b|\b\s"), "");
    if (searchName != "") {
      _temp = await OurBaseStore().getSearchResults(searchName);
      _currentSearch = searchName;
      if (_temp.length < fSEARCHQUERYLENTH) {
        _atTheBottomSearch = true;
      } else {
        _lastSearch = _temp[fSEARCHQUERYLENTH - 1];
        _atTheBottomSearch = false;
      }
      setState(() {
        _searchResults = _temp;
        _inSearch = true;
        _scrollPendingSearch = false;
      });
    } else {
      setState(() {
        _inSearch = false;
      });
    }
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         None

  Description:    Using a future add to the search list as the user scrolls down. It uses the current
                  search. 
  ---------------------------------------------------------------------------------------------------*/
  void _addToSearch() async {
    List<DocumentSnapshot> _temp = List();
    if (_currentSearch != null && _currentSearch != "") {
      _temp = await OurBaseStore().getNextSearchResults(_currentSearch, _lastSearch);
      if (_temp.length < fSEARCHQUERYLENTH) {
        _atTheBottomSearch = true;
      } else {
        _lastSearch = _temp[fSEARCHQUERYLENTH - 1];
        _atTheBottomSearch = false;
      }
      setState(() {
        _searchResults.addAll(_temp);
        _inSearch = true;
        _scrollPendingSearch = false;
      });
    } else {
      setState(() {
        _inSearch = false;
      });
    }
  }

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
  
  Return:         Widget - A way for the user to submit a searhc request

  Description:    Shows a textfield to type in search request
  ---------------------------------------------------------------------------------------------------*/
  Widget _displaySearchBar() {
    return Container(
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
          Container(padding: EdgeInsets.all(10.0), child: Icon(Icons.search)),
          Flexible(
            child: Container(
              padding: EdgeInsets.only(left: 10.0, top: 5.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration.collapsed(hintText: "Search for users..."),
                onSubmitted: (String value) => _handleSearch(value),
              ),
            ),
          ),
          FlatButton(
            padding: EdgeInsets.only(top: 2.0),
            child: Text("search"),
            textColor: Theme.of(context).accentColor,
            onPressed: () => _handleSearch(_searchController.text),
          ),
        ],
      ),
    );
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         Widget - A widget that will be displayed right under the search bar, in the app bar

  Description:    Will either show a clear option to clear the search results, or it will show the categories
                  that the software supports
  ---------------------------------------------------------------------------------------------------*/
  Widget _dropDown() {
    Widget retVal;

    if (_inSearch) {
      retVal = FlatButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.clear),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 10.0),
              child: Text("clear results"),
            ),
          ],
        ),
        onPressed: () => {
          setState(() {
            _inSearch = false;
            _searchController.clear();
            _currentSearch = null;
          })
        },
      );
    } else {
      retVal = DropdownButton<String>(
        value: dropdownValue,
        underline: Container(
          height: 0,
          color: Theme.of(context).accentColor.withOpacity(.5),
        ),
        onChanged: (String newValue) {
          setState(() {
            dropdownValue = newValue;
            _updateDiscover();
          });
        },
        items: <String>[
          'all categories',
          'art',
          'cooking',
          'crafts',
          'design',
          'electronics',
          'fashion',
          'gardening',
          'home',
          'makeup',
          'mods',
          'photography',
          'refurbishing',
          'textile',
          'vehicles',
          'woodworking',
          '3D'
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: SizedBox(
              width: 200.0, // for example
              child: Text(value, textAlign: TextAlign.center),
            ),
          );
        }).toList(),
      );
    }
    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         Widget - A widget that will be displayed in the main part of the screen

  Description:    There are 3 main things that can get displayed here: all discover posts, category posts,
                  or user search results. For discover and category, you can refresh posts. For all 3 
                  as you scroll down more results will be added. 
  ---------------------------------------------------------------------------------------------------*/
  Widget _mainSection() {
    Widget retVal;

    if (_inSearch) {
      if (_searchResults.length == null) {
        return Center(
          child: Text("loading..."),
        );
      } else {
        retVal = NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
                !_scrollPendingSearch &&
                !_atTheBottomSearch) {
              _addToSearch();
              _scrollPendingSearch = true;
              SnackBar _snackbar = SnackBar(
                backgroundColor: Colors.black,
                content: Text(
                  "loading more users...",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
                duration: Duration(seconds: 1),
              );
              Scaffold.of(context).showSnackBar(_snackbar);
            }
            return true;
          },
          child: (_searchResults.length == 0)
              ? Center(
                  child: Text("no users found :("),
                )
              : ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () => _toProfile(_searchResults[index].documentID),
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
                            child: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(_searchResults[index]["profilePicture"]),
                              minRadius: 30.0,
                            ),
                          ),
                          Column(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  _searchResults[index]["firstName"] +
                                      " " +
                                      _searchResults[index]["lastName"],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                  ),
                                ),
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        );
      }
    } else {
      retVal = NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if ((scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) &&
              !_scrollPending &&
              !_atTheBottom) {
            _addToDiscover();
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
            await _updateDiscover();
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
                  of the posts displayed in our post format. If you pull down from the top the 
                  contents will refresh
  ---------------------------------------------------------------------------------------------------*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: _displaySearchBar(),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: _dropDown(),
        ),
      ),
      body: _mainSection(),
    );
  }
}
