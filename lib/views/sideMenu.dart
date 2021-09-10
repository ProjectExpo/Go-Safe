import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_expo/Autentication/auth.dart';
import 'package:project_expo/views/HelpMode.dart';
import 'package:project_expo/views/favorite_places.dart';
import 'Home.dart';


class NavDrawer extends StatefulWidget {
  final String? name;
  final String? email;
  final String? uid;
  const NavDrawer({Key? key, required this.name, required this.email, required this.uid}) : super(key: key);

  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {

  Map<String, dynamic>? details;

  getHelpCalled() async{
    await FirebaseFirestore.instance.collection('users').doc(widget.uid).get().then((DocumentSnapshot<Map<String,dynamic>> snapshot) =>{
      if(snapshot.exists){
        setState((){
          details = snapshot.data();
        })

      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.blue,
        child: ListView(
          children: [
            Container(
              child: Image(
                  image: AssetImage('assets/driving.gif')),
            ),
            SizedBox(height: 20,),
            Divider(height: 10,color: Colors.white,indent: 10, endIndent: 10,),
            SizedBox(height: 10,),
            ListTile(
              onTap: (){},
              leading: Icon(Icons.person,color: Colors.white,size: 35,),
              title: Text(
                widget.name.toString(),
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                widget.email.toString(),
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => FavPlace(uid: widget.uid,)));
              },
              leading: Icon(Icons.favorite,color: Colors.white,size: 30,),
              title: Text(
                'Favorite Places',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            ListTile(
              onTap: ()async{
                await getHelpCalled();
                Navigator.push(context, MaterialPageRoute(builder: (context) => HelpMode(uid: widget.uid!, details: details,)));
              },
              leading: Icon(Icons.volunteer_activism, color: Colors.white,size: 30,),
              title: Text(
                'Help Mode',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: 250),
              child: Column(
                children: [
                  Divider(height: 10,color: Colors.white,indent: 10, endIndent: 10,thickness: 1.2,),
                  ListTile(
                    onTap: (){
                      SignOut();
                      Navigator.pop(context);
                      Navigator.pop(context);

                    },
                    leading: Icon(Icons.exit_to_app, color: Colors.white,size: 30,),
                    title: Text(
                      'Log Out',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),


          ],
        ),
      ),
    );
  }
}

