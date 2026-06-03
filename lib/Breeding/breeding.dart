import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_new_app/auth_service.dart';

class Breeding extends StatefulWidget {
  const Breeding({super.key});

  @override
  State<Breeding> createState() => _BreedingState();
}

class _BreedingState extends State<Breeding> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _breedingIdController = TextEditingController();
  final TextEditingController _fatherIdController = TextEditingController();
  final TextEditingController _motherIdController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  final Color primaryGreen = const Color.fromARGB(255, 120, 173, 80);

  String? _selectedType;
  final List<String> _breedingTypes = ['Natural', 'Artificial'];
  Map<String, dynamic>? _fatherData;
  Map<String, dynamic>? _motherData;
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
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

  Future<void> _fetchSheepData(String tagId, bool isFather) async {
    if (tagId.isEmpty) {
      setState(() {
        if (isFather) _fatherData = null;
        else _motherData = null;
      });
      return;
    }

    final response = await http.get(
      Uri.parse('http://192.168.1.3:8000/api/sheep/tag/$tagId/'),
      headers: {
    'Authorization': 'Bearer ${AuthService.token}',
  },
    );

    if (response.statusCode == 200) {
      setState(() {
        if (isFather) _fatherData = jsonDecode(response.body);
        else _motherData = jsonDecode(response.body);
      });
    } else {
      setState(() {
        if (isFather) _fatherData = null;
        else _motherData = null;
      });
    }
  }

  Future<void> _save() async {
    if (_breedingIdController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _selectedType == null ||
        _fatherIdController.text.isEmpty ||
        _motherIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await http.post(
      Uri.parse('http://192.168.1.3:8000/api/breedings/'),
      headers: {'Content-Type': 'application/json','Authorization': 'Bearer ${AuthService.token}',},
      body: jsonEncode({
        'breeding_id': _breedingIdController.text,
        'date': _dateController.text,
        'breeding_type': _selectedType,
        'father_tag_id': _fatherIdController.text,
        'mother_tag_id': _motherIdController.text,
        'remark': _remarkController.text,
      }),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['different_breed_warning'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['different_breed_warning']),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      Navigator.pop(context, true);
    } else {
      final error = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        title: const Text("Add New Breeding",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          children: [
            _buildSectionContainer(
              title: "Breeding General Info",
              icon: Icons.assignment,
              child: Column(
                children: [
                  TextField(
                    controller: _breedingIdController,
                    decoration:
                        _buildInputDecoration("Breeding ID", Icons.tag),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: _buildInputDecoration(
                        "Date of Breeding", Icons.calendar_month),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    items: _breedingTypes
                        .map((type) => DropdownMenuItem(
                            value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedType = value),
                    decoration: _buildInputDecoration(
                        "Breeding Type", Icons.category),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionContainer(
              title: "Sire Info (Father)",
              icon: Icons.male,
              headerColor: Colors.blue.shade700,
              child: Column(
                children: [
                  TextField(
                    controller: _fatherIdController,
                    decoration: _buildInputDecoration(
                        "Father ID", Icons.fingerprint),
                    onChanged: (val) => _fetchSheepData(val, true),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    readOnly: true,
                    controller: TextEditingController(
                        text: _fatherData?['breed_name'] ?? ''),
                    decoration: _buildInputDecoration(
                        "Father Breed", Icons.pets),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    readOnly: true,
                    controller: TextEditingController(
                        text: _fatherData?['gender'] ?? ''),
                    decoration: _buildInputDecoration(
                        "Father Gender", Icons.male),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    readOnly: true,
                    controller: TextEditingController(
                        text: _fatherData != null
                            ? "${_fatherData!['age_months_calculated'] ?? ''} months"
                            : ''),
                    decoration: _buildInputDecoration(
                        "Father Age", Icons.history),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionContainer(
              title: "Dam Info (Mother)",
              icon: Icons.female,headerColor: Colors.pink.shade700,
              child: Column(
                children: [
                  TextField(
                    controller: _motherIdController,
                    decoration: _buildInputDecoration(
                        "Mother ID", Icons.fingerprint),
                    onChanged: (val) => _fetchSheepData(val, false),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    readOnly: true,
                    controller: TextEditingController(
                        text: _motherData?['breed_name'] ?? ''),
                    decoration: _buildInputDecoration(
                        "Mother Breed", Icons.pets),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    readOnly: true,
                    controller: TextEditingController(
                        text: _motherData?['gender'] ?? ''),
                    decoration: _buildInputDecoration(
                        "Mother Gender", Icons.female),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    readOnly: true,
                    controller: TextEditingController(
                        text: _motherData != null
                            ? "${_motherData!['age_months_calculated'] ?? ''} months"
                            : ''),
                    decoration: _buildInputDecoration(
                        "Mother Age", Icons.history),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionContainer(
              title: "Additional Notes",
              icon: Icons.note_alt_outlined,
              child: TextField(
                controller: _remarkController,
                maxLines: 3,
                decoration: _buildInputDecoration(
                    "Remarks...", Icons.edit_note),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        child: MaterialButton(
          height: 55,
          color: primaryGreen,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("SAVE DATA",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required IconData icon,
    required Widget child,
    Color? headerColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: (headerColor ?? primaryGreen).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Icon(icon,
                    size: 20, color: headerColor ?? primaryGreen),const SizedBox(width: 10),
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: headerColor ?? primaryGreen)),
              ],
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(15), child: child),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryGreen, size: 22),
      filled: true,
      fillColor: Colors.grey.shade50,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryGreen, width: 1.5),
      ),
    );
  }
}