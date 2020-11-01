import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:craetor/services/firebase/authProvider.dart';
import 'package:craetor/services/firebase/baseStore.dart';
import 'package:flutter/material.dart';

class OurSettings extends StatefulWidget {
  @override
  _OurSettingsState createState() => _OurSettingsState();
}

class _OurSettingsState extends State<OurSettings> {
  bool notificationsSwitch = false;
  String currentUid = "";

  /*---------------------------------------------------------------------------------------------------
  Inputs:         value - on or off position of the switch
  
  Return:         None

  Description:    If switch is in on position, the token will be added to the users tokens, so they can
                  receive notifications. If it is in the off position, the user will no longer receive
                  notifications.
  ---------------------------------------------------------------------------------------------------*/
  void _switchChanged(bool value) {
    if (value) {
      OurBaseStore().addToken(currentUid);
    } else {
      OurBaseStore().removeToken(currentUid, false);
    }
    setState(() {
      notificationsSwitch = value;
    });
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         None

  Description:    During initialization or when dependencies change we need to check if there is already
                  a token stored for this device, and set the switch to correct state.
  ---------------------------------------------------------------------------------------------------*/
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    var auth = OurAuthProvider.of(context).auth;
    auth.getCurrentUser().then((user) async {
      currentUid = user.uid;
      DocumentSnapshot _currentToken = await OurBaseStore().getToken(user.uid);
      if (_currentToken.exists) {
        setState(() {
          notificationsSwitch = true;
        });
      }
    });
  }

  /*---------------------------------------------------------------------------------------------------
  Description:    A list of settings in a column that can be adjusted.
  ---------------------------------------------------------------------------------------------------*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "settings",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      "allow notifications on this device",
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                  ),
                ),
                Switch(
                  value: notificationsSwitch,
                  onChanged: (bool value) {
                    _switchChanged(value);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
