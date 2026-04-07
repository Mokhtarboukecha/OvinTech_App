
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BreedDetail extends StatefulWidget {
  final dynamic breed;
  const BreedDetail({super.key, required this.breed});

  @override
  State<BreedDetail> createState() => _BreedDetailState();
}

class _BreedDetailState extends State<BreedDetail> {
  late TextEditingController _nameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.breed['name']);
  }

  Future<void> _updateBreed() async {
    setState(() => _isLoading = true);

    final response = await http.put(
      Uri.parse(
          'http://192.168.1.3:8000/api/breeds/${widget.breed['id']}/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': _nameController.text}),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating breed')),
      );
    }
  }

  Future<void> _deleteBreed() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Breed'),
        content: const Text(
            'Are you sure you want to delete this breed?'),
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
            'http://10.0.2.2:8000/api/breeds/${widget.breed['id']}/'),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Breed Details",
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
              child: Text("Edit Breed Details",
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
        child: Row(
          children: [
            Expanded(
              child: MaterialButton(
                color: Colors.red,
                textColor: Colors.white,
                height: 55,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onPressed: _deleteBreed,
                child: const Text("DELETE"),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MaterialButton(
                color: const Color.fromARGB(255, 120, 173, 80),
                textColor: Colors.white,
                height: 55,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onPressed: _isLoading ? null : _updateBreed,
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