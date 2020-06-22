import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profileScreen';
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userid;
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
  Widget build(BuildContext context) {
    FirebaseAuth.instance.currentUser().then((value) {
      setState(() {
        userid = value.uid;
      });
    });
    // var dataSnapshots=Firestore.instance.collection('users').document(userid).collection('profile').snapshots();
    // dataSnapshots.listen((event) {
    //   event.documents.map((e) =>
    //   print( e.data['Email'])
    //   );
    //  });
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
        appBar: appbar,
        body: SingleChildScrollView(
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
                                .collection('users')
                                .document(userid)
                                .collection('profile')
                                .snapshots(),
                            builder: (ctx, snapshot) {
                              // if (snapshot.connectionState ==
                              //     ConnectionState.waiting) {
                              //   return Center(child: CircularProgressIndicator());
                              // }
                              final doc=snapshot.data.documents;
                              return Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: abh + 20,
                                  ),
                                  buildTile(Icon(Icons.person), doc[0]['Full Name'],
                                      "Name"),
                                  Divider(),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  buildTile(Icon(Icons.email),  doc[0]['Email'],
                                      "Email"),
                                  Divider(),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  buildTile(Icon(Icons.phone), doc[0]['Phone'],
                                      "Phone Number"),
                                  Divider(),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  buildTile(Icon(Icons.today),  doc[0]['YOB'],
                                      "Year of Birth"),
                                  Divider(),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
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
        ));
  }
}
