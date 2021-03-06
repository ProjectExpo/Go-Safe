import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_expo/Autentication/location.dart';
import 'package:telephony/telephony.dart';

class Box extends StatefulWidget {
  final Map<String, dynamic>? details;
  final String? uid;
  const Box({Key? key, required this.uid, required this.details})
      : super(key: key);
  @override
  _BoxState createState() => _BoxState();
}

class _BoxState extends State<Box> {
  sendAlertMessage(String num) async {
    final Telephony telephony = Telephony.instance;
    bool? isPermissionEnabled = await telephony.requestPhoneAndSmsPermissions;
    if (isPermissionEnabled!) {
      await telephony
          .sendSms(
              to: num,
              message:
                  'Hi, I am ${widget.details?['name']}.I need Help you can Track me on GoSafe App. \n This is a automated Message we recommend you to check on them ASAP.\n\n Last Seen Location [${widget.details?['Last Current Location'].latitude},${widget.details?['Last Current Location'].longitude}].',
              isMultipart: true)
          .then((value) => print("Sms Sent"))
          .onError((error, stackTrace) => print(error.toString()));
    } else {
      print('Phone Calls and Sms are not enabled');
    }
  }

  LatLng _latLng = new LatLng(0, 0);
  List<dynamic> numbers =[];

  getLiveLocation() async {
    try {
      await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .then((value) => {
                setState(() {
                  _latLng = LatLng(value.latitude, value.longitude);
                })
              });
    } catch (e) {
      print(e.toString());
    }
  }

  List<String> usersNear = [];

  getUsersNear() async {
    final QuerySnapshot result =
        await FirebaseFirestore.instance.collection('users').get();
    final List<QueryDocumentSnapshot<Object?>> document = result.docs;
    LatLng urLocation = LatLng(
        widget.details?['Last Current Location'].latitude,
        widget.details?['Last Current Location'].longitude);
    document.forEach((element) {
      LatLng temp = LatLng(element['Last Current Location'].latitude,
          element['Last Current Location'].longitude);
      print(element['Last Current Location'].latitude);
      print(element['Last Current Location'].longitude);
      print(urLocation);
      print(distanceBetweenUsers(urLocation, temp));
      if (distanceBetweenUsers(urLocation, temp) < 2000 &&
          element.id != widget.uid) {
        setState(() {
          usersNear.add(element.id);
        });
      }
      // print(distanceBetweenUsers(_latLng, temp));
    });
    // print(usersNear);
  }

  putHelpNearBy() async {
    String UserUid = widget.uid!;
    bool isTiggeredHelp = true;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .update({'CalledHelp': isTiggeredHelp});

    List<dynamic> listOfUsers = [];
    String contacts = '';

    usersNear.forEach((element) async {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(element)
          .get()
          .then((DocumentSnapshot documentSnapshot)
              {
                listOfUsers = documentSnapshot.get('UsersNeedHelps');
                contacts = documentSnapshot.get('Phone Number');
                sendAlertMessage(contacts);
              })
          .catchError((e) => print(e.toString()));

      if (!listOfUsers.contains(UserUid)) {
        listOfUsers.add(UserUid);
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(element)
          .update({'UsersNeedHelps': listOfUsers});
    });
  }

  SendHelp()async{
    await getUsersNear();
    await putHelpNearBy();
    print(numbers);

  }

  @override
  void initState() {
    getLiveLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 220),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white,
          shape: BoxShape.rectangle,
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(left: 30, top: 20),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                  ),
                  Text(
                    'Emergengy',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            Container(
                margin: EdgeInsets.all(40),
                child: Text(
                  'Are You Sure to Call for Help, Your Location will be sent to people nearby',
                  style: TextStyle(fontSize: 20),
                )),
            Container(
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(60),
                  color: Colors.lightBlue),
              child: MaterialButton(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 16),
                onPressed: () async {
                  // await createNotification();
                  SendHelp();
                  bool temp = true;
                  await FirebaseFirestore.instance.collection('users').doc(widget.uid).update({'CalledHelp' : temp}).then((value) => print('Set to true')).catchError((e)=> print(e.toString()));
                  Navigator.pop(context);
                },
                child: Text('Call For Help'),
                elevation: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
