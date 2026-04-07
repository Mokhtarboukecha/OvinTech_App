import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_new_app/vac/homevac.dart'; 
import 'package:my_new_app/vac/list_sheep_vac.dart';


class Homevac extends StatefulWidget {
  const Homevac({super.key});

  @override
  State<Homevac> createState() => _HomevacState();
}

class _HomevacState extends State<Homevac> {
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
                buildDashboardItem("List vaccines", FontAwesomeIcons.list, const Color.fromARGB(255,120,173,80), () {Navigator.of(context).pushNamed("listvac");}),
                buildDashboardItem("Vaccination sheep",FontAwesomeIcons.cow, const Color.fromARGB(255,120,173,80), () {Navigator.of(context).pushNamed("vaccination");}),
                buildDashboardItem("Vaccine record",FontAwesomeIcons.googleDrive , const Color.fromARGB(255,120,173,80), () {Navigator.of(context).pushNamed("list_sheep_vac");}),
               // buildDashboardItem("Weight",FontAwesomeIcons.weightScale , const Color.fromARGB(255,120,173,80), () {}),
                //buildDashboardItem("Granary",FontAwesomeIcons.buildingWheat , const Color.fromARGB(255,120,173,80), () {}),
                //buildDashboardItem("Empoyee",Icons.person , const Color.fromARGB(255,120,173,80), () {}),
              ],
            ),
          ],
        ),




        /*Column( children[ GridView.count(

      crossAxisCount: 2, // عدد الأعمدة (اثنان كما في صورتك)
      crossAxisSpacing: 10, // المسافة الأفقية بين المربعات
      mainAxisSpacing: 10, // المسافة الرأسية بين المربعات
      children: [
        // هنا نستدعي القالب الذي أنشأناه بالأعلى لكل عنصر
        buildDashboardItem("Timetable", Icons.calendar_month, const Color(0xFF00897B), () {
            // الكود الذي يعمل عند الضغط
        }),
        buildDashboardItem("Exams Schedule", Icons.event_note, const Color(0xFF00897B), () {
            // الكود الذي يعمل عند الضغط
        }),
        buildDashboardItem("Exam Grades", Icons.school, const Color(0xFF00897B), () {
             // الكود الذي يعمل عند الضغط
        }),
        // ... وهكذا لبقية العناصر
      ],
    )])*/
      ),);
  }
}