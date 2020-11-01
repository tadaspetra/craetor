import 'dart:io';

import 'package:craetor/services/firebase/authProvider.dart';
import 'package:craetor/services/firebase/baseStore.dart';
import 'package:craetor/utils/navigation/mainApp.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:craetor/screens/login/login.dart';

enum AuthStatus { notSignedIn, signedIn }

class OurRoot extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OurRootState();
}

class _OurRootState extends State<OurRoot> {
  AuthStatus _authStatus = AuthStatus.notSignedIn;
  bool _notification = false;
  String currentUid;

  final FirebaseMessaging _fcm = FirebaseMessaging();

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         None

  Description:    Set up notifications for the user. They only set the notification flag when there is
                  a notification
  ---------------------------------------------------------------------------------------------------*/
  @override
  void initState() {
    super.initState();

    if (Platform.isIOS) {
      _fcm.requestNotificationPermissions(IosNotificationSettings());
      _fcm.onIosSettingsRegistered.listen((settings) {
        //print("settings registered: $settings");
      });
    }
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        //print("onMessage: $message");
        setState(() {
          _notification = true;
        });
      },
      onLaunch: (Map<String, dynamic> message) async {
        //print("onLaunch: $message");
        setState(() {
          _notification = true;
        });
      },
      onResume: (Map<String, dynamic> message) async {
        //print("onResume: $message");
        setState(() {
          _notification = true;
        });
      },
    );
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         None

  Description:    Gets the auth state of the user, and sets the local status to whichever option applies
  ---------------------------------------------------------------------------------------------------*/
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    var auth = OurAuthProvider.of(context).auth;
    bool isEmailVerified = await auth.isEmailVerified();
    auth.getCurrentUser().then((user) {
      setState(() {
        try {
          //Need to check if the email is verified before letting log in
          if (user?.uid == null || !isEmailVerified) {
            _authStatus = AuthStatus.notSignedIn;
          } else {
            _authStatus = AuthStatus.signedIn;
          }
        } catch (e) {
          print(e);
        }
      });
    });
  }

  void _signedIn(String uid) {
    setState(() {
      _authStatus = AuthStatus.signedIn;
    });
    OurBaseStore().getUserInformation(uid).then((user) {
      if (user.data["receivesNotifications"]) {
        OurBaseStore().addToken(uid);
      }
    });
  }

  void _signedOut(String uid) {
    setState(() {
      _authStatus = AuthStatus.notSignedIn;
      OurBaseStore().removeToken(uid, true);
    });
  }

  void _clearNotification() {
    setState(() {
      _notification = false;
    });
  }

  /*---------------------------------------------------------------------------------------------------
  Description:    If user is not logged in, go to login page, if they are logged in and verified go
                  to the Main app
  ---------------------------------------------------------------------------------------------------*/
  @override
  Widget build(BuildContext context) {
    Widget returnWidget;
    switch (_authStatus) {
      case AuthStatus.notSignedIn:
        returnWidget = OurLogin(
          onSignedIn: _signedIn,
        );
        break;
      case AuthStatus.signedIn:
        returnWidget = OurMainApp(
          onSignedOut: _signedOut,
          notification: _notification,
          onNotificationCleared: _clearNotification,
        );
        break;
    }
    return returnWidget;
  }
}
