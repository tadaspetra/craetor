import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

//This class was created to not give a warning for a null return
class MyRefreshIndicator extends StatefulWidget {
  const MyRefreshIndicator({
    Key key,
    @required this.child,
    this.displacement: 40.0,
    @required this.onRefresh,
    this.color,
    this.backgroundColor,
    this.notificationPredicate: defaultScrollNotificationPredicate,
  })  : assert(child != null),
        assert(onRefresh != null),
        assert(notificationPredicate != null),
        super(key: key);

  final Widget child;

  final double displacement;

  final RefreshCallback onRefresh;

  final Color color;

  final Color backgroundColor;

  final ScrollNotificationPredicate notificationPredicate;

  @override
  State<StatefulWidget> createState() {
    return MyRefreshIndicatorState();
  }
}

class MyRefreshIndicatorState extends State<MyRefreshIndicator> with WidgetsBindingObserver {
  Completer<Null> completer;
  bool foreground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    foreground = (state == AppLifecycleState.resumed);
    if (foreground && completer != null) {
      //debugPrint("complete on didChangeAppLifecycleState");
      completer.complete();
      completer = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      child: widget.child,
      onRefresh: _onRefresh,
      displacement: widget.displacement,
      color: widget.color,
      backgroundColor: widget.backgroundColor,
      notificationPredicate: widget.notificationPredicate,
    );
  }

  Future<Null> _onRefresh() {
    final Completer<Null> completer = Completer<Null>();
    widget.onRefresh().then((_) {
      if (foreground) {
        //debugPrint("complete on original future");
        completer.complete();
      } else {
        this.completer = completer;
      }
    });
    return completer.future;
  }
}
