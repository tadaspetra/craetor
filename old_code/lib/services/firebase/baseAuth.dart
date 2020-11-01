import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

abstract class OurBaseAuth {
  Future<FirebaseUser> createUser(String email, String password);
  Future<FirebaseUser> signIn(String email, String password);
  Future<FirebaseUser> getCurrentUser();
  Future<void> signOut();
  Future<void> sendEmailVerification();
  Future<bool> isEmailVerified();
  Future<bool> sendPasswordResetEmail(String email);
}

class OurAuth implements OurBaseAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /*---------------------------------------------------------------------------------------------------
  Inputs:         email - the email of the user signing up
                  password - the password of the user signing up
  
  Return:         FirebaseUser - all the authentication information associated with the user that was 
                  created

  Description:    Creates a user with firebase auth, using the email and password method. After it creates
                  the account, and email will be sent out. The user account is created right here, but the 
                  user will not be able to sign into it until the email is verified. But the user information
                  is still returned from this function even if it is not verified
  ---------------------------------------------------------------------------------------------------*/
  Future<FirebaseUser> createUser(String email, String password) async {
    FirebaseUser retVal;
    try {
      AuthResult authResult = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      retVal = authResult.user;
      sendEmailVerification();
    } catch (e) {
      //print("Error: $e");
    }
    return retVal;
  }

  Future<FirebaseUser> signIn(String email, String password) async {
    FirebaseUser retVal;
    try {
      AuthResult authResult = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      retVal = authResult.user;
    } catch (e) {
      //print("Error: $e");
    }
    return retVal;
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser retVal;
    try {
      retVal = await _auth.currentUser();
    } catch (e) {
      //print("Error: $e");
    }
    return retVal;
  }

  Future<void> signOut() async {
    return _auth.signOut();
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await getCurrentUser();
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    bool retVal;
    FirebaseUser user = await getCurrentUser();
    try {
      retVal = user.isEmailVerified;
    } catch (e) {
      retVal = false;
    }
    return retVal;
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    bool retVal = false;
    try {
      await _auth.sendPasswordResetEmail(email: email);
      retVal = true;
    } catch (e) {
      print("Error: $e");
      retVal = false;
    }
    return retVal;
  }
}
