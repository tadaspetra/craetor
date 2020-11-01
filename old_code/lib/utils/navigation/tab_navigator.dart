import 'package:craetor/screens/create/create.dart';
import 'package:craetor/screens/discover/discover.dart';
import 'package:craetor/screens/feed/feed.dart';
import 'package:craetor/screens/notifications/notifications.dart';
import 'package:craetor/screens/menu/menu.dart';
import 'package:flutter/material.dart';
import 'package:craetor/utils/navigation/bottom_navigation.dart';

class OurTabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final OurTabItem tabItem;
  final Function(String) onSignedOut;

  OurTabNavigator({
    this.navigatorKey,
    this.tabItem,
    this.onSignedOut,
  });

  //*******************This might be necessary for going to a different screen inside the tab
  //*******************For example if you click on someones username, you should go to their page
  // void _push(BuildContext context, {int materialIndex: 500}) {
  //   var routeBuilders = _routeBuilders(context, tabItem);

  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => routeBuilders[TabNavigatorRoutes.detail](context),
  //     ),
  //   );
  // }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         tabItem - which tab was selected
  
  Return:         Widget - which screen is going to be created 

  Description:    Returns the screens that are associated with the tabs.
  ---------------------------------------------------------------------------------------------------*/
  Widget _routeBuilders(OurTabItem tabItem) {
    switch (tabItem) {
      case OurTabItem.feed:
        return OurFeed();
        break;
      case OurTabItem.discover:
        return OurDiscover();
        break;
      case OurTabItem.create:
        return OurCreate();
        break;
      case OurTabItem.notifications:
        return OurNotifications();
        break;
      case OurTabItem.menu:
        return OurMenu(onSignedOut: onSignedOut);
        break;
      default:
        return OurFeed();
    }
  }

  /*---------------------------------------------------------------------------------------------------
  Description:    Returns the Navigator with the correct screen that is selected.
  ---------------------------------------------------------------------------------------------------*/
  @override
  Widget build(BuildContext context) {
    var routeBuilders = _routeBuilders(tabItem);

    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => routeBuilders,
        );
      },
    );
  }
}
