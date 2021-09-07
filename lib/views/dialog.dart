import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:project_expo/Autentication/location.dart';


class Box extends StatefulWidget {
  final String? uid;
  const Box({Key? key, required this.uid}) : super(key: key);
  @override
  _BoxState createState() => _BoxState();
}

class _BoxState extends State<Box> {

  @override
  void initState() {
    getLiveLocation();
    super.initState();
  }

  LatLng _latLng = new LatLng(0, 0);

  getLiveLocation() async {
    try {
      await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high).then((value) =>
      {
        setState(() {
          _latLng = LatLng(value.latitude, value.longitude);
        })
      });
    } catch (e) {
      print(e.toString());
    }
  }

  List<String> usersNear = [];

  getUsersNear() async{
    final QuerySnapshot result = await FirebaseFirestore.instance.collection('users').get();
    final List<QueryDocumentSnapshot<Object?>> document = result.docs;
    document.forEach((element) {
      LatLng temp = LatLng(element['Last Current Location'].latitude, element['Last Current Location'].longitude);
      if(distanceBetweenUsers(_latLng, temp) < 2000 && element.id != widget.uid){
        setState(() {
          usersNear.add(element.id);
        });

      }
      // print(distanceBetweenUsers(_latLng, temp));
    });


  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext){
    return Container(
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
                Icon(Icons.warning_amber_rounded,color: Colors.red,),
                Text('Emergengy',style: TextStyle(
                  color: Colors.red,
                ),),
              ],
            ),
          ),
          Container(
              margin: EdgeInsets.all(40),
              child: Text(
                'Are You Sure to Call for Help, Your Location will be sent to people nearby',
                style: TextStyle(
                    fontSize: 20
                ),
              )
          ),

          Container(
            decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(60),
                color: Colors.lightBlue
            ),
            child: MaterialButton(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 16),
              onPressed: () async{
                await getUsersNear();
                print(usersNear);
                Navigator.pop(context);
              },
              child: Text('Call For Help'),
              elevation: 1.0,
            ),
          ),

        ],
      ),
    );
  }
}
