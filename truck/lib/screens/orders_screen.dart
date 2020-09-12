import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:truck/screens/checkStatusScreen.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/ordersScreen';
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _userInstance = Firestore.instance;
  String uid;

  @override
  void initState() {
    this.uid = '';
    // checkConnectivitySubscription();
    FirebaseAuth.instance.currentUser().then((value) {
      setState(() {
        this.uid = value.uid;
        print("orders:UID: " + uid);
      });
    }).catchError((e) {
      print(e);
    });
    super.initState();
  }

  Widget buildListTile(index, status, title, s1, s2) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor:Colors.orangeAccent,
        radius: 23,
        child: Text(
          status=='Booked'?'B':(status=='Up'?'U':'D'),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      title: Text(title),
      subtitle: Text('Tyres: ' + s1),
      trailing: Icon(Icons.chevron_right),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('entered build:order screen');
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: StreamBuilder(
          stream: Firestore.instance
              .collection('/users/${uid}/orders')
              // .orderBy('date', descending: true)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: Text('Loading..'));
            }
            final document = userSnapshot.data.documents;
            print("docs fetched:");
            print(document);
            if (document.length == 0) {
              return Center(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SvgPicture.asset(
                        'assets/images/collecting.svg',
                        height: 200,
                        width: 200,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text('No Orders Found',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[500])),
                    ],
                  ),
                ),
              );
            }
            return ListView.builder(
                itemCount: document.length,
                itemBuilder: (context, index) {
                  print("doc ID:" + userSnapshot.toString());
                  DocumentSnapshot singleDoc = document[index];
                  print(singleDoc.documentID);
                  var sr_status = document[index]['sr_no'];
                  return Column(
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(CheckStatus.route,
                              arguments: {
                                'docId': singleDoc.documentID,
                                'image_url': document[index]['image_url'],
                                'data':document[index],
                              });
                        },
                        child: buildListTile(
                          index + 1,
                          document[index]['status'],
                          document[index]['TruckNumber'],
                          document[index]['Tyres'],
                          document[index]['date'],
                        ),
                      ),
                      Divider()
                    ],
                  );
                  // Text('hai');
                });
          }),
    );
  }
}
