import 'package:flutter/material.dart';

class NoInternetScreen extends StatelessWidget {
  static const routeName = '/cc';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 25,
            ),
            Image.asset('assets/images/no_internet.png'),
            Text(
              'Uh No!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25.0,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'You\'re not connected to internet',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(
              height: 05,
            ),
            Text(
              'check internet settings and try again',
              style: TextStyle(fontSize: 18),
            )
          ],
        ),
      ),
    );
  }
}
