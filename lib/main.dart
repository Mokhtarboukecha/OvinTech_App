
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_new_app/addbreed.dart';
import 'package:my_new_app/addsheep.dart';
import 'package:my_new_app/breed.dart';
import 'package:my_new_app/fpassword.dart';
import 'package:my_new_app/homepage.dart';
import 'package:my_new_app/login.dart';
import 'package:my_new_app/sheep.dart';
import 'package:my_new_app/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_new_app/vac/addvac.dart';
import 'package:my_new_app/vac/homevac.dart';
import 'package:my_new_app/vac/list_sheep_vac.dart';
import 'package:my_new_app/vac/listvac.dart';
import 'package:my_new_app/vac/vaccination.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    
  );
  runApp(MyApp());

}
class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();  
  }
  class _MyAppState extends State<MyApp>{

    @override
  void initState() {
    FirebaseAuth.instance
  .authStateChanges()
  .listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });
    super.initState();
  }
    
  @override
  Widget build(BuildContext context){
    return   MaterialApp(
      debugShowCheckedModeBanner:false,
      home:Login(),
      routes: {
        "home":(context)=>Login(),
        "signup":(context)=>Signup(),
        "fpassword":(context)=>Fpassword(),
        "homepage":(context)=>Homepage(),
        "breed":(context)=>Breed(),
        "addbreed":(context)=>Addbreed(),
        "sheep":(context)=>Sheep(),
        "homevac":(context)=>Homevac(),
        "listvac":(context)=>Listvac(),
        "addvac":(context)=>Addvac(),
        "vaccination":(context)=>Vaccination(),
        "list_sheep_vac":(context)=>ListSheepVac(),
        "addsheep":(context)=>Addsheep(),
      },
    );
      
    
  }
  }
  