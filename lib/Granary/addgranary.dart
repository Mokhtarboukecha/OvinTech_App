import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_new_app/auth_service.dart';

class Addgranary extends StatefulWidget {
  const Addgranary({super.key});

  @override
  State<Addgranary> createState() => _AddgranaryState();
}

class _AddgranaryState extends State<Addgranary> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();

  String? _selectedCategory;
  bool _noExpiry = false;
  bool _isLoading = false;

  final Color primaryGreen = const Color.fromARGB(255, 120, 173, 80);

  final List<Map<String, dynamic>> _categories = [
    {'value': 'feed', 'label': 'Feed & Nutrition', 'icon': '🌾'},
    {'value': 'health', 'label': 'Health & Medical', 'icon': '💊'},
    {'value': 'breeding', 'label': 'Breeding & Birth', 'icon': '🐑'},
    {'value': 'tools', 'label': 'Tools & Equipment', 'icon': '🔧'},
    {'value': 'fuel', 'label': 'Fuel & Energy', 'icon': '⛽'},
  ];

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _expiryController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _saveItem() async {
    if (_nameController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _unitController.text.isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_noExpiry && _expiryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter expiry date or select 'No Expiry'"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await http.post(
      Uri.parse('http://192.168.1.3:8000/api/granary/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AuthService.token}',
      },
      body: jsonEncode({
        'name': _nameController.text,
        'category': _selectedCategory,
        'quantity': double.parse(_quantityController.text),
        'unit': _unitController.text,
        'expiry_date': _noExpiry ? null : _expiryController.text,
        'no_expiry': _noExpiry,
        'notes': _notesController.text,
      }),
    );

    setState(() => _isLoading = false);

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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Add New Item",
            style: TextStyle(color: Colors.white)),
        backgroundColor: primaryGreen,
      ),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Category Selection
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Category *",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: primaryGreen)),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat['value'];
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = cat['value']),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primaryGreen
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? primaryGreen
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(cat['icon'],
                                  style: const TextStyle(fontSize: 24)),
                              const SizedBox(height: 4),
                              Text(
                                cat['label'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Item Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text("Item Details",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: primaryGreen)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: _buildDecoration("Item Name *", Icons.label),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _quantityController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration:
                              _buildDecoration("Quantity *", Icons.numbers),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d*')),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _unitController,
                          decoration: _buildDecoration("Unit *", Icons.scale),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Expiry Date
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Expiry Date",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: primaryGreen)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: _noExpiry,
                        activeColor: primaryGreen,
                        onChanged: (val) =>
                            setState(() => _noExpiry = val ?? false),
                      ),
                      const Text("No Expiry Date"),
                    ],
                  ),
                  if (!_noExpiry) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: _expiryController,
                      readOnly: true,
                      onTap: _selectDate,
                      decoration: _buildDecoration(
                          "Expiry Date *", Icons.calendar_today,
                          suffix: const Icon(Icons.edit_calendar)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                  )
                ],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Notes",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: primaryGreen)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: _buildDecoration("Optional notes...", Icons.note),
                  ),
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
          minWidth: double.infinity,
          height: 55,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onPressed: _isLoading ? null : _saveItem,
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("SAVE ITEM",
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  InputDecoration _buildDecoration(String label, IconData icon,
      {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryGreen, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: primaryGreen, width: 1.5),
      ),
    );
  }
}