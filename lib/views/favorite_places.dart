import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as GeoCo;
import 'package:project_expo/views/CardView.dart';


class FavPlace extends StatefulWidget {
  final String? uid;
  const FavPlace({Key? key, required this.uid}) : super(key: key);

  @override
  _FavPlaceState createState() => _FavPlaceState();
}

class _FavPlaceState extends State<FavPlace> {

  LatLng _searchLatLng = new LatLng(0,0);

  TextEditingController _search = new TextEditingController();
  String SearchAddress ="";

  late GoogleMapController _googleMapController;
  List<Marker> markers = [];
  static final CameraPosition _initialPosition = CameraPosition(
      target: LatLng(48.858472430968696, 2.2945242136347552),
      zoom: 15);

  Marker search = Marker(markerId: MarkerId('Search'));

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



  List<dynamic> favPlaces = [];
  @override
  void initState(){
    // TODO: implement initState
    retriveData();
    super.initState();

  }

  addFavoriteLocation()async{
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .update({'Favorite Places' : favPlaces})
        .then((value) => print('added'))
        .catchError((e) => print(e.toString()));
  }

   retriveData()async{
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) => {
          setState((){
            favPlaces = documentSnapshot.get('Favorite Places');
          }),
          print(favPlaces)
    }).catchError((e) => print(e.toString()));
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Add Routine Places',
        ),
        elevation: 10.0,
      ),
      body: Stack(
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
            margin: EdgeInsets.only(top: MediaQuery.of(context).size.height-520,left: 10, right: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft:Radius.circular(20), topRight: Radius.circular(20)),
              boxShadow: [BoxShadow(
                blurRadius: 10.0,
                offset: Offset(5,3),
                color: Colors.grey.withOpacity(.7),
              )],
            ),
            child: Column(
              children: [
                Container(
                  margin:EdgeInsets.only(top: 20,left: 20,right: 20) ,
                  child: TextFormField(
                    controller: _search,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () async{
                          await getLatLng(_search.text);
                          await getSearchAddress(_searchLatLng);
                          search = Marker(
                            markerId: MarkerId('Search'),
                            position: _searchLatLng,
                            infoWindow: InfoWindow(title: SearchAddress),

                          );
                          markers.add(search);
                          _googleMapController.animateCamera(
                              CameraUpdate.newCameraPosition(new CameraPosition(target: _searchLatLng,zoom: 15)));
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
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  margin: EdgeInsets.only(left: MediaQuery.of(context).size.width/3 +40, top: 10, right: 20),
                  padding: EdgeInsets.only(left: 10),
                  child: MaterialButton(
                    onPressed: () async{
                      setState(() {
                        favPlaces.add(GeoPoint(_searchLatLng.latitude, _searchLatLng.longitude));
                      });

                      await addFavoriteLocation();
                      // print(favPlaces);


                    },
                    child: Row(
                      children: [
                        SizedBox(width: 20,),
                        Icon(Icons.add),
                        Text(
                          'Add to List',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                    child:ListView.builder(
                      itemCount: favPlaces.length,
                      itemBuilder: (context, index){
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3,horizontal: 7),
                          child: Card(
                            child: LocationName(latlng: LatLng(favPlaces[index].latitude,favPlaces[index].longitude)),
                          ),
                        );
                      },
                    )
                ),
              ],
            ),
          ),
        ],

      ),
    );
  }
}
