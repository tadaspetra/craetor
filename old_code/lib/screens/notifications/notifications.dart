import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:craetor/screens/notifications/local_widgets/eachNotification.dart';
import 'package:craetor/services/firebase/authProvider.dart';
import 'package:craetor/services/firebase/baseStore.dart';
import 'package:craetor/widgets/indicators/refreshIndicator.dart';
import 'package:flutter/material.dart';

class OurNotifications extends StatefulWidget {
  @override
  _OurNotificationsState createState() => _OurNotificationsState();
}

class _OurNotificationsState extends State<OurNotifications> {
  List<DocumentSnapshot> _notifications = List();

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         None
  
  Description:    Alternative to initState, Load in the notifications from the users notification collection
  ---------------------------------------------------------------------------------------------------*/
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateNotifications();
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         None
  
  Description:    A future used the refresh indicator
  ---------------------------------------------------------------------------------------------------*/
  Future<void> _updateNotifications() async {
    List<DocumentSnapshot> _templist = List();

    var auth = OurAuthProvider.of(context).auth;
    auth.getCurrentUser().then((user) async {
      _templist = await OurBaseStore().getNotifications(user.uid);

      setState(() {
        _notifications = _templist;
      });
    });
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         None
  
  Return:         Widget - returns a list of notifications

  Description:    Return the notifications, and have capability of refreshings
  ---------------------------------------------------------------------------------------------------*/

  Widget _displayNotifications() {
    Widget retVal;
    if (_notifications.length == null) {
      return Center(
        child: Text("loading..."),
      );
    } else {
      retVal = MyRefreshIndicator(
        onRefresh: () async {
          await _updateNotifications();
          return;
        },
        child: (_notifications.length == 0)
            ? Center(
                child: Text("no notifcations found :("),
              )
            : ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (BuildContext context, int index) {
                  return OurEachNotification(
                    notificationInfo: _notifications[index],
                  );
                },
              ),
      );
    }
    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
  Description:    Using a future builder, builds a list of notification tiles, once the data is collected.
                  If pulled down from the top the contents will refresh
  ---------------------------------------------------------------------------------------------------*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "notifications",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: _displayNotifications(),
    );
  }
}
