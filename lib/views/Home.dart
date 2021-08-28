

import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:project_expo/Autentication/location.dart';
import 'package:project_expo/models/UserDetails.dart';
import 'package:project_expo/views/sideMenu.dart';


class Home extends StatefulWidget {
  final String? uid;
  const Home({Key? key, required this.uid}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  late Position _currentLocation;
  Map <String, dynamic>? details;

  double latitude = 10.757574;
  double longitude = 78.683008;

  TextEditingController _searchLocation =  new TextEditingController();

  getDetails(){
    setState(() {
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get()
          .then((DocumentSnapshot<Map<String,dynamic>> snapshot) => {
            if(snapshot.exists){
              setState((){
                details =snapshot.data();
              })
            }
      });
    });

    print(details);

  }


  getLocationPermission() async{
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied){
        return Future.error('permission denied');
      }
    }
  }



  @override
  void initState() {
    // TODO: implement initState
    getLocationPermission();
    getDetails();
    super.initState();


  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(name: details?['name'], email: details?['email'],),
      appBar: AppBar(

        // automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Go Safe',
          style: TextStyle(
            fontFamily: 'Lobster',
            fontSize: 30,
            fontWeight: FontWeight.w500,
          ),
        ),
        elevation: 10.0,
      ),
      body: Container(
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(target: LatLng(latitude, longitude), zoom: 16),
              mapType: MapType.terrain,
              zoomControlsEnabled: false,

            ),
            Container(
              margin: EdgeInsets.only(top: 10, left: 10,right: 10),
                child: TextFormField(
                  controller: _searchLocation,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.only(left: 30),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.my_location_outlined),
        onPressed: () async{
          getLocationPermission();
          Position location = await getLiveLocation();
          setState((){
            _currentLocation =  location;
            latitude = _currentLocation.latitude;
            longitude = _currentLocation.longitude;
          });
          print(_currentLocation.toJson());

        },
      ),
    );
  }
}


