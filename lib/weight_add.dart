import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_new_app/auth_service.dart';

class WeightAdd extends StatefulWidget {
  final dynamic sheep;
  const WeightAdd({super.key, required this.sheep});

  @override
  State<WeightAdd> createState() => _WeightAddState();
}

class _WeightAddState extends State<WeightAdd> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;
  final Color primaryGreen = const Color.fromARGB(255, 120, 173, 80);

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _dateController.text =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _save() async {
    if (_weightController.text.isEmpty || _dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill weight and date"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await http.post(
      Uri.parse('http://192.168.1.3:8000/api/weights/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AuthService.token}',
      },
      body: jsonEncode({
        'sheep': widget.sheep['id'],
        'weight': double.parse(_weightController.text),
        'date': _dateController.text,
        'notes': _notesController.text,
      }),
    );

    setState(() => _isLoading = false);
print("Status: ${response.statusCode}");
print("Body: ${response.body}");
    if (response.statusCode == 201) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.body),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Add Weight - ${widget.sheep['tag_id']}",
            style: const TextStyle(color: Colors.white)),
        backgroundColor: primaryGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text("Sheep: ${widget.sheep['tag_id']}",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen)),
            const SizedBox(height: 30),
            TextField(
              controller: _weightController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "Weight (KG) *",
                prefixIcon: Icon(Icons.monitor_weight, color: primaryGreen),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryGreen, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _dateController,
              readOnly: true,
              onTap: _selectDate,
              decoration: InputDecoration(
                labelText: "Date *",
                prefixIcon: Icon(Icons.calendar_today, color: primaryGreen),
                suffixIcon: Icon(Icons.edit_calendar, color: primaryGreen),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryGreen, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Notes (Optional)",
                prefixIcon: Icon(Icons.note, color: primaryGreen),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryGreen, width: 2),
                ),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("SAVE WEIGHT",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}