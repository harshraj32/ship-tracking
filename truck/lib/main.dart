import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:truck/screens/homeScreen.dart';
import 'package:truck/screens/registration_screen.dart';
import 'package:truck/services/auth_services.dart';
import './screens/loginScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget with WidgetsBindingObserver {
  // This widget is the root of your application.
  Widget screen() {
    return StreamBuilder(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.providerData.length == 1) {
            // logged in using email and password
            return snapshot.data.isEmailVerified ? HomeScreen() : LoginScreen();
          } else {
            // logged in using other providers
            return HomeScreen();
          }
        } else {
          return LoginScreen();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ship Tracking',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        accentColor: Colors.blue,
        accentColorBrightness: Brightness.dark,
        buttonTheme: ButtonTheme.of(context).copyWith(
          buttonColor: Colors.orange,
          textTheme: ButtonTextTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: screen(),
      routes: {
        HomeScreen.routeName: (ctx) => HomeScreen(),
        RegistrationScreen.routeName: (ctx) => RegistrationScreen(),
      },
    );
  }
}
