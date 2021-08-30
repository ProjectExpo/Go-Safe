
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_expo/views/dialog.dart';
import 'package:project_expo/views/sideMenu.dart';


class Home extends StatefulWidget {
  final String? uid;
  const Home({Key? key, required this.uid}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Map <String, dynamic>? details;
  LatLng latlng = new LatLng(0, 0);
  CameraPosition _currentPosition = new CameraPosition(target: LatLng(0,0),zoom: 15);

  List<Marker> markers = [];
  late BitmapDescriptor mapMaker;

  late GoogleMapController _googleMapController;

  static final CameraPosition _initialPosition = CameraPosition(
      target: LatLng(48.858472430968696, 2.2945242136347552),
      zoom: 15);

  TextEditingController _searchLocation =  new TextEditingController();

  setCustomMarkers() async{
    mapMaker = await BitmapDescriptor.fromAssetImage(ImageConfiguration(), 'assets/myLocation.png');
  }


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
  getLiveLocation() async{
    try{
      await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((value) => {
        setState((){
        latlng = LatLng(value.latitude, value.longitude);
        _currentPosition = CameraPosition(target: latlng, zoom: 17);

      })
      });
      setMarkers();
    }catch(e){
      print(e.toString());
    }
  }

  setMarkers(){
    if(_currentPosition!=null){
      markers.add(Marker(
          markerId: MarkerId('My Location'),
          position: latlng,
          icon: mapMaker,

      ));
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    getLocationPermission();
    getDetails();
    setCustomMarkers();
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
              initialCameraPosition: _initialPosition,
              mapType: MapType.terrain,
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) => _googleMapController = controller,
              markers: Set.of(markers),
            ),
            Container(
              margin: EdgeInsets.only(top: 10, left: 10,right: 10),
                child: TextFormField(
                  controller: _searchLocation,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: (){},
                      icon: Icon(Icons.search),
                    ),
                    hintText: 'Search',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.5),
                    contentPadding: EdgeInsets.only(left: 30),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
            ),
            Container(
              margin: EdgeInsets.only(top: 650, left: 10),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
                shape: BoxShape.rectangle
              ),
              child: MaterialButton(
                onPressed: (){
                  showDialog(context: context, builder: (context) => Box(),);
                },
                child: Text(
                  'SOS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20
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
          await getLiveLocation();
          _googleMapController.animateCamera(CameraUpdate.newCameraPosition(_currentPosition));
          
          print(latlng);
        },
      ),
    );
  }
}


