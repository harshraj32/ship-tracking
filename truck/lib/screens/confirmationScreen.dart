import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

class ConfirmationScreen extends StatefulWidget {
  static const routeName = '/Confirmation';
  final String status;
  ConfirmationScreen({
    @required this.status,
  }) : assert(status != null);
  @override
  _ConfirmationScreenState createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  String animationName = "Build";
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid;
  var initializationSettingsIOS;
  var initializationSettings;

   void _showNotification() async {
    await _demoNotification();
  }

   Future<void> _demoNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'channel_ID', 'channel name', 'channel description',
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'test ticker');

    var iOSChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(0, 'truck Registered',
        'Your SR number is: 1234354', platformChannelSpecifics,
        payload: 'test payload');
  }

  void popConfirmScreenTimer() {
    Timer _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      Navigator.of(context).pop();
      timer.cancel();
    });
  }

  @override
  void initState() {
    popConfirmScreenTimer();
    super.initState();
    initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    initializationSettingsIOS = new IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    _showNotification();
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('Notification payload: $payload');
    }
    // await Navigator.push(context,
    //     new MaterialPageRoute(builder: (context) => new SecondRoute()));
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text(title),
              content: Text(body),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text('Ok'),
                  // onPressed: () async {
                  //   Navigator.of(context, rootNavigator: true).pop();
                  //   await Navigator.push(context,
                  //       MaterialPageRoute(builder: (context) => SecondRoute()));
                  // },
                )
              ],
            ));
      }
  @override
  Widget build(BuildContext context) {
    print("entering conformation screen");
    return Scaffold(
      backgroundColor: Colors.orange,
      // appBar: AppBar(title: Text("Confirmation")),
      body: Center(
        child: Container(
          width: 300,
          height: 300,
          child: widget.status == "success"
              ? FlareActor(
                  'assets/images/success.flr',
                  alignment: Alignment.center,
                  fit: BoxFit.contain,
                  animation: "success",
                )
              : FlareActor(
                  'assets/images/fail_icon.flr',
                  alignment: Alignment.center,
                  fit: BoxFit.contain,
                  animation: "pop",
                ),
        ),
      ),
    );
  }
}
