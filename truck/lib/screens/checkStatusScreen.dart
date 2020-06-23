import 'package:flutter/material.dart';
class CheckStatus extends StatefulWidget {
  static const route='/checkstatus';
  @override
  _CheckStatusState createState() => _CheckStatusState();
}

class _CheckStatusState extends State<CheckStatus> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tracking'),
      ),
      body: Center(
        child: Text('Tracking screen will be displayed here'),
      ),
    );
  }
}