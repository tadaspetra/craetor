import 'package:flutter/material.dart';

//In order to be able to switch up themes live, you will most likely have to call up the parent context
//and then reload that context.

class OurSimpleTheme {
  String _globalFontFamily = 'Manjari';

  Color _lightPrimaryColor = Colors.lightBlue;
  Color _lightAccentColor = Color.fromARGB(255, 187, 153, 255);

  ThemeData buildLightTheme() {
    return ThemeData(
      fontFamily: _globalFontFamily,
      brightness: Brightness.light,
      accentColorBrightness: Brightness.light,
      accentColor: _lightAccentColor,
      buttonTheme: ButtonThemeData(
        buttonColor: _lightAccentColor,
        textTheme: ButtonTextTheme.normal,
      ),
      appBarTheme: AppBarTheme(
        color: _lightPrimaryColor,
      ),
    );
  }

  Color _darkPrimaryColor = Colors.black;

  //Color _darkAccentColor = Color.fromARGB(255, 187, 153, 255); //lighter one
  Color _darkAccentColorv2 = Color.fromARGB(255, 187, 134, 252); //used on material design website
  Color _darkAccentColorv3 = Colors.purpleAccent[100];

  Color _secondaryHeaderColor = Colors.grey[600];
  Color _cardColor = Colors.grey[850];

  ThemeData buildDarkTheme() {
    return ThemeData(
      fontFamily: _globalFontFamily,
      brightness: Brightness.dark,
      accentColorBrightness: Brightness.dark,
      canvasColor: Colors.black,
      accentColor: _darkAccentColorv3,
      secondaryHeaderColor: _secondaryHeaderColor,
      highlightColor: Colors.transparent,
      cardColor: _cardColor,
      toggleableActiveColor: _darkAccentColorv3,
      buttonTheme: ButtonThemeData(
        buttonColor: _darkAccentColorv2,
        textTheme: ButtonTextTheme.normal,
      ),
      appBarTheme: AppBarTheme(
        color: _darkPrimaryColor,
      ),
    );
  }
}
