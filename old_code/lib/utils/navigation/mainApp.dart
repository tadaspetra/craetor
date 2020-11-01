import 'package:craetor/utils/navigation/bottom_navigation.dart';
import 'package:craetor/utils/navigation/tab_navigator.dart';
import 'package:flutter/material.dart';

import 'bottom_navigation.dart';

//Implementation found: https://github.com/bizz84/nested-navigation-demo-flutter/tree/master/lib
//Some implementations have been removed from this repo. In the navigator(_routeBuilders) we just return a widget,
//instead of a Map with widget builder, also Offstage functionality removed. As well as other smaller things

class OurMainApp extends StatefulWidget {
  final Function(String) onSignedOut;
  final bool notification;
  final VoidCallback onNotificationCleared;
  OurMainApp({
    this.onSignedOut,
    this.notification,
    this.onNotificationCleared,
  });
  @override
  State<StatefulWidget> createState() => _OurMainAppState();
}

class _OurMainAppState extends State<OurMainApp> {
  OurTabItem currentTab = OurTabItem.feed;

  //Global Keys necessary to keep the state of each tab
  Map<OurTabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    OurTabItem.feed: GlobalKey<NavigatorState>(),
    OurTabItem.discover: GlobalKey<NavigatorState>(),
    OurTabItem.create: GlobalKey<NavigatorState>(),
    OurTabItem.notifications: GlobalKey<NavigatorState>(),
    OurTabItem.menu: GlobalKey<NavigatorState>(),
  };

  /*---------------------------------------------------------------------------------------------------
  Inputs:         tabItem - which tab was selected from bottom navigation bar
  
  Return:         None

  Description:    This rebuilds the widgets as well as sets the current tab to the one that was selected
  ---------------------------------------------------------------------------------------------------*/
  void _selectTab(OurTabItem tabItem) {
    setState(() {
      currentTab = tabItem;
      if (currentTab == OurTabItem.notifications) {
        widget.onNotificationCleared();
      }
    });
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         tabItem - which tab was selected from bottom navigation bar
  
  Return:         Widget -  The remaining part of the screen

  Description:    Calls the TabNavigator to display the selected screen in the remaining
                  space, that is not occupied by bottom navigation bar
  ---------------------------------------------------------------------------------------------------*/
  Widget _buildNavigator(OurTabItem tabItem) {
    return OurTabNavigator(
      navigatorKey: navigatorKeys[tabItem],
      tabItem: tabItem,
      onSignedOut: widget.onSignedOut,
    );
    // Return below for offstage. It means shit get loaded in the background.
    //    also would need to uncomment the Stack above
    //
    // Offstage(
    //   offstage: currentTab != tabItem,
    //   child: TabNavigator(
    //     navigatorKey: navigatorKeys[tabItem],
    //     tabItem: tabItem,
    //     auth: widget.auth,
    //   ),
    // );
  }

  Widget _buildBottomNavigationBar(OurTabItem tabItem) {
    Widget retVal;
    if (tabItem == OurTabItem.create) {
      //dont show it
    } else {
      retVal = OurBottomNavigation(
        currentTab: currentTab,
        onSelectTab: _selectTab,
        notification: widget.notification,
      );
    }
    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
  Description:    This build displays one bottom navigation bar that will be used across the whole app.
                  The build Navigator will be the actual content displayed on the screen. The WillPopScope
                  is used so that if back is clicked while on a tab it will exit the app. This is equivalent
                  to PushAndRemoveUntil for every tab. But since its not a whole page this is an easier
                  implementation.
  ---------------------------------------------------------------------------------------------------*/
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !await navigatorKeys[currentTab].currentState.maybePop(),
      child: Scaffold(
        body: _buildNavigator(currentTab),
        // This is explained in the _buildNavigator function comments
        // Stack(children: <Widget>[
        //   _buildOffstageNavigator(TabItem.red),
        //   _buildOffstageNavigator(TabItem.green),
        //   _buildOffstageNavigator(TabItem.blue),
        // ]),
        bottomNavigationBar: _buildBottomNavigationBar(currentTab),
      ),
    );
  }
}
