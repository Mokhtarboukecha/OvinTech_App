import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_new_app/auth_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _changePassword = false;
  bool _obscureOld = true;
  bool _obscureNew = true;

  final Color primaryGreen = const Color.fromARGB(255, 120, 173, 80);

  @override
  void initState() {
    super.initState();
    _firstNameController.text = AuthService.firstName ?? '';
    _lastNameController.text = AuthService.lastName ?? '';
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);

    final body = {
      'first_name': _firstNameController.text,
      'last_name': _lastNameController.text,
    };

    if (_changePassword) {
      if (_newPasswordController.text.isEmpty ||
          _oldPasswordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please fill password fields"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }
      body['old_password'] = _oldPasswordController.text;
      body['new_password'] = _newPasswordController.text;
    }

    final response = await http.put(
      Uri.parse('http://192.168.1.3:8000/api/auth/profile/update/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AuthService.token}',
      },
      body: jsonEncode(body),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      AuthService.firstName = data['first_name'];
      AuthService.lastName = data['last_name'];

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully! ✅"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      final error = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error['error'] ?? 'Error updating profile'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        title: const Text("Settings",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 45,
              backgroundColor: primaryGreen.withValues(alpha: 0.2),
              child: Text(
                "${AuthService.firstName?.isNotEmpty == true ? AuthService.firstName![0].toUpperCase() : '?'}",
                style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen),),
            ),
            const SizedBox(height: 8),
            Text(
              "${AuthService.firstName ?? ''} ${AuthService.lastName ?? ''}",
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              AuthService.email ?? '',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Personal Info
            _buildSection(
              title: "Personal Information",
              icon: Icons.person,
              child: Column(
                children: [
                  _buildField("First Name", Icons.badge, _firstNameController),
                  const SizedBox(height: 12),
                  _buildField("Last Name", Icons.badge_outlined, _lastNameController),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Password
            _buildSection(
              title: "Password",
              icon: Icons.lock,
              child: Column(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _changePassword,
                        activeColor: primaryGreen,
                        onChanged: (val) =>
                            setState(() => _changePassword = val ?? false),
                      ),
                      const Text("Change Password"),
                    ],
                  ),
                  if (_changePassword) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: _oldPasswordController,
                      obscureText: _obscureOld,
                      decoration: InputDecoration(
                        labelText: "Old Password",
                        prefixIcon: Icon(Icons.lock_outline, color: primaryGreen),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureOld
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => _obscureOld = !_obscureOld),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _newPasswordController,
                      obscureText: _obscureNew,
                      decoration: InputDecoration(
                        labelText: "New Password",
                        prefixIcon: Icon(Icons.lock, color: primaryGreen),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureNew
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => _obscureNew = !_obscureNew),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: MaterialButton(
          color: primaryGreen,
          textColor: Colors.white,
          height: 55,
          minWidth: double.infinity,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onPressed: _isLoading ? null : _updateProfile,child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("SAVE CHANGES",
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildSection(
      {required String title,
      required IconData icon,
      required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryGreen, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
                      fontSize: 15)),
            ],
          ),
          const Divider(),
          child,
        ],
      ),
    );
  }

  Widget _buildField(
      String label, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryGreen),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primaryGreen, width: 1.5),
        ),
      ),
    );
  }
}