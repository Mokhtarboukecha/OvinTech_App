

  import 'package:flutter/material.dart';
import 'package:my_new_app/Breeding/breeding.dart';
import 'package:my_new_app/Breeding/homebreeding.dart';
import 'package:my_new_app/Breeding/listbreeding.dart';
import 'package:my_new_app/Granary/addgranary.dart';
import 'package:my_new_app/Granary/homegranary.dart';
import 'package:my_new_app/Granary/listgranary.dart';
import 'package:my_new_app/Pregnancy/pregnancy.dart';
import 'package:my_new_app/addbreed.dart';
import 'package:my_new_app/addsheep.dart';
import 'package:my_new_app/ai_chat.dart';
import 'package:my_new_app/birth_add.dart';
import 'package:my_new_app/breed.dart';
import 'package:my_new_app/fpassword.dart';
import 'package:my_new_app/homepage.dart';
import 'package:my_new_app/login.dart';
import 'package:my_new_app/settings_page.dart';
import 'package:my_new_app/sheep.dart';
import 'package:my_new_app/signup.dart';
import 'package:my_new_app/statistics_page.dart';
import 'package:my_new_app/theme_service.dart';
import 'package:my_new_app/vac/addvac.dart';
import 'package:my_new_app/vac/homevac.dart';
import 'package:my_new_app/vac/list_sheep_vac.dart';
import 'package:my_new_app/vac/listvac.dart';
import 'package:my_new_app/vac/vaccination.dart';
import 'package:my_new_app/weight_list.dart';
import 'package:my_new_app/auth_service.dart';

/*void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeService _themeService = ThemeService();

  void toggleTheme() {
    setState(() {
      _themeService.toggleTheme();
    });
  }

  bool get isDarkMode => _themeService.isDarkMode;

  @override
  Widget build(BuildContext context) {
    final primaryColor = _themeService.primaryColor;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: primaryColor,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(backgroundColor: primaryColor),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF7D746C),
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF7D746C)),
        cardColor: const Color(0xFF2D2D2D),
      ),
      themeMode:
          _themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const Login(),
      routes: {
        "home": (context) => const Login(),
        "signup": (context) => const Signup(),
        "fpassword": (context) => const Fpassword(),
        "homepage": (context) => const Homepage(),
        "breed": (context) => const Breed(),
        "addbreed": (context) => const Addbreed(),
        "sheep": (context) => const Sheep(),
        "homevac": (context) => const Homevac(),
        "listvac": (context) => const Listvac(),
        "addvac": (context) => const Addvac(),
        "vaccination": (context) => const Vaccination(),
        "list_sheep_vac": (context) => const ListSheepVac(),
        "addsheep": (context) => const Addsheep(),
        "homebreeding": (context) => const Homebreeding(),
        "breeding": (context) => const Breeding(),
        "listbreeding": (context) => const Listbreeding(),
        "pergnancy": (context) => const Pregnancy(),
        "listgranary": (context) => const Listgranary(),
        "homegranary": (context) => const Homegranary(),
        "addgranary": (context) => const Addgranary(),
        "aichat": (context) => const AiChat(),
        "wlist": (context) => const WeightList(),
        "birth": (context) => const BirthAdd(),
        "stat": (context) => const StatisticsPage(),
        "settings": (context) => const SettingsPage(),
      },
    );
  }
}*/
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isLoggedIn = await AuthService.loadUser();
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeService _themeService = ThemeService();

  void toggleTheme() {
    setState(() {
      _themeService.toggleTheme();
    });
  }

  bool get isDarkMode => _themeService.isDarkMode;

  @override
  Widget build(BuildContext context) {
    final primaryColor = _themeService.primaryColor;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: primaryColor,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(backgroundColor: primaryColor),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF7D746C),
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF7D746C)),
        cardColor: const Color(0xFF2D2D2D),
      ),
      themeMode:
          _themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: widget.isLoggedIn ? const Homepage() : const Login(),
      routes: {
        "home": (context) => const Login(),
        "signup": (context) => const Signup(),
        "fpassword": (context) => const Fpassword(),
        "homepage": (context) => const Homepage(),
        "breed": (context) => const Breed(),
        "addbreed": (context) => const Addbreed(),
        "sheep": (context) => const Sheep(),
        "homevac": (context) => const Homevac(),
        "listvac": (context) => const Listvac(),
        "addvac": (context) => const Addvac(),
        "vaccination": (context) => const Vaccination(),
        "list_sheep_vac": (context) => const ListSheepVac(),
        "addsheep": (context) => const Addsheep(),
        "homebreeding": (context) => const Homebreeding(),
        "breeding": (context) => const Breeding(),
        "listbreeding": (context) => const Listbreeding(),
        "pergnancy": (context) => const Pregnancy(),
        "listgranary": (context) => const Listgranary(),
        "homegranary": (context) => const Homegranary(),
        "addgranary": (context) => const Addgranary(),
        "aichat": (context) => const AiChat(),
        "wlist": (context) => const WeightList(),
        "birth": (context) => const BirthAdd(),
        "stat": (context) => const StatisticsPage(),
        "settings": (context) => const SettingsPage(),
      },
    );
  }
}