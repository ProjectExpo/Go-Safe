import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as GeoCo;

class LocationName extends StatefulWidget {
  final LatLng latlng;
  const LocationName({Key? key, required this.latlng}) : super(key: key);

  @override
  _LocationNameState createState() => _LocationNameState();
}

class _LocationNameState extends State<LocationName> {
  String Address="";

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
        Address = MyAd;
      });

    }

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSearchAddress(widget.latlng);
  }

  @override
  Widget build(BuildContext context) {


    return ListTile(
      leading: Icon(Icons.place),
      title: Text(
        Address,
      ),
    );
  }
}
