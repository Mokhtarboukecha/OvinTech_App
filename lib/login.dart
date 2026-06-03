

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_new_app/auth_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscured = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter email and password"),
          backgroundColor: Color.fromARGB(255, 109, 199, 109),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await http.post(
      Uri.parse('http://192.168.1.3:8000/api/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
      }),
    );

    setState(() => _isLoading = false);

    /*if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      AuthService.token = data['access'];
      // يمكنك حفظ الـ token هنا لاحقاً
      print("Token: ${data['access']}");
      Navigator.of(context).pushReplacementNamed("homepage");
    }*/
   /* if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  AuthService.token = data['access'];
  AuthService.firstName = data['first_name'];
  AuthService.lastName = data['last_name'];
  AuthService.email = data['email'];
  Navigator.of(context).pushReplacementNamed("homepage");
}*/
if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  await AuthService.saveUser(
    token: data['access'],
    firstName: data['first_name'],
    lastName: data['last_name'],
    email: data['email'],
  );
  Navigator.of(context).pushReplacementNamed("homepage");
}
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Invalid email or password"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 80),
            Image.asset("images/logo2-removebg-preview.png", width: 200),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.topLeft,
              child: Text("Welcome",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(label: Text("Email")),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _passwordController,
              obscureText: _isObscured,
              decoration: InputDecoration(
                labelText: "Password",
                suffixIcon: IconButton(
                  icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _isObscured = !_isObscured),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pushNamed("fpassword"),
                child: const Text("Forgot Password?"),
              ),
            ),
            const SizedBox(height: 15),
            MaterialButton(
              color: Colors.blueAccent,
              textColor: Colors.white,
              minWidth: double.infinity,height: 50,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Login"),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have account?"),
                TextButton(
                  onPressed: () => Navigator.of(context).pushNamed("signup"),
                  child: const Text("SIGN UP",
                      style: TextStyle(color: Colors.blueAccent)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
