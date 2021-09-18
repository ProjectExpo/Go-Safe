import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_expo/services/FirebaseFunctions.dart';
import 'package:project_expo/views/MessageChat.dart';

class MessageField extends StatefulWidget {
  final String uid;
  final String urUid;
  final String urName;
  final Map<String, dynamic> details;
  const MessageField({Key? key, required this.details, required this.uid, required this.urUid, required this.urName}) : super(key: key);

  @override
  _MessageFieldState createState() => _MessageFieldState();
}

class _MessageFieldState extends State<MessageField> {

  TextEditingController _newMessage = new TextEditingController();
  String message ="";

  void sendMessage() async{
    FocusScope.of(context).unfocus();

    await FirebaseFunctions.uploadMessage(widget.uid,message,widget.urUid,widget.urName);
    _newMessage.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage:NetworkImage('https://cdn5.vectorstock.com/i/1000x1000/48/89/man-character-avatar-in-flat-design-vector-10834889.jpg',),
            ),
            SizedBox(width: 10,),
            Text(widget.details['name']),
          ],
        ),
      ),
      body: Column(
        children: [

          Expanded(
              child:Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: MessageChat(myId: widget.urUid,uid: widget.uid,myName: widget.urName,),
              ) ,
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _newMessage,
                    textCapitalization: TextCapitalization.sentences,
                    autocorrect: true,
                    enableSuggestions: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      labelText: 'Type a message',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 0),
                        gapPadding: 10,
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onChanged: (value) => setState((){
                      message = value;
                    }),
                  ),
                ),
                SizedBox(width: 10,),
                GestureDetector(
                  onTap: message.trim().isEmpty?null:sendMessage,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: Icon(Icons.send_sharp, color: Colors.white,),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
