import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_expo/Autentication/auth.dart';
import 'package:project_expo/Autentication/firebaseStore.dart';
import 'package:project_expo/constants/color.dart';
import 'package:project_expo/views/Home.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  String? _userid;

  TextEditingController _email = new TextEditingController();
  TextEditingController _name = new TextEditingController();
  TextEditingController _password = new TextEditingController();
  TextEditingController _cpassword = new TextEditingController();
  TextEditingController _number = new TextEditingController();

  GeoPoint g = GeoPoint(0,0);

  void addUser(){
    List<dynamic> listOfUsers = [];
    bool isHelpNeeded = false;
    Map<String,dynamic> userData={'email': _email.text, 'name': _name.text, 'Phone Number': _number.text,'Last Current Location': g,'isHelpNeeded': isHelpNeeded,'UsersNeedHelps': listOfUsers, 'CalledHelp': isHelpNeeded};
    FirebaseFirestore
        .instance
        .collection("users")
        .doc(_userid)
        .set(userData);
    print('added');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 70, left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 120),
                child: Text(
                  'Go Safe',
                  style: TextStyle(
                    fontFamily: 'Lobster',
                    fontSize: 45,
                    fontWeight: FontWeight.w500,

                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 20, right: 20, top: 100),
                child: TextFormField(
                  controller: _email,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    labelText: 'Email',
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 20, right: 20, top: 25),
                child: TextFormField(
                  controller: _name,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    labelText: 'User Name',
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 20, right: 20, top: 25),
                child: TextFormField(
                  controller: _number,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.phone),
                    labelText: 'Contact Number',
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 20, right: 20, top: 25),
                child: TextFormField(
                  obscureText: true,
                  controller: _password,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.password),
                    labelText: 'Password',
                  ),
                ),
              ),

              Container(
                margin: EdgeInsets.only(left: 20, right: 20, top: 25),
                child: TextFormField(
                  obscureText: true,
                  controller: _cpassword,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.password_rounded),
                    labelText: 'Confirm Password',
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 30,left: 120),
                child: MaterialButton(
                  padding: EdgeInsets.only(top: 10, bottom: 10,left: 30,right: 30),
                  color: black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  onPressed: () async{
                    User user = await SignUpWith(_email.text, _password.text);
                    if(user!= null){
                      setState(() {
                        _userid = user.uid;
                      });
                      addUser();
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Home(uid: _userid,),));
                    }
                  },
                  child: Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 70),
                child: TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text('Already have an account? Sign In'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
