

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_new_app/auth_service.dart';

class SheepDetail extends StatefulWidget {
  final dynamic sheep;
  const SheepDetail({super.key, required this.sheep});

  @override
  State<SheepDetail> createState() => _SheepDetailState();
}

class _SheepDetailState extends State<SheepDetail> {
  bool _isLoading = false;
  bool _isEditing = false;
  Map<String, dynamic>? _familyTree;

  late TextEditingController _tagIdController;
  late TextEditingController _colorController;
  late TextEditingController _remarkController;
  late TextEditingController _birthWeightController;
  late TextEditingController _motherTagController;
  late TextEditingController _fatherTagController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _ageMonthsController;
  late TextEditingController _vendorController;
  late TextEditingController _birthDateController;
  late TextEditingController _purchaseDateController;

  String? _selectedGender;
  String? _selectedBirthType;

  @override
  void initState() {
    super.initState();
    final s = widget.sheep;
    _tagIdController = TextEditingController(text: s['tag_id'] ?? '');
    _colorController = TextEditingController(text: s['color'] ?? '');
    _remarkController = TextEditingController(text: s['remark'] ?? '');
    _birthWeightController =
        TextEditingController(text: s['birth_weight']?.toString() ?? '');
    _motherTagController =
        TextEditingController(text: s['mother_tag'] ?? '');
    _fatherTagController =
        TextEditingController(text: s['father_tag'] ?? '');
    _purchasePriceController =
        TextEditingController(text: s['purchase_price']?.toString() ?? '');
    _ageMonthsController =
        TextEditingController(text: s['age_months']?.toString() ?? '');
    _vendorController =
        TextEditingController(text: s['vendor_name'] ?? '');
    _birthDateController =
        TextEditingController(text: s['birth_date'] ?? '');
    _purchaseDateController =
        TextEditingController(text: s['purchase_date'] ?? '');
    _selectedGender = s['gender'];
    _selectedBirthType = s['birth_type'];
    _fetchFamilyTree();
  }

  Future<void> _fetchFamilyTree() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.1.3:8000/api/sheep/${widget.sheep['id']}/family/'),
        headers: {'Authorization': 'Bearer ${AuthService.token}'},
      );
      if (response.statusCode == 200) {
        setState(() => _familyTree = jsonDecode(response.body));
      }
    } catch (e) {
      print("Family tree error: $e");
    }
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime initial = DateTime.now();
    try {
      if (controller.text.isNotEmpty) {
        initial = DateTime.parse(controller.text);
      }
    } catch (_) {}

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _updateSheep() async {
    setState(() => _isLoading = true);

    final s = widget.sheep;
    final body = {
      'tag_id': _tagIdController.text,
      'gender': _selectedGender,
      'color': _colorController.text,
      'purchase_type': s['purchase_type'],
      'remark': _remarkController.text,
      'breed': s['breed'],
      if (s['purchase_type'] == 'Born At Farm') ...{
        'birth_date': _birthDateController.text.isEmpty
            ? null
            : _birthDateController.text,
        'birth_weight': _birthWeightController.text.isEmpty
            ? null
            : double.tryParse(_birthWeightController.text),
        'mother_tag': _motherTagController.text,
        'father_tag': _fatherTagController.text,
        'birth_type': _selectedBirthType,
      } else ...{
        'purchase_date': _purchaseDateController.text.isEmpty
            ? null
            : _purchaseDateController.text,
        'purchase_price': _purchasePriceController.text.isEmpty
            ? null
            : double.tryParse(_purchasePriceController.text),
        'age_months': int.tryParse(_ageMonthsController.text),
        'vendor_name': _vendorController.text,
      }
    };

    final response = await http.put(
      Uri.parse('http://192.168.1.3:8000/api/sheep/${s['id']}/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AuthService.token}',
      },
      body: jsonEncode(body),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Updated successfully!"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
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

  Future<void> _deleteSheep() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sheep'),
        content: const Text('Are you sure you want to delete this sheep?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await http.delete(
        Uri.parse('http://192.168.1.3:8000/api/sheep/${widget.sheep['id']}/'),
        headers: {'Authorization': 'Bearer ${AuthService.token}'},
      );
      Navigator.pop(context, true);
    }
  }

  Widget _buildInfoRow(String label, dynamic value) {
    if (value == null || value.toString().isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          Expanded(child: Text(value.toString())),
        ],
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller,
      {bool isDate = false, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        readOnly: isDate,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        onTap: isDate ? () => _selectDate(context, controller) : null,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: isDate ? const Icon(Icons.calendar_today) : null,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildFamilyTree() {
    if (_familyTree == null) return const SizedBox();

    final primaryGreen = const Color.fromARGB(255, 120, 173, 80);
    final father = _familyTree!['father'];
    final mother = _familyTree!['mother'];
    final children = _familyTree!['children'] as List?;

    if (father == null && mother == null &&
        (children == null || children.isEmpty)) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_tree, color: primaryGreen),
              const SizedBox(width: 8),
              Text("Family Tree",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
                      fontSize: 16)),
            ],
          ),
          const Divider(),

          // الأب
          if (father != null) ...[
            const Text("Father",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.male, color: Colors.blue, size: 18),
                  const SizedBox(width: 8),
                  Text("Tag: ${father['tag_id']}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (father['breed'] != null) ...[
                    const SizedBox(width: 8),
                    Text("• ${father['breed']}",
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // الأم
          if (mother != null) ...[
            const Text("Mother",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.female, color: Colors.pink, size: 18),
                  const SizedBox(width: 8),
                  Text("Tag: ${mother['tag_id']}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (mother['breed'] != null) ...[
                    const SizedBox(width: 8),
                    Text("• ${mother['breed']}",
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // الأبناء
          if (children != null && children.isNotEmpty) ...[
            const Text("Children",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            ...children.map((child) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.child_care,
                        color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Text("Tag: ${child['tag_id']}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text("• ${child['gender']}",
                        style: const TextStyle(color: Colors.grey)),
                    if (child['birth_date'] != null) ...[
                      const SizedBox(width: 8),
                      Text("• ${child['birth_date']}",
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 11)),
                    ],
                  ],
                ),);
            }),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sheep = widget.sheep;
    final isBornAtFarm = sheep['purchase_type'] == 'Born At Farm';
    final age = sheep['age_months_calculated'];

    return Scaffold(
      backgroundColor: const Color(0xffeaeef1),
      appBar: AppBar(
        title: Text("Sheep ${sheep['tag_id']}",
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 120, 173, 80),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit,
                color: Colors.white),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _isEditing
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("EDIT IDENTIFICATION",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green)),
                      const Divider(),
                      _buildEditField("Tag ID", _tagIdController),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: const InputDecoration(
                            labelText: "Gender",
                            border: OutlineInputBorder()),
                        items: ["Male", "Female"]
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedGender = val),
                      ),
                      const SizedBox(height: 12),
                      _buildEditField("Color", _colorController),
                      const SizedBox(height: 10),
                      if (isBornAtFarm) ...[
                        const Text("BIRTH INFO",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green)),
                        const Divider(),
                        _buildEditField("Birth Date", _birthDateController,
                            isDate: true),
                        _buildEditField(
                            "Birth Weight (KG)", _birthWeightController,
                            isNumber: true),
                        _buildEditField("Mother Tag", _motherTagController),
                        _buildEditField("Father Tag", _fatherTagController),
                        DropdownButtonFormField<String>(
                          value: _selectedBirthType,
                          decoration: const InputDecoration(
                              labelText: "Birth Type",
                              border: OutlineInputBorder()),
                          items: ["Single", "Twin", "Triplet", "Quadruplet"]
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedBirthType = val),
                        ),
                      ] else ...[
                        const Text("PURCHASE INFO",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green)),
                        const Divider(),
                        _buildEditField(
                            "Purchase Date", _purchaseDateController,
                            isDate: true),
                        _buildEditField("Purchase Price", _purchasePriceController,
                            isNumber: true),
                        _buildEditField(
                            "Age (Months)", _ageMonthsController,
                            isNumber: true),
                        _buildEditField("Vendor", _vendorController),
                      ],
                      const SizedBox(height: 10),
                      _buildEditField("Remark", _remarkController),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("IDENTIFICATION",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green)),
                      const Divider(),
                      _buildInfoRow("Tag ID", sheep['tag_id']),
                      _buildInfoRow("Gender", sheep['gender']),
                      _buildInfoRow("Color", sheep['color']),
                      _buildInfoRow("Purchase Type", sheep['purchase_type']),
                      _buildInfoRow(
                          "Age (Months)",
                          age != null
                              ? "$age months"
                              : isBornAtFarm
                                  ? null
                                  : sheep['age_months'] != null
                                      ? "${sheep['age_months']} months"
                                      : null),
                      const SizedBox(height: 10),
                      if (isBornAtFarm) ...[
                        const Text("BIRTH INFO",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green)),
                        const Divider(),
                        _buildInfoRow("Birth Date", sheep['birth_date']),
                        _buildInfoRow("Birth Weight", sheep['birth_weight']),
                        _buildInfoRow("Mother Tag", sheep['mother_tag']),
                        _buildInfoRow("Father Tag", sheep['father_tag']),
                        _buildInfoRow("Birth Type", sheep['birth_type']),
                      ] else ...[
                        const Text("PURCHASE INFO",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green)),
                        const Divider(),
                        _buildInfoRow("Purchase Date", sheep['purchase_date']),
                        _buildInfoRow(
                            "Purchase Price", sheep['purchase_price']),
                        _buildInfoRow("Vendor", sheep['vendor_name']),
                      ],
                      if (sheep['remark'] != null &&
                          sheep['remark'].toString().isNotEmpty) ...[
                        const SizedBox(height: 10),
                        const Text("REMARK",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green)),
                        const Divider(),
                        _buildInfoRow("Remark", sheep['remark']),
                      ],
                      // Family Tree
                      _buildFamilyTree(),
                    ],
                  ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isEditing
            ? MaterialButton(
                color: const Color.fromARGB(255, 120, 173, 80),
                textColor: Colors.white,
                height: 55,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onPressed: _isLoading ? null : _updateSheep,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white): const Text("SAVE CHANGES",
                        style: TextStyle(fontSize: 16)),
              )
            : MaterialButton(
                color: Colors.red,
                textColor: Colors.white,
                height: 55,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onPressed: _isLoading ? null : _deleteSheep,
                child: const Text("DELETE SHEEP",
                    style: TextStyle(fontSize: 16)),
              ),
      ),
    );
  }
}