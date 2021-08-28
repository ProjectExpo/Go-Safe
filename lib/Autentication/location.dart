import 'package:geolocator/geolocator.dart';

Future <Position> getLiveLocation() async{
  // bool isServiceEnabled;
  // LocationPermission permission;

  // isServiceEnabled = await Geolocator.isLocationServiceEnabled();
  // if(!isServiceEnabled){
  //   return Future.error('Location is disabled');
  // }

  // permission = await Geolocator.checkPermission();
  // if(permission == LocationPermission.denied){
  //   permission = await Geolocator.requestPermission();
  //   if(permission == LocationPermission.denied){
  //     return Future.error('permission denied');
  //   }
  // }
  // if(permission == LocationPermission.deniedForever){
  //   return Future.error('Permmission denied forever');
  // }

  return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}