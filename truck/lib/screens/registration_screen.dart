import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegistrationScreen extends StatefulWidget {
  static const routeName = "/registrationScreen";
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  var _fullName = '';
  var _email = '';
  var _yob = '';
  var _pyl = '';
  var _phone;
  var uid;

  @override
  void initState() {
    this.uid = '';
    this._phone = '';
    FirebaseAuth.instance.currentUser().then((value) {
      setState(() {
        this.uid = value.uid;
        this._phone = value.phoneNumber;
        print("UID: " + uid);
        print("Phone:" +_phone);
      });
    }).catchError((e) {
      print(e);
    });
    super.initState();
  }

  Future<void> _trySubmit() async {
    FocusScope.of(context).unfocus();
    final _isValid = _formKey.currentState.validate();
    var _date = DateTime.now();

    if (_isValid) {
      _formKey.currentState.save();
      print(_fullName.trim());
      print(_email.trim());
      print(_yob);
      print(_pyl);
      await Firestore.instance.collection('/users/${uid}/profile').add({
        'Full Name': _fullName,
        'Email': _email,
        'Phone': _phone,
        'YOB': _yob,
        'date': _date,
        // 'PYL': _pyl,
      }).then((value) {
        // showSnackBar();
        Navigator.of(context).pushReplacementNamed('/homeScreen');
      });
    }
  }

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
            const SizedBox(
              height: 12,
            ),
            new ListTile(
              leading: Icon(Icons.person),
              title: new TextFormField(
                key: ValueKey('FullName'),
                decoration: InputDecoration(
                  labelText: "Full Name",
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    // borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(),
                  ),
                ),
                onSaved: (value) {
                  _fullName = value;
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return "full name cann\'t be empty";
                  }
                  return null;
                },
              ),
            ),
            new ListTile(
              leading: Icon(Icons.email),
              title: new TextFormField(
                key: ValueKey('EmailId'),
                decoration: InputDecoration(
                  labelText: "Email",
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    // borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(),
                  ),
                ),
                onSaved: (value) {
                  _email = value;
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return "email address cann\'t be empty";
                  }
                  if(!value.contains('@'))
                    return "enter valid Email address";
                  return null;
                },
              ),
            ),
            new ListTile(
              leading: Icon(Icons.today),
              title: new TextFormField(
                key: ValueKey('YoB'),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Year of Birth",
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    // borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(),
                  ),
                ),
                onSaved: (value) {
                  _yob = value;
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return "Year of Birth cann\'t be empty";
                  }
                  return null;
                },
              ),
            ),
            new ListTile(
              leading: Icon(Icons.place),
              title: new TextFormField(
                key: ValueKey('Place'),
                decoration: InputDecoration(
                  labelText: "Place you live",
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderSide: new BorderSide(),
                  ),
                ),
                onSaved: (value) {
                  _pyl = value;
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return "Place you live cann\'t be empty";
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(
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
                      "SUBMIT",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      _trySubmit();
                    },
                    padding: EdgeInsets.all(16.0),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
