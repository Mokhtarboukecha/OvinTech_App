import 'package:flutter/material.dart';

class Fpassword extends StatefulWidget {
  const Fpassword({super.key});

  @override
  State<Fpassword> createState() => _FpasswordState();
}

class _FpasswordState extends State<Fpassword> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp( debugShowCheckedModeBanner:false,
      home: Scaffold( backgroundColor: Colors.white,
      body:SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: Column( children: [
        SizedBox(height: 80,),
        Align(alignment:Alignment.topLeft,
        child :Text("Rest your Password",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)),
        SizedBox(height: 15,),
        Text("Please enter your registered email address. We will send you instructions to reset your password.",style: TextStyle(color: Colors.grey,fontSize: 15),),
        SizedBox(height: 15,),
        TextField(decoration: InputDecoration(label: Text("Email")),),
        SizedBox(height: 15,),
        MaterialButton(color: Colors.blueAccent,textColor: Colors.white,minWidth:300.0,height: 50 ,shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(30)) ,onPressed:(){},child: Text("Reset Password",),),
        SizedBox(height: 15,),
        Row(mainAxisAlignment: MainAxisAlignment.center,children: [Text("← Back to"),MaterialButton(onPressed: (){Navigator.of(context).pushNamed("home");},textColor: Colors.blueAccent,child: Text("LOGIN PAGE"),)],) 

        ],

        ),
      )
      ),
    );
  }
}