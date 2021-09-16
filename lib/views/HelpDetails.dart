import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_expo/views/CardView.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpDetails extends StatefulWidget {
  final String uid;
  const HelpDetails({Key? key, required this.uid}) : super(key: key);

  @override
  _HelpDetailsState createState() => _HelpDetailsState();
}

class _HelpDetailsState extends State<HelpDetails> {

  Color whiteNeu = new Color(0xffecf0f3);
  static final CameraPosition _initialPosition = CameraPosition(target: LatLng(48.858472430968696, 2.2945242136347552),zoom: 14);

  Map<String, dynamic>? details;

  GetDetails() async{
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

  _makePhoneCall(String num) async{
    await launch('tel://$num');
  }

  _makeMessage(String num) async{
    await launch('sms:$num');
  }

  @override
  void initState() {
    GetDetails();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Help Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 13, horizontal: 13),
              margin: EdgeInsets.symmetric(vertical: 35, horizontal: 30),
              decoration: BoxDecoration(
                color: whiteNeu,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xffd1d9e6),
                    blurRadius: 20,
                    offset: Offset(
                      10,
                      10,
                    ),
                  ),
                ]
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:NetworkImage('https://cdn5.vectorstock.com/i/1000x1000/48/89/man-character-avatar-in-flat-design-vector-10834889.jpg',),
                  ),
                  SizedBox(width: 20,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        details?['name'],
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w500

                        ),
                      ),
                      SizedBox(height: 5,),
                      Text(
                        details?['email'],
                        style: TextStyle(
                          fontSize: 16
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 2, horizontal: 30),
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: MaterialButton(
                        onPressed: (){
                          _makePhoneCall(details?['Phone Number']);
                        },
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 45),
                      child: Row(
                        children: [
                          Text('Call',style: TextStyle(fontSize: 17),),
                          Icon(Icons.call)
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(20)
                    ),
                    child: MaterialButton(
                      onPressed: (){
                        _makeMessage(details?['Phone Number']);
                      },
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 35),
                      child: Row(
                        children: [
                          Text('Message',style: TextStyle(fontSize: 17),),
                          Icon(Icons.message_rounded)
                        ],
                      ),
                    ),
                  ),

                ],
              ),
            ),

            Container(
              padding: EdgeInsets.symmetric(vertical: 13, horizontal: 13),
              margin: EdgeInsets.symmetric(vertical: 35, horizontal: 30),
              decoration: BoxDecoration(
                  color: whiteNeu,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xffd1d9e6),
                      blurRadius: 20,
                      offset: Offset(
                        -10,
                        10,
                      ),
                    ),
                  ]
              ),
              child: Column(
                crossAxisAlignment:  CrossAxisAlignment.start,
                children: [
                  Container(
                      margin: EdgeInsets.only(left: 10, top: 5),
                      child: Text('Last Seen Location',
                        style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w500
                        ),)
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5, top: 5, right: 5),

                    child: SizedBox(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.lightBlueAccent,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(target: LatLng(details?['Last Current Location'].latitude,details?['Last Current Location'].longitude),zoom: 15),
                          markers: {Marker(markerId: MarkerId("Location"),position: LatLng(details?['Last Current Location'].latitude,details?['Last Current Location'].longitude))},
                        ),
                      ),
                      height: MediaQuery.of(context).size.height/3,
                      width: MediaQuery.of(context).size.width/0.7,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 13, horizontal: 13),
              margin: EdgeInsets.symmetric(vertical: 35, horizontal: 30),
              decoration: BoxDecoration(
                  color: whiteNeu,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xffd1d9e6),
                      blurRadius: 20,
                      offset: Offset(
                        -10,
                        10,
                      ),
                    ),
                  ]
              ),
              child: Column(
                children: [
                  Container(
                    margin:EdgeInsets.only(top: 10, right: 50,bottom: 10) ,
                    child: Text(
                      'Frequently Visited Places',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 23
                      ),
                    ),
                  ),
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: details?['Favorite Places'].length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: LocationName(latlng: LatLng(details?['Favorite Places'][index].latitude, details?['Favorite Places'][index].longitude)),
                      );
                    },
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 13, horizontal: 13),
              margin: EdgeInsets.symmetric(vertical: 35, horizontal: 30),
              decoration: BoxDecoration(
                  color: whiteNeu,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xffd1d9e6),
                      blurRadius: 20,
                      offset: Offset(
                        -10,
                        10,
                      ),
                    ),
                  ]
              ),
              child: Column(
                children: [
                  Container(
                    margin:EdgeInsets.only(top: 10, right: 50,bottom: 10) ,
                    child: Text(
                      'Emergency Contacts',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 23
                      ),
                    ),
                  ),
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: details?['Emergency Contacts'].length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(
                            details?['Emergency Contacts'][index]['Name'],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),),
                          subtitle: Text(
                            details?['Emergency Contacts'][index]['Phone Number'],
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 2
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: (){
                              _makePhoneCall(details?['Emergency Contacts'][index]['Phone Number']);
                            },
                            icon: Icon(Icons.add_call),
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
