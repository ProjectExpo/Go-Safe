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


List<dynamic> users =[];

deleteHelp(List<dynamic> usersSent, String User)async{
  print(usersSent);
}