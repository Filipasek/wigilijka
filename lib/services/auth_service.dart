import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthService {
  // static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  static Future addUserToDatabase(
      userId, String name, String contactData, String avatar) async {
    print('logged in');
    _firestore.collection('/users').document(userId).setData({
      'name': name,
      'contactData': contactData,
      'avatar': avatar,
    });
  }
}
