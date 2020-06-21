import 'package:flutter/material.dart';

class RegistrationScreen extends StatefulWidget {
  static const routeName = "/registrationScreen";
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
          ),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(children: <Widget>[
            TextFormField(
              key: ValueKey('VehicleNo'),
              decoration: InputDecoration(
                labelText: "Vehicle No",
                fillColor: Colors.white,
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(25.0),
                  borderSide: new BorderSide(),
                ),
              ),
              onSaved: (value) {},
              validator: (value) {
                if (value.isEmpty) {
                  return "Vehicle number cann\'t be empty";
                }
                return null;
              },
            ),
            TextFormField(
              key: ValueKey('TruckNo'),
              decoration: InputDecoration(
                labelText: "Truck No",
                fillColor: Colors.white,
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(25.0),
                  borderSide: new BorderSide(),
                ),
              ),
              onSaved: (value) {
                // _truckNo = value;
              },
              validator: (value) {
                if (value.isEmpty) {
                  return "Truck Number cann\'t be empty";
                }
                return null;
              },
            ),
            SizedBox(
              height: 12,
            ),
            // Container(
            //   padding: EdgeInsets.all(16),
            //   child: Center(
            //     child: SizedBox(
            //       width: MediaQuery.of(context).size.width * 0.85,
            //       child: RaisedButton(
            //         color: Theme.of(context).primaryColor,
            //         shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(10.0)),
            //         child: Text(
            //           "SUBMIT",
            //           style: TextStyle(
            //               color: Colors.white,
            //               fontSize: 18.0,
            //               fontWeight: FontWeight.bold),
            //         ),
            //         onPressed: () {
            //           // _trySubmit();
            //         },
            //         padding: EdgeInsets.all(16.0),
            //       ),
            //     ),
            //   ),
            // ),
          ]),
        ),
      ),
    );
  }
}
