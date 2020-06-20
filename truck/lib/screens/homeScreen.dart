import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:truck/screens/loginScreen.dart';
import 'package:truck/services/auth_services.dart';
import 'package:flutter_svg/flutter_svg.dart';
class HomeScreen extends StatefulWidget {
  static const routeName = '/homeScreen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Firestore _auth = Firestore.instance;
  final _formKey = GlobalKey<FormState>();
  var _vehicleNo = '';
  var _truckNo = '';
  var _tyreCheckUp = false;
  var _tyres = 0;
  String uid;
  List<String> _tyresDD = ['Select tyres', '10', '12', '18'];
  String _selectedTyres;
  // String dropdownValue = 'Select Tyres';

  @override
  void initState() {
    this.uid = '';
    FirebaseAuth.instance.currentUser().then((value) {
      setState(() {
        this.uid = value.uid;
        print("UID: " + uid);
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
      print(_vehicleNo.trim());
      print(_truckNo.trim());
      print(_selectedTyres);

      await Firestore.instance.collection('/users/${uid}/orders').add({
        'Ship Number': _vehicleNo,
        'Truck Number': _truckNo,
        'Tyres': _selectedTyres,
        'date': _date
      });
      // print("BuildContext:".context);
      // Scaffold.of(context).showSnackBar(SnackBar(
      //   content: Text("vehicle:" +
      //       _vehicleNo +
      //       " truck:" +
      //       _truckNo +
      //       " tyres:" +
      //       _selectedTyres),
      //       duration: Duration(seconds: 5),
      // ));
    }
  }

  _signOut() async {
    _firebaseAuth == null ? print(2) : print(_firebaseAuth.currentUser());
    await _firebaseAuth.signOut().whenComplete(() => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(),
            ),
            (Route<dynamic> route) => false));
     
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          DropdownButton(
              icon: Icon(Icons.more_vert),
              items: [
                DropdownMenuItem(
                  child: Container(
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.exit_to_app),
                        SizedBox(
                          width: 8,
                        ),
                        Text("Logout"),
                      ],
                    ),
                  ),
                  value: 'logout',
                )
              ],
              onChanged: (itemIdentifier) {
                if (itemIdentifier == 'logout') {
                  // AuthService().signOut();
                  _signOut();
                }
              }),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Container(
                child: SvgPicture.asset('assets/images/booking.svg'),
                width: 300,
                height: 300,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextFormField(
                  key: ValueKey('VehicleNo'),
                  decoration: InputDecoration(
                    labelText: "Vehicle No",
                    fillColor: Colors.white,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(25.0),
                      borderSide: new BorderSide(),
                    ),
                  ),
                  onSaved: (value) {
                    _vehicleNo = value;
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Vehicle number cann\'t be empty";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextFormField(
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
                    _truckNo = value;
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Truck Number cann\'t be empty";
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 12),
                  padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 6),
                  // padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    border: Border.all(
                        color: Theme.of(context).primaryColor,
                        style: BorderStyle.solid,
                        width: 0.80),
                  ),
                  child: DropdownButton(
                    underline: Container(),
                    hint: Text('Select tyres'),
                    value: _selectedTyres,
                    isExpanded: true,
                     
                    onChanged: (newValue) {
                      setState(() {
                        _selectedTyres = newValue;
                      });
                    },
                    items: _tyresDD.map((tyre) {
                      return DropdownMenuItem(
                        child: new Text(tyre),
                        value: tyre,
                      );
                    }).toList(),
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
      ),
    );
  }
}
