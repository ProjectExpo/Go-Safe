import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EmergencyContact extends StatefulWidget {
  final String? uid;
  const EmergencyContact({Key? key, required this.uid}) : super(key: key);

  @override
  _EmergencyContactState createState() => _EmergencyContactState();
}

class _EmergencyContactState extends State<EmergencyContact> {

  TextEditingController _name = new TextEditingController();
  TextEditingController _phNumber = new TextEditingController();

  List<dynamic> contacts =[];

  final _formKey = GlobalKey<FormState>();


  AddNumber(String name, String phNum) async{
    contacts.add({'Name' : name, 'Phone Number': phNum });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .update({'Emergency Contacts' : contacts})
        .then((value) {
          _name.text = "";
          _phNumber.text ="";
        })
        .catchError((e)=> print(e.toString()));
  }

  retriveData()async{
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) => {
      setState((){
        contacts = documentSnapshot.get('Emergency Contacts');
      }),
      print(contacts)
    }).catchError((e) => print(e.toString()));
  }

  DeleteNumber(int index) async{
    setState(() {
      contacts.removeAt(index);
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .update({'Emergency Contacts' : contacts})
        .then((value) {
      print('deleted number');
    })
        .catchError((e)=> print(e.toString()));

  }


  @override
  void initState() {
    super.initState();
    retriveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Contacts'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Form(
            key: _formKey,
            child: Container(
              margin : EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                color: new Color(0xffecf0f3),
                borderRadius: BorderRadius.circular(20),
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
                      child: TextFormField(
                        validator: (value) {
                          if(value == null || value.isEmpty){
                            return "This Field Can\'t be empty";
                          }
                        },
                        controller: _name,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person_add_alt_1),
                          labelText: 'Name',

                        ),
                      )),
                  SizedBox(height: 10,),
                  Container(
                      child: TextFormField(
                        validator: (value) {
                          if(value == null || value.isEmpty){
                            return "This Field Can\'t be empty";
                          }
                          if(!RegExp("[0-9]{10}").hasMatch(value)){
                            return "Enter Valid Number";
                          }
                        },
                        controller: _phNumber,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.phone_iphone_outlined),
                          labelText: 'Phone Number',

                        ),
                      )),
                  SizedBox(height: 20,),
                  Container(
                    margin: EdgeInsets.only(left: MediaQuery.of(context).size.width/1.8),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: MaterialButton(
                        onPressed: (){
                          if(_formKey.currentState!.validate()){
                            AddNumber(_name.text, _phNumber.text);
                          }
                          // print(contacts[0]['Name']);
                        },
                      child: Text(
                        'Add',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            child: Expanded(
              child: ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    decoration: BoxDecoration(
                        color: new Color(0xffecf0f3),
                        borderRadius: BorderRadius.circular(20),
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
                    child: ListTile(
                      title: Text(contacts[index]['Name'],
                        style: TextStyle(
                          fontSize: 18,
                        ),),
                      subtitle: Text(contacts[index]['Phone Number'],
                      style: TextStyle(
                        fontSize: 15,
                        letterSpacing: 1
                      ),),
                      trailing: IconButton(
                        onPressed: (){
                          DeleteNumber(index);
                        },
                        icon: Icon(Icons.delete, color: Colors.redAccent,),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
