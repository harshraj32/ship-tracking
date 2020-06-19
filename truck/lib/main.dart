import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:truck/screens/homeScreen.dart';
import 'package:truck/services/auth_services.dart';
import './screens/loginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget with WidgetsBindingObserver {
  // This widget is the root of your application.
  Widget screen(){
      return StreamBuilder(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (BuildContext context, snapshot) {
          
          
            
          //    if (snapshot.hasData) {
          //   return HomeScreen();
          // } else {
          //   return LoginScreen();
          // }});
          // }
          if (snapshot.hasData) {
        if (snapshot.data.providerData.length == 1) { // logged in using email and password
          return snapshot.data.isEmailVerified
              ? HomeScreen()
              : LoginScreen();
        } else { // logged in using other providers
          return HomeScreen();
        }
      } else {
        return LoginScreen();
      }
        },);
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: screen(),
       routes: {
                HomeScreen.routeName: (ctx) => HomeScreen(),},
    );
  }
}
