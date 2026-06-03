import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_new_app/Granary/addgranary.dart'; 
import 'package:my_new_app/Granary/listgranary.dart';


class Homegranary extends StatefulWidget {
  const Homegranary({super.key});

  @override
  State<Homegranary> createState() => _HomegranaryState();
}

class _HomegranaryState extends State<Homegranary> {
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
                buildDashboardItem("List granary", FontAwesomeIcons.list, const Color.fromARGB(255,120,173,80), () {Navigator.of(context).pushNamed("listgranary");}),
                //buildDashboardItem("Vaccination sheep",FontAwesomeIcons.add, const Color.fromARGB(255,120,173,80), () {Navigator.of(context).pushNamed("vaccination");}),
                //buildDashboardItem("Vaccine record",FontAwesomeIcons.googleDrive , const Color.fromARGB(255,120,173,80), () {Navigator.of(context).pushNamed("list_sheep_vac");}),
               // buildDashboardItem("Weight",FontAwesomeIcons.weightScale , const Color.fromARGB(255,120,173,80), () {}),
                //buildDashboardItem("Granary",FontAwesomeIcons.buildingWheat , const Color.fromARGB(255,120,173,80), () {}),
                buildDashboardItem("Add Granary",Icons.add , const Color.fromARGB(255,120,173,80), () {Navigator.of(context).pushNamed("addgranary");}),
              ],
            ),
          ],
        ),




        
      ),);
  }
}