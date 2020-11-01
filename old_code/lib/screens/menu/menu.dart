import 'package:craetor/screens/contactUs/contactUs.dart';
import 'package:craetor/screens/settings/settings.dart';
import 'package:craetor/screens/terms/terms.dart';
import 'package:flutter/material.dart';
import 'package:craetor/services/firebase/authProvider.dart';
import 'package:craetor/services/firebase/baseStore.dart';
import 'package:craetor/screens/profile/profile.dart';

class OurMenu extends StatefulWidget {
  final Function(String) onSignedOut;
  OurMenu({
    this.onSignedOut,
  });
  @override
  State<StatefulWidget> createState() => _OurMenuState();
}

class _OurMenuState extends State<OurMenu> {
  String username = "loading";
  String profilePic = "";
  String uid;
  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         None

  Description:    Retrieves the user's data used on initialization of the menu screen
  ---------------------------------------------------------------------------------------------------*/
  void didChangeDependencies() {
    super.didChangeDependencies();
    var auth = OurAuthProvider.of(context).auth;
    auth.getCurrentUser().then((user) {
      uid = user.uid;
      OurBaseStore().getUserInformation(user.uid).then((user) {
        if (this.mounted) {
          setState(() {
            username = user.data["firstName"] + " " + user.data["lastName"];
            profilePic = user.data["profilePicture"];
          });
        }
      });
    });
  }

  void _goToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OurSettings(),
      ),
    );
  }

  void _goToTerms() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OurTerms(),
      ),
    );
  }

  void _goToContactUs() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OurContactUs(),
      ),
    );
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         context - the context that we are currently in
  
  Return:         None

  Description:    Whenever the signout button is pressed the auth signs the user out then makes a
                  callback to the Root page to lead the user back to the login screen
  ---------------------------------------------------------------------------------------------------*/
  void _signOut(BuildContext context) async {
    try {
      var auth = OurAuthProvider.of(context).auth;
      await auth.signOut();
      widget.onSignedOut(uid);
    } catch (e) {
      //print("hello $e");
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
  
  Return:         Widget- items in the row to symbolize the person's profile to access

  Description:    Displays a row wrapped in a GestureDetector with items such as the person's avatar,
                  their name, and text notifying to view the profile. Tapping anyhwere in this Row will
                  navigate to Profile screen
  ---------------------------------------------------------------------------------------------------*/
  Widget _displayProfileEntrance() {
    bool everythingLoaded = ((profilePic == null) || (username == null) || profilePic.isEmpty);
    Widget retVal;
    retVal = GestureDetector(
      onTap: () => _toProfile(uid),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.0),
                child: CircleAvatar(
                  backgroundImage: everythingLoaded
                      ? AssetImage("assets/usericon.png")
                      : NetworkImage(profilePic),
                  radius: 55.0,
                ),
              ),
              Expanded(
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      everythingLoaded
                          ? Text("loading", style: TextStyle(fontSize: 32.0))
                          : Text(username,
                              style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w700)),
                      SizedBox(height: 5.0),
                      Text(
                        "click to view profile",
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Theme.of(context).accentColor,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
  Description:    Scaffold containing enterance to the person's profile and other settings   
  ---------------------------------------------------------------------------------------------------*/
  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          "menu",
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_height * .20),
          child: Expanded(
            flex: 3,
            child: _displayProfileEntrance(),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: ListTile(
              contentPadding: EdgeInsets.all(10.0),
              leading: Icon(
                Icons.settings,
                size: 40.0,
              ),
              title: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  "settings",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
                ),
              ),
              onTap: () => _goToSettings(),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: ListTile(
              contentPadding: EdgeInsets.all(10.0),
              leading: Icon(
                Icons.insert_drive_file,
                size: 40.0,
              ),
              title: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  "terms & conditions",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
                ),
              ),
              onTap: () => _goToTerms(),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: ListTile(
              contentPadding: EdgeInsets.all(10.0),
              leading: Icon(
                Icons.email,
                size: 40.0,
              ),
              title: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  "contact developers",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
                ),
              ),
              onTap: () => _goToContactUs(),
            ),
          ),
          FlatButton(
            padding: EdgeInsets.symmetric(vertical: 40.0),
            child: Text(
              "- sign out -",
              style: TextStyle(fontSize: 18.0, color: Theme.of(context).accentColor),
            ),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
    );
  }
}
