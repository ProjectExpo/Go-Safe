import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_expo/Autentication/auth.dart';
import 'package:project_expo/constants/color.dart';
import 'package:project_expo/views/Home.dart';
import 'package:project_expo/views/Register.dart';

class LogIn extends StatefulWidget {
  const LogIn({Key? key}) : super(key: key);

  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {

  String? _userid;

  TextEditingController _email = new TextEditingController();
  TextEditingController _password = new TextEditingController();


  final _formKey = GlobalKey<FormState>();
  String error = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 50,left: 10),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  child: Image(image: AssetImage("assets/mapIcon.gif"),),
                ),
                Text(
                    'Go Safe',
                  style: TextStyle(
                    fontFamily: 'Lobster',
                    fontSize: 45,
                    fontWeight: FontWeight.w500,

                  ),
                ),
                Text(
                  error,
                  style: TextStyle(
                    color: Colors.redAccent
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20, top: 10),
                  child: TextFormField(
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return 'This Field Can\'t be empty';
                      }
                    },
                    controller: _email ,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      labelText: 'Email',
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: TextFormField(
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return 'This Field Can\'t be empty';
                      }
                    },
                    controller: _password ,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.password),
                      labelText: 'Password',
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 25),
                  child: MaterialButton(
                    padding: EdgeInsets.only(top: 10, bottom: 10,left: 30,right: 30),
                    color: black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                      onPressed: () async{
                        if(_formKey.currentState!.validate()){
                          dynamic isRegistered= await SignInWith(_email.text, _password.text);
                          if(isRegistered.runtimeType.toString() == 'String'){
                              setState(() {
                                error= "Invalid Credentials";
                              });
                            return;
                          }
                          if(isRegistered){

                            setState(() {
                              _userid =FirebaseAuth.instance.currentUser!.uid;
                              error ="";
                            });
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home(uid: _userid),));
                          }
                        }

                      },
                      child: Text(
                          'Login',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                  ),
                ),
                TextButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Register(),));
                  },
                  child: Text('New User? Register Now'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
