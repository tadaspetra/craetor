import 'dart:async';

import 'package:craetor/screens/root/root.dart';
import 'package:craetor/services/firebase/authProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:craetor/widgets/texts/textFormField.dart';
import 'package:craetor/utils/validation/formFieldValidator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:craetor/services/firebase/baseStore.dart';

//models
import 'package:craetor/models/userData.dart';

class OurSignupForm extends StatefulWidget {
  static const String routeName = 'signupform';
  State<StatefulWidget> createState() => OurSignupFormState();
}

class OurSignupFormState extends State<OurSignupForm> {
  OurFormFieldValidator validate = OurFormFieldValidator();
  OurUserData currentUser = OurUserData();
  final _formKeySign = GlobalKey<FormState>();
  static TextEditingController firstNameController = TextEditingController();
  static TextEditingController lastNameController = TextEditingController();
  static TextEditingController emailController = TextEditingController();
  static TextEditingController passController = TextEditingController();
  static TextEditingController reenteredPassController = TextEditingController();
  String get _textValueFirstName => firstNameController.text;
  String get _textValueLastName => lastNameController.text;
  String get _textValueEmail => emailController.text;
  String get _textValuePass => passController.text;
  String get _textValueReenteredPass => reenteredPassController.text;

  /*---------------------------------------------------------------------------------------------------
  Inputs:         context - the context that we are currently in
  
  Return:         None
  
  Description:    Checks that the values were all validated, that the passwords match, and then creates
                  a user on firebase authentication, and sends an email to be authenticated. The other
                  information that has been inputted is stored in firestore to be referenced later
  ---------------------------------------------------------------------------------------------------*/
  void _authenticate(BuildContext context) async {
    if (_formKeySign.currentState.validate()) {
      if (_textValuePass == _textValueReenteredPass) {
        var auth = OurAuthProvider.of(context).auth;
        FirebaseUser user = await auth.createUser(_textValueEmail, _textValuePass);
        if (user != null) {
          currentUser.firstName = _textValueFirstName.trim();
          currentUser.lastName = _textValueLastName.trim();
          currentUser.email = user.email.trim();
          currentUser.profilePicture =
              "https://firebasestorage.googleapis.com/v0/b/craetor.appspot.com/o/usericon.jpg?alt=media&token=f339987f-0ec9-4cb2-b9ab-fb2316e9266d";
          currentUser.uid = user.uid;
          OurBaseStore().addUserInformation(currentUser);
          final SnackBar snackBar = SnackBar(
            content: Text("Check email to verify account"),
          );
          Scaffold.of(context).showSnackBar(snackBar);
          Timer(Duration(seconds: 2), () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => OurRoot(),
              ),
              (Route<dynamic> route) => false,
            );
          });
        } else {
          //user was not create correctly
          setState(() {
            passController.clear();
            reenteredPassController.clear();
            final SnackBar snackBar = SnackBar(
              content: Text("Something went wrong with creating account. Try a different email."),
            );
            Scaffold.of(context).showSnackBar(snackBar);
          });
        }
      } else {
        setState(() {
          passController.clear();
          reenteredPassController.clear();
          final SnackBar snackBar = SnackBar(
            content: Text("Passwords do not match"),
          );
          Scaffold.of(context).showSnackBar(snackBar);
        });
      }
    } else {
      //do nothing -- what happens here??
    }
  }

  /*---------------------------------------------------------------------------------------------------
  Description:    Creates visual list of forms in which the user will enter information about themselves
                  After the button is clicked, the fields will all be validated
  ---------------------------------------------------------------------------------------------------*/
  Widget build(BuildContext context) {
    return Form(
      key: _formKeySign,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          OurTextFormField(
            icon: Icon(Icons.person_outline),
            controller: firstNameController,
            label: "Enter First Name",
            formValidator: (value) => validate.nameValidator(value.trim()),
          ),
          SizedBox(
            height: 10.0,
          ),
          OurTextFormField(
            icon: Icon(Icons.person_outline),
            controller: lastNameController,
            label: "Enter Last Name",
            formValidator: (value) => validate.nameValidator(value.trim()),
          ),
          SizedBox(
            height: 10.0,
          ),
          OurTextFormField(
            icon: Icon(Icons.email),
            controller: emailController,
            label: "Enter Email",
            formValidator: (value) => validate.signupEmailValidator(value.trim()),
          ),
          SizedBox(
            height: 10.0,
          ),
          OurTextFormField(
            icon: Icon(Icons.lock),
            controller: passController,
            label: "Enter Password",
            isPassword: true,
            formValidator: (value) => validate.signupPassValidator(value),
          ),
          SizedBox(
            height: 10.0,
          ),
          OurTextFormField(
            icon: Icon(Icons.lock_open),
            controller: reenteredPassController,
            label: "Re-enter Password",
            isPassword: true,
            formValidator: (value) => validate.signupReenteredPassValidator(value),
          ),
          SizedBox(
            height: 10.0,
          ),
          RaisedButton(
            key: Key("submitButton"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(80, 20, 80, 20),
              child: Text(
                "signup",
                style: TextStyle(fontSize: 18),
              ),
            ),
            onPressed: () => _authenticate(context),
          ),
          SizedBox(height: 40.0),
        ],
      ),
    );
  }
}
