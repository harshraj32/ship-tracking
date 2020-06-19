import 'package:flutter/material.dart';
import 'package:truck/screens/homeScreen.dart';
import 'package:truck/services/auth_services.dart';
import './screens/loginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
<<<<<<< HEAD
      home:AuthService.handleAuth(),
      
      //  LoginScreen()
=======
      home: AuthService().handleAuth(),
       routes: {
                HomeScreen.routeName: (ctx) => HomeScreen(),},
>>>>>>> 7471a499309c8924c875bd790ed49d871c64a079
    );
  }
}
