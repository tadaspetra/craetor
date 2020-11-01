import 'package:craetor/screens/accountInfo/local_widgets/accountInfoForm.dart';
import 'package:craetor/utils/image.dart';
import 'package:flutter/material.dart';
import 'package:craetor/services/firebase/authProvider.dart';
import 'package:craetor/services/firebase/baseStore.dart';
import 'package:craetor/models/userData.dart';

class OurAccountInfo extends StatefulWidget {
  @override
  _OurAccountInfoState createState() => _OurAccountInfoState();
}

class _OurAccountInfoState extends State<OurAccountInfo> {
  OurUserData _userData = OurUserData();

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         None

  Description:    Initializes the user's data values and sets the controller's text to each specific
                  field it applies to
  ---------------------------------------------------------------------------------------------------*/
  void didChangeDependencies() {
    super.didChangeDependencies();
    var auth = OurAuthProvider.of(context).auth;
    auth.getCurrentUser().then((user) {
      OurBaseStore().getUserInformation(user.uid).then((user) {
        if (this.mounted) {
          setState(() {
            _userData.profilePicture = user.data["profilePicture"];
          });
        }
      });
      _userData.uid = user.uid;
    });
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         None

  Description:    Open's gallery for the user to select an image that will update the users profile
              
  ---------------------------------------------------------------------------------------------------*/
  Future<void> _updateProfilePicture() async {
    OurImage().getImage(source: true, circle: true).then((data) async {
      try {
        OurBaseStore().updateUserProfilePic(data, _userData.uid).then((picPath) {
          setState(() {
            _userData.profilePicture = picPath;
            didChangeDependencies(); // This is so that the posts get reloaded with the new profile picture
          });
        });
      } catch (e) {
        //print(e);
      }
    });
  }

  /*---------------------------------------------------------------------------------------------------
  Description:    Scaffold containing TextFormFields that the user can edit and submit to firebase   
  ---------------------------------------------------------------------------------------------------*/
  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    bool everythingLoaded = (_userData.profilePicture == null);
    return Scaffold(
      body: ListView(
        children: <Widget>[
          IconButton(
            padding: EdgeInsets.all(20.0),
            alignment: Alignment.topLeft,
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(10.0),
                child: GestureDetector(
                  onTap: _updateProfilePicture,
                  child: CircleAvatar(
                    backgroundImage: everythingLoaded
                        ? AssetImage("assets/usericon.png")
                        : NetworkImage(_userData.profilePicture),
                    radius: _screenWidth * .2,
                    child: Container(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        color: Colors.black.withOpacity(.6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "change",
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
                ),
              ),
            ],
          ),
          OurAccountInfoForm(),
        ],
      ),
    );
  }
}
