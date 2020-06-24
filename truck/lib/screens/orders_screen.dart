import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  Widget buildListTile(index, title, s1, s2) {
    return ListTile(
      leading: CircleAvatar(
        radius: 23,
        child: Text(index.toString()),
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
          stream:
              Firestore.instance.collection('/users/${uid}/orders').orderBy('date', descending: true).snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: Text('Loading..'));
            }
            final document = userSnapshot.data.documents;
            return ListView.builder(
                itemCount: document.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: <Widget>[
                      InkWell(
                        onTap: (){
                          Navigator.of(context).pushNamed(CheckStatus.route);
                        },
                        child: buildListTile(
                          index + 1,
                          document[index]['Truck Number'],
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
