import 'package:craetor/services/firebase/authProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:craetor/widgets/texts/textFormField.dart';
import 'package:craetor/utils/validation/formFieldValidator.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OurLoginForm extends StatefulWidget {
  final Function(String) onSignedIn;
  OurLoginForm({
    this.onSignedIn,
  });

  @override
  State<StatefulWidget> createState() => OurLoginFormState();
}

class OurLoginFormState extends State<OurLoginForm> {
  OurFormFieldValidator validate = OurFormFieldValidator();
  final _formKey = GlobalKey<FormState>();
  //VARIABLES FOR TESTING VALIDATION/AUTHENTICATION
  static TextEditingController emailController = TextEditingController();
  static TextEditingController passController = TextEditingController();
  String get _textValueEmail => emailController.text;
  String get _textValuePass => passController.text;
  var auth;

  /*---------------------------------------------------------------------------------------------------
  Inputs:         context - the context in which we are working in
  
  Return:         None

  Description:    We validate the information that is passed in, then try and sign in the user. If everything
                  is correct, we sign in. If not show user what is incorrect
  ---------------------------------------------------------------------------------------------------*/
  void _authenticate(BuildContext context) async {
    auth = OurAuthProvider.of(context).auth;
    if (_formKey.currentState.validate()) {
      FirebaseUser user = await auth.signIn(
        _textValueEmail.trim(),
        _textValuePass,
      );
      if (user != null) {
        if (await auth.isEmailVerified()) {
          widget.onSignedIn(user.uid);
          emailController.clear();
          passController.clear();
        } else {
          final SnackBar snackBar = SnackBar(
            content: Text("Need to Verify Email"),
          );
          Scaffold.of(context).showSnackBar(snackBar);
        }
      } else {
        setState(() {
          passController.clear();
          final SnackBar snackBar = SnackBar(
            content: Text("Invalid Password or email"),
          );
          Scaffold.of(context).showSnackBar(snackBar);
        });
      }
    } else {
      //do nothing
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          OurTextFormField(
            icon: Icon(Icons.email),
            controller: emailController,
            label: "Email",
            formValidator: (value) => validate.loginEmailValidator(value.trim()),
          ),
          SizedBox(
            height: 20.0,
          ),
          OurTextFormField(
            icon: Icon(Icons.lock),
            controller: passController,
            label: "Password",
            isPassword: true,
            formValidator: (value) => validate.loginPassValidator(value),
          ),
          SizedBox(
            height: 20.0,
          ),
          Container(
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
                padding: const EdgeInsets.fromLTRB(80, 20, 80, 20),
                child: Text(
                  "login",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              onPressed: () => _authenticate(context),
            ),
          ),
        ],
      ),
    );
  }
}
