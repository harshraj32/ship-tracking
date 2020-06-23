import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  @override
  Widget build(BuildContext context) {
    print("entering conformation screen");
    return Scaffold(
      appBar: AppBar(title: Text("Confirmation")),
      body: Column(children: [
        Center(
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
                    )),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.90,
          child: Card(
            elevation: 4,
            // margin: EdgeInsets.all(15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
            ),
            child: Column(
              children: <Widget>[
                ListTile(
                  title: Text("SR Number"),
                  subtitle: Text("xjoandoianw"),
                ),
                Divider(),
                ListTile(
                  title: Text("Date"),
                  subtitle: Text(DateFormat("d-MMMM-y H:m:s EEEE").format( DateTime.now())),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 12,
        ),
        Container(
          padding: EdgeInsets.all(16),
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: RaisedButton(
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                child: Text(
                  "Check Status",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {},
                padding: EdgeInsets.all(16.0),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
