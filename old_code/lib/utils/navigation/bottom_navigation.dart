import 'package:flutter/material.dart';

enum OurTabItem {
  feed,
  discover,
  create,
  notifications,
  menu,
}

class OurTabHelper {
  /*---------------------------------------------------------------------------------------------------
  Inputs:         index - which tab is being referred to
  
  Return:         TabItem - the TabItem correlating to the index

  Description:    Returns TabItem correlating to index
  ---------------------------------------------------------------------------------------------------*/
  static OurTabItem item({int index}) {
    switch (index) {
      case 0:
        return OurTabItem.feed;
      case 1:
        return OurTabItem.discover;
      case 2:
        return OurTabItem.create;
      case 3:
        return OurTabItem.notifications;
      case 4:
        return OurTabItem.menu;
    }
    return OurTabItem.feed;
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         tabItem - which tab is being referred to
  
  Return:         String - the name of the correlating tabItem

  Description:    Returns the name of the correlating tabItem
  ---------------------------------------------------------------------------------------------------*/
  static String description(OurTabItem tabItem) {
    switch (tabItem) {
      case OurTabItem.feed:
        return 'feed';
      case OurTabItem.discover:
        return 'discover';
      case OurTabItem.create:
        return 'create';
      case OurTabItem.notifications:
        return 'notifications';
      case OurTabItem.menu:
        return 'menu';
    }
    return '';
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         tabItem - which tab is being referred to
  
  Return:         IconData - the icon of the correlating tabItem

  Description:    Returns the icon of the correlating tabItem
  ---------------------------------------------------------------------------------------------------*/
  static IconData icon(OurTabItem tabItem) {
    switch (tabItem) {
      case OurTabItem.feed:
        return Icons.home;
      case OurTabItem.discover:
        return Icons.search;
      case OurTabItem.create:
        return Icons.add;
      case OurTabItem.notifications:
        return Icons.notifications;
      case OurTabItem.menu:
        return Icons.menu;
    }
    return Icons.layers;
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         tabItem - which tab is being referred to
  
  Return:         MaterialColor - the color for the correlating tabItem

  Description:    Returns the color for the correlating tabItem
  ---------------------------------------------------------------------------------------------------*/
  static Color color(OurTabItem tabItem, BuildContext context) {
    return Theme.of(context).accentColor;
  }
}

class OurBottomNavigation extends StatelessWidget {
  final OurTabItem currentTab;
  final ValueChanged<OurTabItem> onSelectTab;
  final bool notification;
  OurBottomNavigation({
    this.currentTab,
    this.onSelectTab,
    this.notification,
  });

  /*---------------------------------------------------------------------------------------------------
  Inputs:         tabItem - which tab is being referred to
  
  Return:         Color - the name of the correlating tabItem

  Description:    Returns the name of the correlating tabItem if its the current tab, and grey if 
                  it's not the current tab
  ---------------------------------------------------------------------------------------------------*/
  Color _colorTabMatching({OurTabItem item, BuildContext context}) {
    if (item == OurTabItem.notifications && notification) {
      return Colors.orange;
    } else {
      return currentTab == item ? OurTabHelper.color(item, context) : Colors.grey;
    }
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         tabItem - which tab is being referred to
  
  Return:         BottomNavigationBarItem - essentially all the items inside the tab

  Description:    Returns the icon and text for each customized tab
  ---------------------------------------------------------------------------------------------------*/
  BottomNavigationBarItem _buildItem({OurTabItem tabItem, BuildContext context}) {
    IconData icon = OurTabHelper.icon(tabItem);
    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        color: _colorTabMatching(item: tabItem, context: context),
      ),
      title: Text(""),
    );
  }

  /*---------------------------------------------------------------------------------------------------
  Description:    Displays the BottomNavigationBar with all the tab contents that are in there. When a tab
                  is clicked returns a callback to MainApp, that will move to the correct screen, but the
                  tab color and tab things are updated in this file
  ---------------------------------------------------------------------------------------------------*/
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Theme(
        data: Theme.of(context).copyWith(splashColor: Colors.transparent),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: [
            _buildItem(tabItem: OurTabItem.feed, context: context),
            _buildItem(tabItem: OurTabItem.discover, context: context),
            _buildItem(tabItem: OurTabItem.create, context: context),
            _buildItem(tabItem: OurTabItem.notifications, context: context),
            _buildItem(tabItem: OurTabItem.menu, context: context),
          ],
          onTap: (index) => onSelectTab(
            OurTabHelper.item(index: index),
          ),
        ),
      ),
    );
  }
}
