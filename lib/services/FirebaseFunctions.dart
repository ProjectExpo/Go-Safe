

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_expo/models/Message.dart';

class FirebaseFunctions {

  static Future uploadMessage(String uid, String message, String myId,
      String myName) async {
    final refMessage = FirebaseFirestore.instance.collection(
        'chats/${uid}/messages');

    final newMessage = Message(
      idUser: myId,
      userName: myName,
      message: message,
      createdAt: DateTime.now(),
    );
    await refMessage.add(newMessage.toJson());
  }

}