
import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_expo/services/notification.dart';
import 'package:project_expo/views/HelpDetails.dart';
import 'package:project_expo/views/dialog.dart';
import 'package:project_expo/views/sideMenu.dart';
import 'package:geocoding/geocoding.dart' as GeoCo;
import 'package:telephony/telephony.dart';


class Home extends StatefulWidget {
  final String? uid;
  const Home({Key? key, required this.uid}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool SendNotification = true;
  bool canAccessLocation = false;
  LatLng? checkLatlng;

  Map <String, dynamic>? details;
  LatLng latlng = new LatLng(10.758463206941846, 78.68146469709662);
  CameraPosition _currentPosition = new CameraPosition(target: LatLng(0,0),zoom: 15);
  String Myaddress = "";
  LatLng _searchLatLng = new LatLng(0, 0);
  String SearchAddress ="";

  List<Marker> markers = [];

  Marker search = Marker(markerId: MarkerId('Search'));
  late BitmapDescriptor mapMaker;
  late BitmapDescriptor helpMaker;

  late GoogleMapController _googleMapController;

  static final CameraPosition _initialPosition = CameraPosition(
      target: LatLng(48.858472430968696, 2.2945242136347552),
      zoom: 15);

  TextEditingController _searchLocation =  new TextEditingController();
  

  setCustomMarkers() async{
    mapMaker = await BitmapDescriptor.fromAssetImage(ImageConfiguration(), 'assets/myLocation.png');
    helpMaker = await BitmapDescriptor.fromAssetImage(ImageConfiguration(), 'assets/help_on_map.png');
  }

  updateLastCurrentLocation(LatLng l) async{
    GeoPoint cuurentpoint = GeoPoint(l.latitude, l.longitude);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .update({'Last Current Location': cuurentpoint})
        .then((value) =>{
          setState((){
         checkLatlng = l;
    })
    })
        .catchError((e) => print(e.toString()));
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
    await Telephony.instance.requestPhoneAndSmsPermissions;
  }
  getLiveLocation() async{
    try{
      await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((value) => {
        setState((){
        latlng = LatLng(value.latitude, value.longitude);
        _currentPosition = CameraPosition(target: latlng, zoom: 17);
        if(checkLatlng == latlng){
          canAccessLocation = false;
        }else{
          canAccessLocation = true;
        }

      })
      });
      setMarkers();
    }catch(e){
      print(e.toString());
    }  }

  setMarkers() async{
    await getMyAddress();
    if(_currentPosition!=null){
      markers.add(Marker(
          markerId: MarkerId('My Location'),
          position: latlng,
          icon: mapMaker,
          infoWindow: InfoWindow(title: Myaddress,),

      ));
    }
  }

  getMyAddress() async{
    List<GeoCo.Placemark> address = await GeoCo.GeocodingPlatform.instance.placemarkFromCoordinates(latlng.latitude, latlng.longitude);
    var mainAddress = address[0];

    Myaddress = mainAddress.locality.toString();

    if(mainAddress!=null){
      var MyAd;

      MyAd = "${mainAddress.subLocality}";
      MyAd = "$MyAd, ${mainAddress.locality}";
      MyAd = "$MyAd, ${mainAddress.country}";
      MyAd = "$MyAd, ${mainAddress.postalCode}";

      setState(() {
        Myaddress = MyAd;
      });

    }

  }

  getSearchAddress(LatLng searchLatLng) async{
    List<GeoCo.Placemark> address = await GeoCo.GeocodingPlatform.instance.placemarkFromCoordinates(searchLatLng.latitude, searchLatLng.longitude);
    var mainAddress = address[0];


    if(mainAddress!=null){
      var MyAd;
      MyAd = "${mainAddress.name}";
      MyAd = "$MyAd, ${mainAddress.street}";
      MyAd = "$MyAd, ${mainAddress.subLocality}";
      MyAd = "$MyAd, ${mainAddress.locality}";
      MyAd = "$MyAd, ${mainAddress.country}";
      MyAd = "$MyAd, ${mainAddress.postalCode}";

      setState(() {
        SearchAddress = MyAd;
      });

    }

  }

  getLatLng(String Place) async {
    List<GeoCo.Location> location = await GeoCo.GeocodingPlatform.instance.locationFromAddress(Place);
    // print(location);
    var searchLatLng = location[0];

    if(searchLatLng!=null){
      LatLng tempLatLng ;

      tempLatLng = new LatLng(searchLatLng.latitude, searchLatLng.longitude);

      setState(() {
        _searchLatLng = tempLatLng;
      });
    }
  }



  PlaceHelpMarkers()async{
    List<LatLng> usersNeededHelp =[];
    List<dynamic> users =[];
    await FirebaseFirestore.instance.collection('users').doc(widget.uid).get().then((snapshot) =>{
      // users = snapshot.data()?['usersNeedHelps']
     users =  snapshot.data()?['UsersNeedHelps']
    });

    if(users.isEmpty){
      print('hi');
        setState(() {
          markers =[];
          setMarkers();
        });
      return;
    }

   users.forEach((userUid)async{
      LatLng currentUsersLocation;
      await FirebaseFirestore.instance.collection('users').doc(userUid).get().then((snapshot) => {

        currentUsersLocation = LatLng(snapshot.data()?['Last Current Location'].latitude,snapshot.data()?['Last Current Location'].longitude),
        usersNeededHelp.add(currentUsersLocation),
      });
    });

    Future.delayed(Duration(seconds: 1),(){
      if(usersNeededHelp.length == 0){
        setState(() {
          SendNotification = true;

        });
        return;
      }
      for(int i=1;i<=usersNeededHelp.length;i++){
        if(SendNotification){
          createNotification();
          SendNotification = false;
        }
          markers.add(
            Marker(
              markerId: MarkerId(i.toString()),
              icon: helpMaker,
              position: usersNeededHelp[i-1],
              infoWindow: InfoWindow(title: 'I Need Help'),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => HelpDetails(uid: users[i-1],urUid: widget.uid!,urName: details?['name'],),));
              }
            ),
          );
      }
      setState(() {

      });
    });

  }

  Timer? helperTimer;
  Timer? userTimer;

  LocationTracker() async{
    await getLiveLocation();
    _googleMapController.animateCamera(CameraUpdate.newCameraPosition(_currentPosition));
    setState(() {

    });
    await updateLastCurrentLocation(latlng);
  }

  @override
  void initState() {
    // TODO: implement initState

    getLocationPermission();
    getDetails();
    setCustomMarkers();


    super.initState();
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) => {
      if(!isAllowed){
        showDialog(context: context,
            builder: (context) => AlertDialog(title: Text('Allow Notifications'),
              content: Text('Our App  would like to send you notifications'),
              actions: [
                TextButton(onPressed: (){Navigator.pop(context);}, child: Text('Don\'t Allow', style: TextStyle(color: Colors.grey, fontSize: 18),)),
                TextButton(onPressed: (){
                  AwesomeNotifications().requestPermissionToSendNotifications().then((value) => Navigator.pop(context));
                }, child: Text('Allow', style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold),))
              ],
            ))
      }
    });
    helperTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      PlaceHelpMarkers();
    });
    // userTimer = Timer.periodic(Duration(seconds: 10), (timer) async{
    //   await getLiveLocation();
    //   // _googleMapController.animateCamera(CameraUpdate.newCameraPosition(_currentPosition));
    //   if(canAccessLocation){
    //     print('updated');
    //     setState(() {
    //
    //     });
    //     await updateLastCurrentLocation(latlng);
    //   }
    // });

  }

  @override
  void dispose() {
    super.dispose();
    helperTimer?.cancel();
    userTimer?.cancel();
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(name: details?['name'], email: details?['email'], uid: widget.uid,),
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

              markers: Set.of(markers),
              myLocationButtonEnabled: false,
              onMapCreated: (GoogleMapController controller) =>{
                _googleMapController = controller,
              },
            ),
            Container(
              margin: EdgeInsets.only(top: 10, left: 10,right: 10),
                child: TextFormField(
                  controller: _searchLocation,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: () async{
                        await getLatLng(_searchLocation.text);
                        await getSearchAddress(_searchLatLng);
                        search = Marker(
                          markerId: MarkerId('Search'),
                          position: _searchLatLng,
                          infoWindow: InfoWindow(title: SearchAddress),

                        );
                        markers.add(search);
                        _googleMapController.animateCamera(
                            CameraUpdate.newCameraPosition(new CameraPosition(target: _searchLatLng,zoom: 15)));
                        print(SearchAddress);
                      },
                      icon: Icon(Icons.search),
                    ),
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
            Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height-170, left: 10),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(50),
                shape: BoxShape.rectangle
              ),
              child: MaterialButton(
                onPressed: (){
                  showDialog(context: context, builder: (context) => Box(uid: widget.uid,details: details,),);
                },
                child: Text(
                  'Help',
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'direction',
            onPressed: (){
              // PlaceHelpMarkers();
              setState(() {
                markers = [];
                setMarkers();
              });
            },
            child: Icon(Icons.directions),
          ),
          SizedBox(height: 20,),
          FloatingActionButton(
            heroTag: 'location',
            child: Icon(Icons.my_location_outlined),
            onPressed: () async{
              setState(() {
                if(!canAccessLocation){
                  canAccessLocation = true;
                }
              });

              getLocationPermission();
              await LocationTracker();
              setState(() {
                checkLatlng = latlng;
              });
              // print(_searchLatLng);
            },
          ),
        ],
      ),
    );
  }
}


