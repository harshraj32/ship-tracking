import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:truck/screens/homeScreen.dart';
import 'package:truck/screens/no_internet_screen.dart';
import 'package:truck/screens/orders_screen.dart';
import 'package:truck/screens/profile_screen.dart';
import 'package:truck/screens/registration_screen.dart';
import './screens/loginScreen.dart';
import './screens/checkStatusScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget with WidgetsBindingObserver {
  // This widget is the root of your application.
  Widget screen() {
    return StreamBuilder(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (BuildContext context, snapshot) {
          switch (snapshot.connectionState) {
            case (ConnectionState.active):
            case (ConnectionState.done):
              if (snapshot.hasData) {
                if (snapshot.data.providerData.length == 1) {
                  // logged in using email and password
                  return snapshot.data.isEmailVerified
                      ? HomeScreen()
                      : LoginScreen();
                } else {
                  // logged in using other providers
                  return HomeScreen();
                }
              } else {
                return LoginScreen();
              }
              break;
            case (ConnectionState.waiting):
              return Scaffold(
                  body: Center(
                child: CircularProgressIndicator(),
              ));
          }
        });
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
      // home: screen(),
      home: screen(),
      routes: {
        HomeScreen.routeName: (ctx) => HomeScreen(),
        RegistrationScreen.routeName: (ctx) => RegistrationScreen(),
        ProfileScreen.routeName: (ctx) => ProfileScreen(),
        NoInternetScreen.routeName: (ctx) => NoInternetScreen(),
        CheckStatus.route: (ctx) => CheckStatus(),
        OrdersScreen.routeName: (ctx) => OrdersScreen(),
      },
    );
  }
}
