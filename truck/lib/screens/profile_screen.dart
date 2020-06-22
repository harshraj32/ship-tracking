import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:truck/screens/registration_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profileScreen';
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String uid;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  var _fullName = '';
  var _email = '';
  var _yob = '';
  var _pyl = '';
  var phno = '';

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

      var uinstance =
          await Firestore.instance.collection('/users/${uid}/profile');

      var ref = await uinstance.getDocuments();

      await uinstance.document(ref.documents[0].documentID).updateData({
        'Full Name': _fullName,
        'Email': _email,
        'YOB': _yob,
        'Phone': phno,
        'date': _date,
        'PYL': _pyl,
      }).then((value) {
        Navigator.of(context).pop();
      });
    }
  }

  var isUp = false;
  Widget buildTile(Icon icon, String text, String title1) {
    return Container(
      // margin: EdgeInsets.only(bottom: 5),
      child: ListTile(
        leading: icon,
        title: Text(title1),
        subtitle: Text(text),
      ),
    );
  }

  @override
  void initState() {
    this.uid = '';
    this.phno = '';
    FirebaseAuth.instance.currentUser().then((value) {
      setState(() {
        this.uid = value.uid;
        this.phno = value.phoneNumber;
        print("profile:UID: " + uid);
      });
    }).catchError((e) {
      print("init:" + e);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appbar = AppBar(
      // backgroundColor: Colors.transparent,
      title: Text('Profile'),
    );
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var abh = appbar.preferredSize.height + MediaQuery.of(context).padding.top;
    // print(appbar.preferredSize.height+MediaQuery.of(context).padding.top);
    var hf = height / 4;

    return Scaffold(
      key: _scaffoldKey,
      appBar: appbar,
      body: SingleChildScrollView(
        child: Container(
          child: Stack(
            children: <Widget>[
              Container(
                width: width,
                height: height - abh,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: height - hf,
                    width: width - 30,
                    child: Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                        child: StreamBuilder(
                            stream: Firestore.instance
                                .collection('/users/${uid}/profile')
                                .snapshots(),
                            builder: (ctx, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              final doc = snapshot.data.documents;
                              return SingleChildScrollView(
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(
                                      height: abh + 20,
                                    ),
                                    buildTile(Icon(Icons.person),
                                        doc[0]['Full Name'], "Name"),
                                    Divider(),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    buildTile(Icon(Icons.email),
                                        doc[0]['Email'], "Email"),
                                    Divider(),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    buildTile(Icon(Icons.phone),
                                        doc[0]['Phone'], "Phone Number"),
                                    Divider(),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    buildTile(Icon(Icons.today), doc[0]['YOB'],
                                        "Year of Birth"),
                                    Divider(),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              );
                            })),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      // gradient: LinearGradient(
                      //   // stops: [0.5,0.5],
                      //   begin: Alignment.topLeft,
                      //   end: Alignment.bottomRight,
                      //   colors: [
                      //   Colors.orange,
                      //   Colors.orange[200],
                      // ])
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: hf,
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/images/dp.png'),
                              fit: BoxFit.fill),
                          borderRadius: BorderRadius.circular(80),
                        ),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: isUp
          ? Container()
          : FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  isUp = true;
                });
                _scaffoldKey.currentState
                    .showBottomSheet((context) {
                      return StreamBuilder(
                          stream: Firestore.instance
                              .collection('/users/${uid}/profile')
                              .snapshots(),
                          builder: (context, uSnapshot) {
                            if (uSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: Text('Loading...'),
                              );
                            }
                            final document = uSnapshot.data.documents;
                            return Container(
                                color: Colors.white,
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.height / 1.2,
                                child: Container(
                                  margin: EdgeInsets.all(16),
                                  child: SingleChildScrollView(
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                          // mainAxisAlignment: MainAxisAlignment.end,
                                          // crossAxisAlignment: CrossAxisAlignment.end,
                                          children: <Widget>[
                                            const SizedBox(
                                              height: 12,
                                            ),
                                            new ListTile(
                                              leading: Icon(Icons.person),
                                              title: new TextFormField(
                                                initialValue: document[0]
                                                    ['Full Name'],
                                                key: ValueKey('FullName'),
                                                decoration: InputDecoration(
                                                  labelText: "Full Name",
                                                  fillColor: Colors.white,
                                                  border:
                                                      new OutlineInputBorder(
                                                    // borderRadius: new BorderRadius.circular(25.0),
                                                    borderSide:
                                                        new BorderSide(),
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
                                                initialValue: _email =
                                                    document[0]['Email'],
                                                key: ValueKey('EmailId'),
                                                decoration: InputDecoration(
                                                  labelText: "Email",
                                                  fillColor: Colors.white,
                                                  border:
                                                      new OutlineInputBorder(
                                                    // borderRadius: new BorderRadius.circular(25.0),
                                                    borderSide:
                                                        new BorderSide(),
                                                  ),
                                                ),
                                                onSaved: (value) {
                                                  _email = value;
                                                },
                                                validator: (value) {
                                                  if (value.isEmpty) {
                                                    return "email address cann\'t be empty";
                                                  }
                                                  if (!value.contains('@'))
                                                    return "enter valid Email address";
                                                  return null;
                                                },
                                              ),
                                            ),
                                            new ListTile(
                                              leading: Icon(Icons.today),
                                              title: new TextFormField(
                                                initialValue: _yob =
                                                    document[0]['YOB'],
                                                key: ValueKey('YoB'),
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  labelText: "Year of Birth",
                                                  fillColor: Colors.white,
                                                  border:
                                                      new OutlineInputBorder(
                                                    // borderRadius: new BorderRadius.circular(25.0),
                                                    borderSide:
                                                        new BorderSide(),
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
                                                initialValue: _pyl =
                                                    document[0]['PYL'],
                                                key: ValueKey('Place'),
                                                decoration: InputDecoration(
                                                  labelText: "Place you live",
                                                  fillColor: Colors.white,
                                                  border:
                                                      new OutlineInputBorder(
                                                    borderSide:
                                                        new BorderSide(),
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
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.85,
                                                  child: RaisedButton(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0)),
                                                    child: Text(
                                                      "SUBMIT",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 18.0,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    onPressed: () {
                                                      _trySubmit();
                                                    },
                                                    padding:
                                                        EdgeInsets.all(16.0),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ]),
                                    ),
                                  ),
                                ));
                          });
                    })
                    .closed
                    .then((value) {
                      setState(() {
                        isUp = false;
                      });
                    });
              },
            ),
    );
  }
}
