import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:truck/screens/authScreen.dart';
import 'package:truck/screens/homeScreen.dart';
import 'package:truck/screens/loginScreen.dart';


class AuthService {
  //Handles Auth
 static  handleAuth() {
   print('handiling auth pages');
    return StreamBuilder(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            print("has data ...loading home screen");
            return HomeScreen();
          } else {
            print('no data found...loading auth screen');
            return LoginScreen();
          }
        });
  }

  //Sign out
  static signOut() {
    print("siging out..");
    FirebaseAuth.instance.signOut();
  }

  //SignIn
  static signIn(AuthCredential authCreds) {
    FirebaseAuth.instance.signInWithCredential(authCreds);
  }

  static signInWithOTP(smsCode, verId) {
    AuthCredential authCreds = PhoneAuthProvider.getCredential(
        verificationId: verId, smsCode: smsCode);
    signIn(authCreds);
  }
}
