import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class CheckStatus extends StatefulWidget {
  static const route = '/checkstatus';
  @override
  _CheckStatusState createState() => _CheckStatusState();
}

class _CheckStatusState extends State<CheckStatus> {
  String uid;
  Completer<GoogleMapController> _controller = Completer();
  List<LatLng> latlng1 = [];
  double _originLatitude = 17.4401, _originLongitude = 78.3489;
  double _destLatitude = 18.8762165, _destLongitude = 79.998875;
  BitmapDescriptor pinLocationIcon;
  BitmapDescriptor pinLocationIcon2;
  Set<Marker> _markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPIKey = "AIzaSyAx1w469aSv5bKV8u0YJg3M_Lt-grDkEgo";
  int oldlen = 0;
  @override
  void didChangeDependencies() async {
    print("changes made");

    _getPolyline();
    super.didChangeDependencies();
  }

  void _onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);
  }

  _addPolyLine() {
    print(' Inside addployline function ');
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      width: 5,
      polylineId: id,
      color: Colors.blue,
      points: latlng1,
      visible: true,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPIKey,
      PointLatLng(_originLatitude, _originLongitude),
      PointLatLng(_destLatitude, _destLongitude),
      // travelMode: TravelMode.driving,
      // wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")]
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        latlng1.add(LatLng(point.latitude, point.longitude));
      });
    }
    print("before calling addpolyline");
    _addPolyLine();
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
    // BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.6),
    //         'assets/images/red_dot.png')
    //     .then((onValue1) {
    //   pinLocationIcon2= onValue1;
    // }).;

    super.initState();
  }

 

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(latlng1);
    print(latlng1.length);
    if (latlng1.length != 0) {
      setState(() {
        _originLatitude = num.parse(latlng1[0].latitude.toStringAsFixed(5));
        _originLongitude = num.parse(latlng1[0].longitude.toStringAsFixed(5));
        _destLatitude =
            num.parse(latlng1[latlng1.length - 1].latitude.toStringAsFixed(5));
        _destLongitude =
            num.parse(latlng1[latlng1.length - 1].longitude.toStringAsFixed(5));
      });
    }
    print(_originLatitude.toString() + " org lat");
    print(_originLongitude.toString() + " org lon");
    print(_destLatitude.toString() + " dest lat");
    print(_destLongitude.toString() + " dest lon");
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
              .orderBy('timestamp')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            var doc = snapshot.data.documents;
            print('Tracking docs: ' + doc.toString());
            var len = doc.length;
            if (len > oldlen) {
              _getPolyline();
            }
            oldlen = len;
            List<LatLng> latlng = [];

            for (int i = 0; i < doc.length; i++) {
              latlng.add(LatLng(
                  double.parse(doc[i]['lat']), double.parse(doc[i]['lng'])));
            }
            latlng1 = latlng;
            return len == 0
                ? Center(
                    child: Text('ship is not assigned yet'),
                  )
                : GoogleMap(
                    polylines: Set<Polyline>.of(polylines.values),
                    myLocationEnabled: true,
                    compassEnabled: true,
                    tiltGesturesEnabled: false,
                    mapType: MapType.normal,
                    markers: Set<Marker>.of(latlng.map((e) {
                      if (latlng[0].latitude == e.latitude &&
                          latlng[0].longitude == e.longitude) {
                        return Marker(
                          markerId: MarkerId('rakesh'),
                          position: e,
                        );
                      } else if (latlng[len - 1].latitude == e.latitude &&
                          latlng[len - 1].longitude == e.longitude) {
                        return Marker(
                          markerId: MarkerId('rakesh'),
                          position: e,
                          icon: pinLocationIcon,
                        );
                      } else {
                        return Marker(
                            markerId: MarkerId('rakesh'),
                            position: e,
                            icon: BitmapDescriptor.defaultMarkerWithHue(200));
                      }
                    }).toList()),
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(double.parse(doc[len - 1]['lat']),
                          double.parse(doc[len - 1]['lng'])),
                      zoom: 8.0,
                    ),
                  );
          }),
    );
  }
}
