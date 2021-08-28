import 'package:firebase_auth/firebase_auth.dart';

Future <dynamic> SignUpWith(String email, String password) async{
  User? user;
  try{
    user = (await FirebaseAuth
        .instance
        .createUserWithEmailAndPassword(email: email, password: password)).user;
    await FirebaseAuth
        .instance
        .signInWithEmailAndPassword(email: email, password: password);
    return user;
  }catch(e){
    print(e.toString());
    return user;
  }
}

Future <bool> SignInWith(String email, String password) async{
  try{
    await FirebaseAuth
        .instance
        .signInWithEmailAndPassword(email: email, password: password);
    return true;

  }catch(e){
    print(e.toString());
    return false;
  }
}

Future <void> SignOut() async{
  try{
    await FirebaseAuth.instance.signOut();
  }catch(e){
    print(e.toString());
  }
}