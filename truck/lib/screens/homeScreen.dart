import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:truck/services/auth_services.dart';

class HomeScreen extends StatefulWidget {
   static const routeName = '/homeScreen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    _signOut() async {
      _firebaseAuth == null? print(2):print(_firebaseAuth.currentUser());
    await _firebaseAuth.signOut();
    
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
                        body: Container(),
                      );
                    }
                  
}
