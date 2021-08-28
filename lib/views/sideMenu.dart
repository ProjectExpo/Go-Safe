import 'package:flutter/material.dart';

class NavDrawer extends StatefulWidget {
  final String? name;
  final String? email;
  const NavDrawer({Key? key, required this.name, required this.email}) : super(key: key);

  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
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
              onTap: (){},
              leading: Icon(Icons.favorite,color: Colors.white,size: 30,),
              title: Text(
                'Favorite Places',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),


          ],
        ),
      ),
    );
  }
}

