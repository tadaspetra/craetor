import 'package:craetor/screens/login/forgotPassword.dart';
import 'package:craetor/screens/signup/signup.dart';
import 'package:flutter/material.dart';
import 'package:craetor/screens/login/local_widgets/loginForm.dart';

class OurLogin extends StatelessWidget {
  final Function(String) onSignedIn;
  OurLogin({
    this.onSignedIn,
  });
  static const String routeName = 'login';
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
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: _screenWidth * .5,
                margin: EdgeInsets.only(top: 160),
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
              child: OurLoginForm(
                onSignedIn: onSignedIn,
              ),
            ),
            FlatButton(
              padding: EdgeInsets.only(top: 10.0),
              textColor: Theme.of(context).accentColor,
              child: Text("forgot password? click here"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OurForgotPassword(),
                  ),
                );
              },
            ),
            SizedBox(
              height: 80.0,
            ),
            FlatButton(
              padding: EdgeInsets.only(bottom: 20.0),
              textColor: Theme.of(context).accentColor,
              key: Key("signupButton"),
              child: Text("don't have an account? click here"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OurSignup(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
