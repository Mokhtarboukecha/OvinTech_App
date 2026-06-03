

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_new_app/auth_service.dart';

class Vaccination extends StatefulWidget {
  const Vaccination({super.key});

  @override
  State<Vaccination> createState() => _VaccinationState();
}

class _VaccinationState extends State<Vaccination> {
  DateTime? selectedDate;
  String? selectedVaccineId;
  int? givenEveryDays;
  DateTime? validTill;
  bool _isLoading = false;

  final TextEditingController remarkController = TextEditingController();
  final TextEditingController tagController = TextEditingController();

  List<dynamic> _vaccines = [];
  List<String> tags = [];

  @override
  void initState() {
    super.initState();
    _fetchVaccines();
  }

  Future<void> _fetchVaccines() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.3:8000/api/vaccines/'),
      headers: {
    'Authorization': 'Bearer ${AuthService.token}',
  },
    );
    if (response.statusCode == 200) {
      setState(() {
        _vaccines = jsonDecode(response.body);
      });
    }
  }

  void _onVaccineChanged(String? vaccineId) {
    final vaccine = _vaccines.firstWhere(
      (v) => v['id'].toString() == vaccineId,
      orElse: () => null,
    );
    setState(() {
      selectedVaccineId = vaccineId;
      givenEveryDays = vaccine?['given_every_days'];
      _calculateValidTill();
    });
  }

  void _calculateValidTill() {
    if (selectedDate != null && givenEveryDays != null) {
      setState(() {
        validTill = selectedDate!.add(Duration(days: givenEveryDays!));
      });
    }
  }

  Future<void> _addTag() async {
    final tagId = tagController.text.trim();
    if (tagId.isEmpty) return;

    // تحقق من وجود الخروف
    final response = await http.get(
      Uri.parse('http://192.168.1.3:8000/api/sheep/?format=json'),
      headers: {
    'Authorization': 'Bearer ${AuthService.token}',
  },
    );

    if (response.statusCode == 200) {
      final sheep = jsonDecode(response.body) as List;
      final exists = sheep.any((s) => s['tag_id'] == tagId);

      if (!exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No sheep found with tag ID: $tagId"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (tags.contains(tagId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Tag already added"),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      setState(() {
        tags.add(tagId);
        tagController.clear();
      });
    }
  }

  Future<void> _save() async {
    if (selectedDate == null ||
        selectedVaccineId == null ||
        validTill == null ||
        tags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields and add at least one sheep"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    List<String> errors = [];

    for (final tagId in tags) {
      final response = await http.post(
        Uri.parse('http://192.168.1.3:8000/api/vaccinations/'),
        headers: {'Content-Type': 'application/json','Authorization': 'Bearer ${AuthService.token}',},
        body: jsonEncode({
          'tag_id': tagId,
          'vaccine': int.parse(selectedVaccineId!),
          'date': "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}",
          'valid_till': "${validTill!.year}-${validTill!.month.toString().padLeft(2, '0')}-${validTill!.day.toString().padLeft(2, '0')}",
          'remark': remarkController.text,
        }),
      );

      if (response.statusCode != 201) {
        final error = jsonDecode(response.body);
        errors.add("$tagId: ${error['error'] ?? response.body}");
      }
    }

    setState(() => _isLoading = false);if (errors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vaccination saved successfully!"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {
        tags.clear();
        selectedDate = null;
        selectedVaccineId = null;
        validTill = null;
        givenEveryDays = null;
        remarkController.clear();
      });
    } else {
      for (final error in errors) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    Color mainColor = const Color.fromARGB(255, 120, 173, 80);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vaccination",
            style: TextStyle(color: Colors.white)),
        backgroundColor: mainColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Date
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Date *",
                suffixIcon: const Icon(Icons.calendar_today),
                hintText: _formatDate(selectedDate),
              ),
              controller: TextEditingController(
                  text: _formatDate(selectedDate)),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                    _calculateValidTill();
                  });
                }
              },
            ),
            const SizedBox(height: 15),

            // Vaccine Name
            DropdownButtonFormField<String>(
              value: selectedVaccineId,
              decoration: const InputDecoration(
                labelText: "Vaccine Name *",
              ),
              items: _vaccines.map((vaccine) {
                return DropdownMenuItem(
                  value: vaccine['id'].toString(),
                  child: Text(vaccine['name']),
                );
              }).toList(),
              onChanged: _onVaccineChanged,
            ),
            const SizedBox(height: 15),

            // Given Every Days (تلقائي)
            Row(
              children: [
                const Text("Given Every ",
                    style: TextStyle(color: Colors.blueGrey)),
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: TextEditingController(
                        text: givenEveryDays?.toString() ?? ''),
                    decoration: const InputDecoration(
                      hintText: "Auto",
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text("Days",
                    style: TextStyle(color: Colors.blueGrey)),
              ],
            ),
            const SizedBox(height: 15),

            // Valid Till (تلقائي)
            TextField(readOnly: true,
              controller: TextEditingController(
                  text: _formatDate(validTill)),
              decoration: const InputDecoration(
                labelText: "Vaccine valid till",
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 15),

            // Remark
            TextField(
              controller: remarkController,
              decoration: const InputDecoration(labelText: "Remark"),
            ),
            const SizedBox(height: 20),

            // Tag ID + ADD
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: tagController,
                    decoration: const InputDecoration(
                      labelText: "Enter Tag Id *",
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                  ),
                  onPressed: _addTag,
                  child: const Text("ADD",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // عرض Tags
            Wrap(
              children: tags.map((tag) {
                return Container(
                  margin: const EdgeInsets.all(5),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(tag),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () => setState(() => tags.remove(tag)),
                        child: const Icon(Icons.close, size: 16),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            // SAVE
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white)
                    : const Text("SAVE",
                        style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}