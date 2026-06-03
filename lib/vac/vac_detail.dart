import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_new_app/auth_service.dart';

class VacDetail extends StatefulWidget {
  final dynamic vaccine;
  const VacDetail({super.key, required this.vaccine});

  @override
  State<VacDetail> createState() => _VacDetailState();
}

class _VacDetailState extends State<VacDetail> {
  late TextEditingController _nameController;
  late TextEditingController _daysController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.vaccine['name']);
    _daysController = TextEditingController(
        text: widget.vaccine['given_every_days'].toString());
  }

  Future<void> _updateVaccine() async {
    setState(() => _isLoading = true);

    final response = await http.put(
      Uri.parse(
          'http://192.168.1.3:8000/api/vaccines/${widget.vaccine['id']}/'),
      headers: {'Content-Type': 'application/json','Authorization': 'Bearer ${AuthService.token}',},
      body: jsonEncode({
        'name': _nameController.text,
        'given_every_days': int.parse(_daysController.text),
      }),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error updating vaccine"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _deleteVaccine() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vaccine'),
        content:
            const Text('Are you sure you want to delete this vaccine?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await http.delete(
        Uri.parse(
            'http://192.168.1.3:8000/api/vaccines/${widget.vaccine['id']}/'),
            headers: {
    'Authorization': 'Bearer ${AuthService.token}',
  },
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Vaccine Details",
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
              child: Text("Edit Vaccine Details",
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
                      contentPadding:EdgeInsets.symmetric(horizontal: 10),
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
        child: Row(
          children: [
            Expanded(
              child: MaterialButton(
                color: Colors.red,
                textColor: Colors.white,
                height: 55,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onPressed: _deleteVaccine,
                child: const Text("DELETE"),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MaterialButton(
                color: const Color.fromARGB(255, 120, 173, 80),
                textColor: Colors.white,
                height: 55,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onPressed: _isLoading ? null : _updateVaccine,
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white)
                    : const Text("SAVE"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}