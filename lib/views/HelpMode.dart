import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_expo/Autentication/location.dart';


class HelpMode extends StatefulWidget {
  final String uid;
  final Map<String, dynamic>? details;
  const HelpMode({Key? key, required this.uid,required this.details}) : super(key: key);

  @override
  _HelpModeState createState() => _HelpModeState();
}

class _HelpModeState extends State<HelpMode> {


  late bool HelpCalled;
  List<String> usersNear = [];

  getUsersNear() async{
    final QuerySnapshot result = await FirebaseFirestore.instance.collection('users').get();
    final List<QueryDocumentSnapshot<Object?>> document = result.docs;
    LatLng urLocation = LatLng(widget.details?['Last Current Location'].latitude, widget.details?['Last Current Location'].longitude);
    document.forEach((element) {
      LatLng temp = LatLng(element['Last Current Location'].latitude, element['Last Current Location'].longitude);
      if(distanceBetweenUsers(urLocation, temp) < 2000 && element.id != widget.uid){
        setState(() {
          usersNear.add(element.id);
        });

      }
      // print(distanceBetweenUsers(_latLng, temp));
    });
  }

  putHelpNearBy() async{
    String UserUid = widget.uid;
    bool isTiggeredHelp = true;

    await FirebaseFirestore.instance.collection('users').doc(widget.uid).update({'CalledHelp' : isTiggeredHelp});

    List<dynamic> listOfUsers = [];

    usersNear.forEach((element) async{
      await FirebaseFirestore.instance
          .collection('users')
          .doc(element)
          .get()
          .then((DocumentSnapshot documentSnapshot) => {
        listOfUsers = documentSnapshot.get('UsersNeedHelps')
      }).catchError((e) => print(e.toString()));

      if(!listOfUsers.contains(UserUid)){
        listOfUsers.add(UserUid);
      }
      await FirebaseFirestore.instance.collection('users').doc(element).update({'UsersNeedHelps': listOfUsers}).then((value) => print('List of Users Updated'));
    });


  }

  SendHelp(){
    getUsersNear();
    putHelpNearBy();
  }



  deleteHelp()async{

    final QuerySnapshot result = await FirebaseFirestore.instance.collection('users').get();
    final List<QueryDocumentSnapshot<Object?>> document = result.docs;

    document.forEach((element) async{
      List<dynamic> users = element['UsersNeedHelps'];
      if(users.contains(widget.uid)){
        users.remove(widget.uid);
        await FirebaseFirestore.instance.collection('users').doc(element.id).update({'UsersNeedHelps':users});
      }
    });

  }

  @override
  void initState(){
    HelpCalled = widget.details?['CalledHelp'];
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        margin: EdgeInsets.only(bottom: 30),
        color: Colors.white,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height/5),
              child: Image(
                  image: AssetImage(HelpCalled?'assets/Help.png':'assets/safe.png'),
                height: 200,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Text(
                'Hey ${widget.details?['name']},',
                style: TextStyle(
                  fontSize: 35,
                  fontFamily: 'Lobster'
                ),
                ),
              ),
            Container(
              margin: EdgeInsets.only(top: 10,left: 50),
              child: Text(
                HelpCalled?'Last we heard you were in trouble, Are You Safe Now?':'Good to know your are Safe,Let us know if You Need Any Help',
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 50),
              child: LiteRollingSwitch(
                value: HelpCalled,
                iconOn: Icons.flag,
                iconOff: Icons.done,
                textOn: 'Help',
                textOff: 'Safe',
                colorOn: Colors.red,
                colorOff: Colors.green,
                textSize: 20,
                onChanged: (bool state)async{
                  setState(() {
                    HelpCalled = !HelpCalled;
                  });
                  if(HelpCalled == true){
                    deleteHelp();
                    bool temp = false;
                    await FirebaseFirestore.instance.collection('users').doc(widget.uid).update({'CalledHelp' : temp}).then((value) => print('Set to false')).catchError((e)=> print(e.toString()));
                  }else{
                    SendHelp();
                    bool temp = true;
                    await FirebaseFirestore.instance.collection('users').doc(widget.uid).update({'CalledHelp' : temp}).then((value) => print('Set to true')).catchError((e)=> print(e.toString()));

                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
