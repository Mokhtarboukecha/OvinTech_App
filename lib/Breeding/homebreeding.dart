import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_new_app/vac/homevac.dart'; 
import 'package:my_new_app/vac/list_sheep_vac.dart';


class Homebreeding extends StatefulWidget {
  const Homebreeding({super.key});

  @override
  State<Homebreeding> createState() => _HomebreedingState();
}

class _HomebreedingState extends State<Homebreeding> {
  Widget buildDashboardItem(String title, IconData icon, Color color, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: color, // اللون الأخضر الذي اخترته
        borderRadius: BorderRadius.circular(15), // تدوير الحواف كما في الصورة
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.white), // الأيقونة بيضاء
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold( backgroundColor: Colors.white,
      appBar: AppBar( iconTheme: IconThemeData(color: Colors.white),
        title: Text("Dashboard",style: TextStyle(color: Colors.white,)),backgroundColor:Color.fromARGB(255,120,173,80),
      shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(0), 
      ),
    ),),
      drawer: Drawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all( 20),
        child:
        Column(
          children: [
            GridView.count(
              shrinkWrap: true, // مهم جداً: يجعل الشبكة تأخذ مساحة العناصر فقط
              physics: const NeverScrollableScrollPhysics(), // تعطيل التمرير الداخلي للشبكة
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.1, // للتحكم في طول المربع (عرض/طول)
              children: [
                buildDashboardItem("Breeding sheeps", FontAwesomeIcons.venusMars, const Color.fromARGB(255,120,173,80), () {Navigator.of(context).pushNamed("breeding");}),
                buildDashboardItem("list Breedig",FontAwesomeIcons.list, const Color.fromARGB(255,120,173,80), () {Navigator.of(context).pushNamed("listbreeding");}),
                //buildDashboardItem("Vaccine record",FontAwesomeIcons.googleDrive , const Color.fromARGB(255,120,173,80), () {Navigator.of(context).pushNamed("list_sheep_vac");}),
              
              ],
            ),
          ],
        ),




      
      ),);
  }
}