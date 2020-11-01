import 'package:craetor/screens/login/local_widgets/loginForm.dart';
import 'package:craetor/screens/signup/local_widgets/signupForm.dart';
import 'package:flutter/material.dart';

class OurFormFieldValidator {
  TextEditingController _loginFormEmailController = OurLoginFormState.emailController;
  TextEditingController _loginFormPassController = OurLoginFormState.passController;
  TextEditingController _signupFormPassController = OurSignupFormState.passController;
  TextEditingController _signupFormReenteredPassController =
      OurSignupFormState.reenteredPassController;
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

  String loginEmailValidator(String value) {
    RegExp regex = RegExp(pattern);
    String retVal;
    if (value.isEmpty) {
      retVal = "Email field cannot be empty";
    } else if (!regex.hasMatch(value)) {
      retVal = "Enter valid Email";
      _loginFormEmailController.clear();
    } else {
      //do nothing
    }
    return retVal;
  }

  String loginPassValidator(String value) {
    String retVal;
    if (value.isEmpty) {
      retVal = "Password field cannot be empty";
    } else if (value.length < 7) {
      //TODO: check other factors to be more secure
      retVal = "Password must be more than 6 characters";
      _loginFormPassController.clear();
    } else {
      retVal = null;
    }
    return retVal;
  }

  String signupEmailValidator(String value) {
    //TODO: Check that the email hasnt been taken already
    RegExp regex = RegExp(pattern);
    String retVal;
    if (value.isEmpty) {
      retVal = "Email field cannot be empty";
    } else if (!regex.hasMatch(value)) {
      retVal = "Enter valid Email";
    } else {
      retVal = null;
    }
    return retVal;
  }

  String signupPassValidator(String value) {
    String retVal;
    if (value.isEmpty) {
      retVal = "Password field cannot be empty";
    } else if (value.length < 7) {
      retVal = "Password must be more than 6 characters";
      _signupFormPassController.clear();
    } else {
      //do nothing
    }
    return retVal;
  }

  String signupReenteredPassValidator(String value) {
    String retVal;
    if (value.isEmpty) {
      retVal = "Password field cannot be empty";
    } else if (value.length < 7) {
      retVal = "Password must be more than 6 characters";
      _signupFormReenteredPassController.clear();
    } else {
      //do nothing
    }
    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         value - the string that you are validating
  
  Return:         String the error message, or nothing if it is valid
  
  Description:    checks that the name field is not empty.
  ---------------------------------------------------------------------------------------------------*/
  String nameValidator(String value) {
    String retVal;
    if (value.isEmpty) {
      // TODO: check that its not too long either
      retVal = "Need to enter first and last name";
    } else {
      //do nothing
    }
    return retVal;
  }

  /*---------------------------------------------------------------------------------------------------
  Inputs:         value - the string that you are validating
  
  Return:         String the error message, or nothing if it is valid
  
  Description:    checks that the field is less then 1000 workds.
  ---------------------------------------------------------------------------------------------------*/
  String genericValidator(String value) {
    // TODO: create legit vaidation for each
    String retVal;
    if (value.length > 1000) {
      retVal = "Need to be under 1000 characters";
    } else {
      //do nothing
    }
    return retVal;
  }
}
