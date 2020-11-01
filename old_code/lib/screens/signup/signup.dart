import 'package:flutter/material.dart';
import 'package:craetor/screens/signup/local_widgets/signupForm.dart';

class OurSignup extends StatelessWidget {
  static const String routeName = 'signup';
  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.centerLeft,
            colors: [
              Color.fromARGB(255, 84, 84, 84),
              Color.fromARGB(255, 0, 0, 0),
            ],
          ),
        ),
        child: ListView(
          children: <Widget>[
            IconButton(
              padding: EdgeInsets.all(20.0),
              alignment: Alignment.topLeft,
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: _screenWidth * .5,
                margin: EdgeInsets.only(top: 100),
                child: Image.asset(
                  "assets/logo_v4.png",
                ),
              ),
            ),
            SizedBox(
              height: 60.0,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: OurSignupForm(),
            ),
          ],
        ),
      ),
    );
  }
}
