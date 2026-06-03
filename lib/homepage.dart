
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_new_app/auth_service.dart';
import 'package:my_new_app/main.dart';
import 'package:my_new_app/theme_service.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final ThemeService _themeService = ThemeService();

  Widget _buildDashboardItem(
      String title, IconData icon, VoidCallback onTap) {
    final color = _themeService.primaryColor;
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
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _themeService.primaryColor;
    final firstName = AuthService.firstName ?? '';
    final lastName = AuthService.lastName ?? '';

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Dashboard",
            style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 20),
              decoration: BoxDecoration(color: primaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    child: Text(
                      firstName.isNotEmpty
                          ? firstName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Hello, $firstName $lastName",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    AuthService.email ?? '',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(
                    icon: Icons.settings,
                    title: "Settings",
                    subtitle: "Edit profile & password",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed("settings");
                    },
                  ),
                  _buildDrawerItem(
                    icon: _themeService.isDarkMode? Icons.light_mode
                        : Icons.dark_mode,
                    title: _themeService.isDarkMode
                        ? "Light Mode"
                        : "Dark Mode",
                    subtitle: _themeService.isDarkMode
                        ? "Switch to light theme"
                        : "Switch to dark theme",
                    onTap: () {
                      MyApp.of(context)?.toggleTheme();
                      setState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  _buildDrawerItem(
                    icon: Icons.logout,
                    title: "Logout",
                    subtitle: "Sign out of your account",
                    color: Colors.red,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Logout"),
                          content: const Text(
                              "Are you sure you want to logout?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              /*onPressed: () {
                                /*AuthService.token = null;
                                AuthService.firstName = null;
                                AuthService.lastName = null;
                                AuthService.email = null;
                                Navigator.of(context)
                                    .pushReplacementNamed("home");*/
                                await AuthService.logout();
                                Navigator.of(context).pushReplacementNamed("home");
                              },*/
                              onPressed: () async {
  await AuthService.logout();
  Navigator.of(context).pushReplacementNamed("home");
},
                              child: const Text("Logout",
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Version
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Livestock Manager v1.0",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.1,
          children: [
            _buildDashboardItem("Breed", FontAwesomeIcons.dna,
                () => Navigator.of(context).pushNamed("breed")),
            _buildDashboardItem("Sheep", FontAwesomeIcons.cow,
                () => Navigator.of(context).pushNamed("sheep")),
            _buildDashboardItem("Vaccines", FontAwesomeIcons.syringe,
                () => Navigator.of(context).pushNamed("homevac")),
            _buildDashboardItem("Breeding", FontAwesomeIcons.venusMars,
                () => Navigator.of(context).pushNamed("homebreeding")),
            _buildDashboardItem("Pregnancy", FontAwesomeIcons.hourglassHalf,
                () => Navigator.of(context).pushNamed("pergnancy")),
            _buildDashboardItem("Granary", FontAwesomeIcons.buildingWheat,
                () => Navigator.of(context).pushNamed("homegranary")),
            _buildDashboardItem("Ask the bot", FontAwesomeIcons.robot,
                () => Navigator.of(context).pushNamed("aichat")),_buildDashboardItem("Weight", FontAwesomeIcons.balanceScale,
                () => Navigator.of(context).pushNamed("wlist")),
            _buildDashboardItem("Births", FontAwesomeIcons.child,
                () => Navigator.of(context).pushNamed("birth")),
            _buildDashboardItem("Statistics", FontAwesomeIcons.chartPie,
                () => Navigator.of(context).pushNamed("stat")),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    final primaryColor = _themeService.primaryColor;
    return ListTile(
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: (color ?? primaryColor).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color ?? primaryColor, size: 22),
      ),
      title: Text(title,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: color ?? null)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
      onTap: onTap,
    );
  }
}