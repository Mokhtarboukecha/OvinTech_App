

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_new_app/auth_service.dart';

class Addsheep extends StatefulWidget {
  const Addsheep({super.key});

  @override
  State<Addsheep> createState() => _AddsheepState();
}

class _AddsheepState extends State<Addsheep> {
  String purchaseType = "Born At Farm";
  String? selectedGender;
  String? selectedBreed;
  String? selectedBirthType;
  bool _isLoading = false;
  List<dynamic> _breeds = [];

  final TextEditingController _tagIdController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _birthWeightController = TextEditingController();
  final TextEditingController _motherTagController = TextEditingController();
  final TextEditingController _fatherTagController = TextEditingController();
  final TextEditingController _purchaseDateController = TextEditingController();
  final TextEditingController _purchasePriceController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _vendorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBreeds();
  }

  Future<void> _fetchBreeds() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.3:8000/api/breeds/'),
      headers: {
    'Authorization': 'Bearer ${AuthService.token}',
  },
    );
    if (response.statusCode == 200) {
      setState(() {
        _breeds = jsonDecode(response.body);
      });
    }
  }

  int? _calculateAge() {
    if (_birthDateController.text.isEmpty) return null;
    final birth = DateTime.parse(_birthDateController.text);
    final today = DateTime.now();
    int months = (today.year - birth.year) * 12;
    months += today.month - birth.month;
    return months;
  }

  Future<void> _saveSheep() async {
    if (_tagIdController.text.isEmpty || selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill required fields"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final body = {
      'tag_id': _tagIdController.text,
      'gender': selectedGender,
      'color': _colorController.text,
      'purchase_type': purchaseType,
      'remark': _remarkController.text,
      'breed': selectedBreed,
      if (purchaseType == "Born At Farm") ...{
        'birth_date': _birthDateController.text.isEmpty
            ? null
            : _birthDateController.text,
        'birth_weight': _birthWeightController.text.isEmpty
            ? null
            : double.tryParse(_birthWeightController.text),
        'mother_tag': _motherTagController.text,
        'father_tag': _fatherTagController.text,
        'birth_type': selectedBirthType,
        'age_months': _calculateAge(),
      } else ...{
        'purchase_date': _purchaseDateController.text.isEmpty
            ? null
            : _purchaseDateController.text,
        'purchase_price': _purchasePriceController.text.isEmpty
            ? null
            : double.tryParse(_purchasePriceController.text),
        'age_months': int.tryParse(_ageController.text),
        'vendor_name': _vendorController.text,
      }
    };

    final response = await http.post(
      Uri.parse('http://192.168.1.3:8000/api/sheep/'),
      headers: {'Content-Type': 'application/json','Authorization': 'Bearer ${AuthService.token}',},
      body: jsonEncode(body),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 201) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.body),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeaeef1),
      appBar: AppBar(
        title: const Text("Add New Animal",
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 120, 173, 80),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("IDENTIFICATION",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green)),
                const Divider(),
                TextField(
                  controller: _tagIdController,
                  decoration:
                      const InputDecoration(labelText: "Tag ID*"),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration:
                            const InputDecoration(labelText: "Breed*"),
                        value: selectedBreed,
                        items: _breeds
                            .map((b) => DropdownMenuItem(
                                  value: b['id'].toString(),
                                  child: Text(b['name']),
                                ))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => selectedBreed = val),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedGender,
                        decoration:
                            const InputDecoration(labelText: "Gender*"),
                        items: ["Male", "Female"]
                            .map((e) => DropdownMenuItem(
                                value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => selectedGender = val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _colorController,
                  decoration:
                      const InputDecoration(labelText: "Color"),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: purchaseType,
                  items: ["Born At Farm", "Purchased"]
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => purchaseType = val!),
                  decoration: const InputDecoration(
                    labelText: "By Purchase/Birth*",
                    labelStyle: TextStyle(color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 20),
                if (purchaseType == "Purchased") ...[
                  _buildRowField("Purchase Date*", "Purchase Price*",
                      isDate: true,
                      controller1: _purchaseDateController,
                      controller2: _purchasePriceController),
                  const SizedBox(height: 10),
                  _buildRowField("Age (In Months)", "Vendor Name",
                      controller1: _ageController,controller2: _vendorController),
                ] else ...[
                  _buildRowField("Birth Date*", "Birth Wt(KG)",
                      isDate: true,
                      controller1: _birthDateController,
                      controller2: _birthWeightController),
                  const SizedBox(height: 10),
                  _buildRowField("Mother Tag ID", "Father Tag ID",
                      controller1: _motherTagController,
                      controller2: _fatherTagController),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Age (In Months)",
                            hintText: _birthDateController.text.isEmpty
                                ? "Auto calculated"
                                : "${_calculateAge()} months",
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedBirthType,
                          decoration: const InputDecoration(
                              labelText: "Birth Type*"),
                          items: [
                            "Single",
                            "Twin",
                            "Triplet",
                            "Quadruplet"
                          ]
                              .map((e) => DropdownMenuItem(
                                  value: e, child: Text(e)))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => selectedBirthType = val),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 15),
                TextField(
                  controller: _remarkController,
                  decoration:
                      const InputDecoration(labelText: "Remark"),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: MaterialButton(
        height: 60,
        color: const Color.fromARGB(255, 120, 173, 80),
        onPressed: _isLoading ? null : _saveSheep,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("SAVE",
                style:
                    TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }

  Widget _buildRowField(String label1, String label2,
      {bool isDate = false,
      TextEditingController? controller1,
      TextEditingController? controller2}) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller1,
            readOnly: isDate,
            onTap: isDate
                ? () => _selectDate(context, controller1!)
                : null,
            decoration: InputDecoration(
              labelText: label1,
              suffixIcon:
                  isDate ? const Icon(Icons.calendar_month) : null,
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: TextField(
            controller: controller2,
            decoration: InputDecoration(labelText: label2),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }
}