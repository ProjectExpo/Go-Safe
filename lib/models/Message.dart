

import 'package:flutter/cupertino.dart';

class Message{
  final String? idUser;
  final String? userName;
  final String? message;
  final DateTime? createdAt;

  const Message({
    @required this.idUser,
    @required this.userName,
    @required this.message,
    @required this.createdAt,

  });

  static Message fromJson(Map<String, dynamic>json) => Message(
      idUser: json['idUser'],
      userName: json['userName'],
      message: json['message'],
      createdAt: json['createdAt']);

  Map<String, dynamic> toJson() =>{
    'idUser' : idUser,
    'userName': userName,
    'message': message,
    'createdAt': createdAt,
  };


}