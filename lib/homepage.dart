import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_new_app/vac/homevac.dart'; 


class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Widget buildDashboardItem(String title, IconData icon, Color color, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15), 
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.white), 
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
              shrinkWrap: true, 
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.1, 
              children: [
                buildDashboardItem("Breed", FontAwesomeIcons.dna, const Color.fromARGB(255,120,173,80), () {Navigator.of(context).pushNamed("breed");}),
                buildDashboardItem("sheep",FontAwesomeIcons.cow, const Color.fromARGB(255,120,173,80), () {Navigator.of(context).pushNamed("sheep");}),
                buildDashboardItem("Vaccines",FontAwesomeIcons.syringe , const Color.fromARGB(255,120,173,80), () {Navigator.of(context).pushNamed("homevac");}),
                buildDashboardItem("Weight",FontAwesomeIcons.weightScale , const Color.fromARGB(255,120,173,80), () {}),
                buildDashboardItem("Granary",FontAwesomeIcons.buildingWheat , const Color.fromARGB(255,120,173,80), () {}),
                buildDashboardItem("Empoyee",Icons.person , const Color.fromARGB(255,120,173,80), () {}),
              ],
            ),
          ],
        ),




        
      ),);
  }
}