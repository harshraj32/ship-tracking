import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CheckStatus extends StatefulWidget {
  static const route = '/checkstatus';
  @override
  _CheckStatusState createState() => _CheckStatusState();
}

class _CheckStatusState extends State<CheckStatus> {
  String uid;
  Completer<GoogleMapController> _controller = Completer();

  BitmapDescriptor pinLocationIcon;
  BitmapDescriptor pinLocationIcon2;

  // static const LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

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

    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5),
            'assets/images/ship_marker_small_96.png')
        .then((onValue) {
      pinLocationIcon = onValue;
    });

    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    Map<String, Object> docId = ModalRoute.of(context).settings.arguments;
    if (docId != null) {
      print("docID:" + docId['docId']);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Tracking'),
      ),
      body: StreamBuilder(
          stream: Firestore.instance
              .collection('users')
              .document(uid)
              .collection('orders')
              .document(docId['docId'])
              .collection('coordinates')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            var doc = snapshot.data.documents;
            var len = doc.length;
            List<LatLng> latlng = [];
            for (int i = 0; i < doc.length; i++) {
              latlng.add(LatLng(
                  double.parse(doc[i]['lat']), double.parse(doc[i]['lng'])));
            }
            return GoogleMap(
              markers: Set<Marker>.of(latlng.map((e) {
                
                if(latlng[0].latitude==e.latitude && latlng[0].longitude==e.longitude){
                  return Marker(
                  markerId: MarkerId('rakesh'),
                  position: e,
                  
                );
                }
                else if(latlng[len-1].latitude==e.latitude&& latlng[len-1].longitude==e.longitude ){
                  return Marker(
                  markerId: MarkerId('rakesh'),
                  position: e,
                  icon: pinLocationIcon
                );
                }
                else{
                  return Marker(
                  markerId: MarkerId('rakesh'),
                  position: e,
                  icon: pinLocationIcon2
                );
                }
               
                
              }).toList()),
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(double.parse(doc[len - 1]['lat']),
                    double.parse(doc[len - 1]['lng'])),
                zoom: 11.0,
              ),
            );
          }),
    );
  }
}
