import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:truck/screens/authScreen.dart';
import 'package:truck/screens/homeScreen.dart';
import 'package:truck/screens/loginScreen.dart';

import 'package:truck/screens/loginScreen.dart';


class AuthService {
  //Handles Auth
 handleAuth() {
   print('handiling auth pages');
    return StreamBuilder(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (BuildContext context, snapshot) {
          
          
            
             if (snapshot.hasData) {
            return HomeScreen();
          } else {
            return LoginScreen();
          }});
          }
         
  

  //Sign out
  signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  //SignIn
  signIn(AuthCredential authCreds) async{
   await FirebaseAuth.instance
    .signInWithCredential(authCreds)
        .then((AuthResult value) {
      if (value.user != null) {
        // Handle loogged in state
      //  user = value.user;
        print(value.user.phoneNumber);
        // Navigator.pushAndRemoveUntil(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => HomeScreen(),
        //     ),
        //     (Route<dynamic> route) => false);
      
      } else {
        // showToast("Error validating OTP, try again", Colors.red);
      }
    }).catchError((error) {
      // showToast("Something went wrong", Colors.red);
    });
  }
    

  signInWithOTP(smsCode, verId) async {
    AuthCredential authCreds = PhoneAuthProvider.getCredential(
        verificationId: verId, smsCode: smsCode);
   await signIn(authCreds);
  }
        }
