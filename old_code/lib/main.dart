import 'package:craetor/services/firebase/authProvider.dart';
import 'package:flutter/material.dart';
import 'package:craetor/screens/root/root.dart';
import 'package:craetor/services/firebase/baseAuth.dart';
import 'package:craetor/utils/simpleTheme.dart';

import 'package:flutter/services.dart';

void main() => runApp(OurApp());

class OurApp extends StatelessWidget {
  /*---------------------------------------------------------------------------------------------------
  Description:    The entry point for the app. It is wrapped in an InheritedWidget called AuthProvider
                  that will let every module below access the auth state of the app. The actual MaterialApp
                  has an entry point of Root which will decide whether the user is already logged in or not.
                  There are also only two routes defined. This is because with the BottomNavigationBar that 
                  we are using throughout the app, it does not use routes. But we still want to use them
                  for the login process, since that will not have a BottomNavigationBar
  ---------------------------------------------------------------------------------------------------*/
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return OurAuthProvider(
      auth: OurAuth(),
      child: MaterialApp(
        title: "Craetor",
        debugShowCheckedModeBanner: false,
        theme: OurSimpleTheme().buildDarkTheme(),
        home: OurRoot(),
      ),
    );
  }
}
