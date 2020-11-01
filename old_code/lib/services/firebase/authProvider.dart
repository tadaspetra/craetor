import 'package:craetor/services/firebase/baseAuth.dart';
import 'package:flutter/material.dart';

class OurAuthProvider extends InheritedWidget {
  final OurBaseAuth auth;

  OurAuthProvider({
    Key key,
    Widget child,
    this.auth,
  }) : super(
          key: key,
          child: child,
        );

  /*---------------------------------------------------------------------------------------------------
  Inputs:         oldWidget - the previous inheritedWidget state. That has the previous auth state
  
  Return:         bool - whether or not the inherted widget needs to be notified of an auth change

  Description:    Returns true
  ---------------------------------------------------------------------------------------------------*/
  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

/*---------------------------------------------------------------------------------------------------
  Inputs:         context - the current build context that you are calling it from
  
  Return:         AuthProvider - returns the object that you are trying to inherit

  Description:    This function allows access to the BaseAuth object wherever it is called
  ---------------------------------------------------------------------------------------------------*/
  static OurAuthProvider of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<OurAuthProvider>());
  }
}
