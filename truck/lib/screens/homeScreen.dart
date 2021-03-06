import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:truck/providers/userRefProvider.dart';
import 'package:truck/screens/confirmationScreen.dart';
import 'package:truck/screens/loginScreen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:truck/screens/no_internet_screen.dart';
import 'package:truck/screens/orders_screen.dart';
import 'package:truck/screens/profile_screen.dart';
import 'package:truck/services/connection_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/homeScreen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  final Firestore _auth = Firestore.instance;
  final _textController = TextEditingController();
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  final _formKey = GlobalKey<FormState>();
  var _vehicleNo = '';
  var _truckNo = '';
  var _tyreCheckUp = false;
  var _tyres = 0;
  var downloadUrl1;

  var photoStatus = '';
  ProgressDialog pr;

  _getToken() {
    firebaseMessaging.getToken().then((token) {
      print("Device Token: $token");
    });
  }

  StreamSubscription<ConnectivityResult> _streamSubscription;
  Connectivity _connectivity = Connectivity();

  String _networkConnection = '';

  String uid;
  List<String> _tyresDD = ['Select tyres', '10', '12', '18'];
  String _selectedTyres = 'Select tyres';
  var connectionStatus = true;
  // String dropdownValue = 'Select Tyres';

  void checkConnectivitySubscription() async {
    _streamSubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      var conn = InternetConnectionService.getConnectionValue(result);
      switch (conn) {
        case 'None':
          setState(() {
            connectionStatus = false;
          });
          break;
        case 'Mobile':
          setState(() {
            connectionStatus = true;
          });
          break;
        case 'Wi-Fi':
          setState(() {
            connectionStatus = true;
          });
          break;
      }
    });
  }

  @override
  void initState() {
    this.uid = '';
    checkConnectivitySubscription();
    configLocalNotification();

    FirebaseAuth.instance.currentUser().then((value) {
      setState(() {
        this.uid = value.uid;
        print("UID: " + uid);
      });
    }).catchError((e) {
      print(e);
    });
    registerNotification();
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  Future<void> _trySubmit(userRefId) async {
    FocusScope.of(context).unfocus();
    final _isValid = _formKey.currentState.validate();
    // var _date = DateTime.now();

    if (_isValid) {
      _formKey.currentState.save();
      print(_selectedTyres);
      // print(dou);
      if (_selectedTyres == 'Select tyres' || downloadUrl1 == null) {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (ctx) {
              return AlertDialog(
                elevation: 5,
                insetPadding: EdgeInsets.all(15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                title: Text('Uh No!'),
                content: Text('Enter required details to continue'),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Text('OKAY'))
                ],
              );
            });
        return;
      }

      final collRef = Firestore.instance.collection('/users/${userRefId}/orders');
      DocumentReference docReference = collRef.document();
      String status = "";
      docReference.setData({
        'TruckNumber': _vehicleNo,
        'Tyres': _selectedTyres,
        'date': Timestamp.now(),
        'image_url': downloadUrl1,
        'sr_no': DateTime.now().millisecondsSinceEpoch.toString(),
        'status': 'Booked',
        'shipId':'NA'
      }).then((doc) {
        print('hop ${docReference.documentID}');
        status = "success";
        // showSnackBar();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ConfirmationScreen(status: status)));
      }).catchError((error) {
        print(error);
        status = "fail";
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ConfirmationScreen(status: status)));
      });
      _textController.clear();
      downloadUrl1 = '';
      setState(() {
        photoStatus = '';
        _selectedTyres = 'Select tyres';
      });
    }
  }

  _signOut() async {
    _firebaseAuth == null ? print(2) : print(_firebaseAuth.currentUser());
    await _firebaseAuth
        .signOut()
        .whenComplete(() => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(),
            ),
            (Route<dynamic> route) => false));
  }

  void configLocalNotification() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void registerNotification() {
    var userRefId = Provider.of<UserRefProvider>(context,listen: false).userReference;
    
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
      showNotification(message['notification']);
      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      return;
    });

    firebaseMessaging.getToken().then((token) async {
      print('token: $token');
      var uinstance =
          await Firestore.instance.collection('users');

      // var ref = await uinstance.getDocuments();
      await uinstance
          .document(userRefId)
          .updateData({'pushToken': token});
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'channel_ID',
      'channel name',
      'channel description',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));
  }

  //camera module
  StorageReference storageReference = FirebaseStorage.instance.ref();

  Future<void> _takePicture() async {
    var _imageFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );

    String fileName;
    try {
      fileName = path.basename(_imageFile.path);
    } catch (error) {
      print("exception: " + error.toString());
      showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Row(
                children: <Widget>[
                  Icon(
                    Icons.warning,
                    color: Colors.red,
                  ),
                  SizedBox(
                    width: 3,
                  ),
                  Text('Uh Nooo!'),
                ],
              ),
              content:
                  Text('Image selection cancelled, please select an Image'),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text('OKAY'))
              ],
            );
          });
      return;
    }

    StorageReference ref = storageReference.child("/truck_images");
    StorageUploadTask storageUploadTask =
        ref.child(fileName).putFile(_imageFile);
    if (storageUploadTask.isSuccessful || storageUploadTask.isComplete) {
      final String url = await ref.getDownloadURL();
      print("The download URL is " + url);
    } else if (storageUploadTask.isInProgress) {
      pr.show();
      storageUploadTask.events.listen((event) {
        double percentage = 100 *
            (event.snapshot.bytesTransferred.toDouble() /
                event.snapshot.totalByteCount.toDouble());
        if (percentage == 100.0) {
          pr.hide();
          setState(() {
            photoStatus = 'S';
          });
        }
        print("THe percentage " + percentage.toString());
      });

      StorageTaskSnapshot storageTaskSnapshot =
          await storageUploadTask.onComplete;
      downloadUrl1 = await storageTaskSnapshot.ref.getDownloadURL();
      // FirebaseData.uploadImage(downloadUrl1, DateTime.now().toString(), userId);
      //Here you can get the download URL when the task has been completed.
      print("Download URL " + downloadUrl1.toString());
    } else {
      print('exception occured');
      setState(() {
        photoStatus = 'F';
      });
      //Catch any cases here that might come up like canceled, interrupted
    }
  }

  //pick from gallery
  Future<void> _takePictureFromGallery() async {
    var _imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );
    String fileName;
    try {
      fileName = path.basename(_imageFile.path);
    } catch (error) {
      print("exception: " + error.toString());
      showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Text('Uh Nooo!'),
              content: Text(
                  'Image selection cancelled or interupted, Select an Image'),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text('OKAY'))
              ],
            );
          });
      return;
    }

    StorageReference ref = storageReference.child("/truck_images");
    StorageUploadTask storageUploadTask =
        ref.child(fileName).putFile(_imageFile);
    if (storageUploadTask.isSuccessful || storageUploadTask.isComplete) {
      final String url = await ref.getDownloadURL();
      print("The download URL is " + url);
    } else if (storageUploadTask.isInProgress) {
      pr.show();
      storageUploadTask.events.listen((event) {
        double percentage = 100 *
            (event.snapshot.bytesTransferred.toDouble() /
                event.snapshot.totalByteCount.toDouble());
        if (percentage == 100.0) {
          pr.hide();
          setState(() {
            photoStatus = 'S';
          });
        }
        print("THe percentage " + percentage.toString());
      });

      StorageTaskSnapshot storageTaskSnapshot =
          await storageUploadTask.onComplete;
      downloadUrl1 = await storageTaskSnapshot.ref.getDownloadURL();
      // FirebaseData.uploadImage(downloadUrl1, DateTime.now().toString(), userId);
      //Here you can get the download URL when the task has been completed.
      print("Download URL " + downloadUrl1.toString());
    } else {
      // throw Exception('Image pick cancelled or intrupted');
      print('exception occured while image upload');
      setState(() {
        photoStatus = 'F';
      });
      //Catch any cases here that might come up like canceled, interrupted
    }
  }

  //show dialog
  void showDialogForImage() {}

  var isfirst = true;
  var fetchStatus=false;
  @override
  void didChangeDependencies() async {
    if (isfirst) {
      await Provider.of<UserRefProvider>(context, listen: false)
          .fetchRef()
          .then((value) {
        setState(() {
          isfirst = false;
          fetchStatus=true;
        });
      });
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context, isDismissible: false);
    var userRefId = Provider.of<UserRefProvider>(context,listen: false).userReference;
    print('connection status:- ' + connectionStatus.toString());
    return !connectionStatus
        ? Scaffold(
            body: NoInternetScreen(),
          )
        : Scaffold(
            key: _scaffoldkey,
            appBar: AppBar(
              title: Text("Registration"),
              actions: [
                if(fetchStatus)
                DropdownButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).primaryIconTheme.color,
                    ),
                    dropdownColor: Colors.orange,
                    items: [
                      DropdownMenuItem(
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.person),
                              SizedBox(
                                width: 8,
                              ),
                              Text("Profile"),
                            ],
                          ),
                        ),
                        value: 'profile',
                      ),
                      DropdownMenuItem(
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.library_books),
                              SizedBox(
                                width: 8,
                              ),
                              Text("Orders"),
                            ],
                          ),
                        ),
                        value: 'orders',
                      ),
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
                      if (itemIdentifier == 'profile') {
                        Navigator.of(context)
                            .pushNamed(ProfileScreen.routeName);
                      }
                      if (itemIdentifier == 'orders') {
                        Navigator.of(context).pushNamed(OrdersScreen.routeName);
                      }
                    }),
              ],
            ),
            body: !connectionStatus
                ? NoInternetScreen()
                : fetchStatus?  SingleChildScrollView(
                    child: Container(
                      margin: EdgeInsets.all(10),
                      child: Form(
                        key: _formKey,
                        child: Column(children: <Widget>[
                          SizedBox(
                            height: 25,
                          ),
                          Container(
                            child: SvgPicture.asset('assets/images/pic2.svg'),
                            width: 250,
                            height: 250,
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextFormField(
                              controller: _textController,
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
                                _vehicleNo = value.toUpperCase();
                              },
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Vehicle number cann\'t be empty";
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 6),
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
                          photoStatus == ''
                              ? FlatButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (ctx) {
                                          return Dialog(
                                            elevation: 5,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Container(
                                              height: 120,
                                              child: Column(
                                                children: <Widget>[
                                                  FlatButton(
                                                    onPressed: () {
                                                      _takePictureFromGallery();
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Icon(Icons.image),
                                                        SizedBox(
                                                          width: 3,
                                                        ),
                                                        Text(
                                                            'Choose from gallery',
                                                            style: TextStyle(
                                                                fontSize:
                                                                    17.0)),
                                                      ],
                                                    ),
                                                  ),
                                                  Divider(),
                                                  FlatButton(
                                                    onPressed: () {
                                                      _takePicture();
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Icon(Icons.camera),
                                                        SizedBox(
                                                          width: 3,
                                                        ),
                                                        Text(
                                                          'Capture Image',
                                                          style: TextStyle(
                                                              fontSize: 17.0),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        });
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.camera_alt),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text('Take a picture of truck'),
                                    ],
                                  ))
                              : (photoStatus == 'S'
                                  ? Text(
                                      'Photo Uploaded Successfully',
                                      style: TextStyle(
                                        color: Colors.green,
                                      ),
                                    )
                                  : Text(
                                      'Photo Upload Failed',
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    )),
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
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  child: Text(
                                    "SUBMIT",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () {
                                    _trySubmit(userRefId);
                                  },
                                  padding: EdgeInsets.all(16.0),
                                ),
                              ),
                            ),
                          ),
                          // FlatButton(
                          //   onPressed: () {
                          //     Navigator.of(context).pushNamed("/cc");
                          //   },
                          //   child: Text("Connection Check"),
                          // ),
                        ]),
                      ),
                    ),
                  ):Center(
            child: CircularProgressIndicator(),
          ),
          );
  }
}
