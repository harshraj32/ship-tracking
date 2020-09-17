import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserRefProvider with ChangeNotifier {
  var userReference;
  Future<void> fetchRef() async {
    FirebaseAuth.instance.currentUser().then((value) async {
      var ref =
          await Firestore.instance.collection('keys').document(value.uid).get();
      print("In provider: " + ref.data['refId']);
      userReference = ref.data['refId'];
    });
  }
}
