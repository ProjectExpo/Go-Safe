import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_expo/models/Message.dart';
import 'package:project_expo/services/FirebaseFunctions.dart';


class MessageChat extends StatefulWidget {
  final String myId;
  final String myName;
  final String uid;
  const MessageChat({Key? key, required this.myId, required this.uid, required this.myName}) : super(key: key);

  @override
  _MessageChatState createState() => _MessageChatState();
}

class _MessageChatState extends State<MessageChat> {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<dynamic, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('chats/${widget.uid}/messages')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot){

        if(snapshot.connectionState ==  ConnectionState.waiting){
          return Center(child: CircularProgressIndicator());
        }else if(snapshot.hasError){
          return(Text('Something Went Wrong!!'));
        }
        final messages = snapshot.data;
        // print(snapshot.data!.size);
        // return Text('Hi');

        return messages!.size == 0?Default():ListView.builder(
          physics: BouncingScrollPhysics(),
          reverse: true,
          itemCount: messages.size,
          itemBuilder: (context, index){
            final message = messages.docs[index]['message'];
            // print(message);
            return MessageText(message: message,isMe: messages.docs[index]['idUser'] == widget.myId?true:false, name: widget.myName,);
          },
        );
      },
    );
  }
}

class MessageText extends StatelessWidget {
  final String message;
  final bool isMe;
  final String name;
  const MessageText({Key? key, required this.message, required this.isMe, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe?MainAxisAlignment.end:MainAxisAlignment.start,
      children: [
        if(!isMe)
          CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://image.shutterstock.com/image-vector/male-avatar-profile-picture-vector-260nw-743546287.jpg'),),
        if(!isMe)
          SizedBox(width: 8,),
        Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: !isMe?Colors.grey[200] :Colors.blue[100],
            borderRadius: !isMe?BorderRadius.circular(13).subtract(BorderRadius.only(topLeft: Radius.circular(16))) :BorderRadius.circular(13).subtract(BorderRadius.only(bottomRight: Radius.circular(16))),
            boxShadow: [
              BoxShadow(
                color: !isMe?Colors.grey.shade300:Colors.grey.shade300,
                blurRadius: 10,
                offset: !isMe?Offset(10,10):Offset(-10, 10),
              ),
            ]
          ),
          child: Column(
            crossAxisAlignment: isMe?CrossAxisAlignment.end:CrossAxisAlignment.start,
            children: [
              Text(
                isMe?'You':name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700
                ),
              ),
              Text(message,style: TextStyle(fontSize: 20,),),
            ],
          ),
        ),
      ],
    );
  }
}


class Default extends StatelessWidget {
  const Default({Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: Text(
            'This Conversation will be deleted when User is Safe',style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
          ),
        ),
      ],
    );
  }
}


