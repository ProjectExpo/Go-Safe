import 'package:cloud_firestore/cloud_firestore.dart';

void addUser(String? uid, String email, String name){
  FirebaseFirestore
      .instance
      .collection("users")
      .doc(uid)
      .set({
    'email': email,
    'name': name,
  });
  print('added');
}
