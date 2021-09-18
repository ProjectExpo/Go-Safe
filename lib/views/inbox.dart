import 'package:flutter/material.dart';
import 'package:project_expo/services/FirebaseFunctions.dart';
import 'package:project_expo/views/MessageChat.dart';


class Inbox extends StatefulWidget {
  final String uid;
  final String name;
  const Inbox({Key? key, required this.uid, required this.name}) : super(key: key);

  @override
  _InboxState createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  TextEditingController _newMessage = new TextEditingController();
  String message ="";

  void sendMessage() async{
    FocusScope.of(context).unfocus();

    await FirebaseFunctions.uploadMessage(widget.uid,message,widget.uid,widget.name);
    _newMessage.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inbox'),
        centerTitle: true,
      ),
      body: Column(
        children: [

          Expanded(
            child:Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: MessageChat(myId: widget.uid,uid: widget.uid,myName: widget.name,),
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
