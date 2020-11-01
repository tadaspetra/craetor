import 'dart:async';

import 'package:craetor/services/firebase/authProvider.dart';
import 'package:craetor/widgets/texts/textFormField.dart';
import 'package:flutter/material.dart';
import 'package:craetor/utils/validation/formFieldValidator.dart';

class OurForgotPassword extends StatefulWidget {
  static const String routeName = 'forgotPassword';

  @override
  _OurForgotPasswordState createState() => _OurForgotPasswordState();
}

class _OurForgotPasswordState extends State<OurForgotPassword> {
  static TextEditingController emailController = TextEditingController();
  final _formKey2 = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _authenticate(BuildContext context) async {
    if (_formKey2.currentState.validate()) {
      var auth = OurAuthProvider.of(context).auth;
      if (await auth.sendPasswordResetEmail(emailController.text)) {
        final SnackBar snackBar = SnackBar(
          content: Text("check email to reset password"),
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
        Timer(Duration(seconds: 2), () {
          Navigator.pop(context);
          emailController.clear();
        });
      } else {
        final SnackBar snackBar = SnackBar(
          content: Text("make sure you entered a correct email"),
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
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
        child: Form(
          key: _formKey2,
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
                child: OurTextFormField(
                  icon: Icon(Icons.email),
                  controller: emailController,
                  label: "Enter account email",
                  formValidator: (value) =>
                      OurFormFieldValidator().loginEmailValidator(value.trim()),
                ),
              ),
              SizedBox(height: 60.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 120.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white38,
                        blurRadius: 5.0, // has the effect of softening the shadow
                        offset: Offset(
                          0.0, // horizontal, move right 10
                          2.0, // vertical, move down 10
                        ),
                      )
                    ],
                  ),
                  child: RaisedButton(
                    key: Key("loginButton"),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: Text(
                        "submit",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    onPressed: () {
                      _authenticate(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
