

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_new_app/auth_service.dart';

class Addbreed extends StatefulWidget {
  const Addbreed({super.key});

  @override
  State<Addbreed> createState() => _AddbreedState();
}

class _AddbreedState extends State<Addbreed> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveBreed() async {
    if (_nameController.text.isEmpty) return;

    setState(() => _isLoading = true);

    final response = await http.post(
      Uri.parse('http://192.168.1.3:8000/api/breeds/'),
      headers: {'Content-Type': 'application/json','Authorization': 'Bearer ${AuthService.token}',},
      body: jsonEncode({'name': _nameController.text}),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 201) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving breed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Add New Breed",
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
              child: Text("New Breed Details",
                  style: TextStyle(
                      color: Color.fromARGB(255, 120, 173, 80),
                      fontSize: 20)),
            ),
            const SizedBox(height: 50),
            TextField(
              controller: _nameController,
              decoration:
                  const InputDecoration(label: Text("Breed Name")),
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
          height: 55,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          onPressed: _isLoading ? null : _saveBreed,
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("SAVE BREED"),
        ),
      ),
    );
  }
}