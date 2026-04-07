/*import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // أضف هذا السطر

class Addvac extends StatefulWidget {
  const Addvac({super.key});

  @override
  State<Addvac> createState() => _AddvacState();
}

class _AddvacState extends State<Addvac> {
  @override
  Widget build(BuildContext context) {
    return Scaffold( backgroundColor: Colors.white,
    appBar: AppBar(title: Text("Add New Vaccine" ,style: TextStyle(color:Colors.white),),
    
    backgroundColor:Color.fromARGB(255,120,173,80),),
    body:SingleChildScrollView( padding: EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        
        children: [ const SizedBox(height: 35),
        Align( alignment: Alignment.centerLeft,
          child: 
          Text("New Vaccine Details", style: TextStyle(color: Color.fromARGB(255,120,173,80),fontSize: 20),),)
          , SizedBox(height: 50),
          TextField(
            
              decoration: const InputDecoration(label: Text("Vaccine Name")),
            ),
            SizedBox(height: 20),//Expanded( child:
          /*Text("Given Every" ,style: TextStyle(color:Colors.blueGrey)),SizedBox(width:7),TextField(
  keyboardType: TextInputType.number, // لإظهار لوحة مفاتيح الأرقام فقط
  decoration: InputDecoration(
    //labelText: "أدخل عدداً طبيعياً",
    border: OutlineInputBorder(),
  ),
  inputFormatters: [
    // هذا الفلتر يمنع إدخال أي شيء عدا الأرقام (0-9)
    FilteringTextInputFormatter.digitsOnly,
  ],
),Text("Days")*/
// ... (بقيمة الأكواد بالأعلى)
            const SizedBox(height: 20),
            Row(
              children: [
                const Text("Given Every", style: TextStyle(color: Colors.blueGrey)),
                const SizedBox(width: 7),
                
                // الحل هنا: تغليف الحقل بـ Expanded أو SizedBox
                Expanded( 
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "0",
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
                
                const SizedBox(width: 7),
                const Text("Days", style: TextStyle(color: Colors.blueGrey)),
              ],
            ),
// ... (بقية الكود)
          
      ]),
    ) ,
    bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: MaterialButton(
          color: const Color.fromARGB(255, 120, 173, 80),
          textColor: Colors.white,
          minWidth: double.infinity,
          height: 55,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          onPressed: () {
            // كود الحفظ ثم العودة
            Navigator.pop(context);
          },
          child: const Text("SAVE VACCINE"),
        ),
      ),
    
    );
  
  }
}*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Addvac extends StatefulWidget {
  const Addvac({super.key});

  @override
  State<Addvac> createState() => _AddvacState();
}

class _AddvacState extends State<Addvac> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveVaccine() async {
    if (_nameController.text.isEmpty || _daysController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await http.post(
      Uri.parse('http://192.168.1.3:8000/api/vaccines/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': _nameController.text,
        'given_every_days': int.parse(_daysController.text),
      }),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 201) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error saving vaccine"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Add New Vaccine",
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 120, 173, 80),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 35),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("New Vaccine Details",
                  style: TextStyle(
                      color: Color.fromARGB(255, 120, 173, 80),
                      fontSize: 20)),
            ),
            const SizedBox(height: 50),
            TextField(
              controller: _nameController,
              decoration:
                  const InputDecoration(label: Text("Vaccine Name")),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text("Given Every",
                    style: TextStyle(color: Colors.blueGrey)),
                const SizedBox(width: 7),
                Expanded(
                  child: TextField(
                    controller: _daysController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "0",
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10),
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
                const SizedBox(width: 7),
                const Text("Days",
                    style: TextStyle(color: Colors.blueGrey)),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: MaterialButton(
          color: const Color.fromARGB(255, 120, 173, 80),
          textColor: Colors.white,
          minWidth: double.infinity,
          height: 55,shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          onPressed: _isLoading ? null : _saveVaccine,
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("SAVE VACCINE"),
        ),
      ),
    );
  }
}