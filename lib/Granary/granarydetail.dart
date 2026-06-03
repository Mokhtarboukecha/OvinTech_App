import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_new_app/auth_service.dart';

class Granarydetail extends StatefulWidget {
  final dynamic item;
  const Granarydetail({super.key, required this.item});

  @override
  State<Granarydetail> createState() => _GranarydetailState();
}

class _GranarydetailState extends State<Granarydetail> {
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _unitController;
  late TextEditingController _notesController;
  late TextEditingController _expiryController;
  bool _isLoading = false;
  bool _isEditing = false;
  String? _selectedCategory;
  bool _noExpiry = false;

  final Color primaryGreen = const Color.fromARGB(255, 120, 173, 80);

  final List<Map<String, dynamic>> _categories = [
    {'value': 'feed', 'label': 'Feed & Nutrition', 'icon': '🌾'},
    {'value': 'health', 'label': 'Health & Medical', 'icon': '💊'},
    {'value': 'breeding', 'label': 'Breeding & Birth', 'icon': '🐑'},
    {'value': 'tools', 'label': 'Tools & Equipment', 'icon': '🔧'},
    {'value': 'fuel', 'label': 'Fuel & Energy', 'icon': '⛽'},
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(text: item['name']);
    _quantityController =
        TextEditingController(text: item['quantity'].toString());
    _unitController = TextEditingController(text: item['unit']);
    _notesController = TextEditingController(text: item['notes'] ?? '');
    _expiryController =
        TextEditingController(text: item['expiry_date'] ?? '');
    _selectedCategory = item['category'];
    _noExpiry = item['no_expiry'] ?? false;
  }

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

  Future<void> _updateItem() async {
    setState(() => _isLoading = true);

    final response = await http.put(
      Uri.parse(
          'http://192.168.1.3:8000/api/granary/${widget.item['id']}/'),
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
        const SnackBar(
          content: Text("Error updating item"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await http.delete(
        Uri.parse(
            'http://192.168.1.3:8000/api/granary/${widget.item['id']}/'),
        headers: {'Authorization': 'Bearer ${AuthService.token}'},
      );
      Navigator.pop(context, true);
    }
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 15,
                    color: valueColor ?? Colors.black87,
                    fontWeight: valueColor != null
                        ? FontWeight.bold
                        : FontWeight.normal)),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryGreen, size: 20),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: primaryGreen, width: 1.5),
      ),
    );
  }

  String _getExpiryText() {
    if (_noExpiry) return "No Expiry";
    if (widget.item['expiry_date'] == null) return "Not set";
    if (widget.item['is_expired'] == true) return "⚠️ Expired!";
    final expiry = DateTime.parse(widget.item['expiry_date']);
    final diff = expiry.difference(DateTime.now()).inDays;
    if (diff <= 0) return "⚠️ Expired!";
    if (diff <= 7) return "⚠️ $diff days left";
    if (diff <= 30) return "🟡 $diff days left";
    return "✅ $diff days left";
  }

  Color _getExpiryColor() {
    if (_noExpiry) return Colors.green;
    if (widget.item['is_expired'] == true) return Colors.red;
    if (widget.item['expiry_date'] == null) return Colors.grey;
    final expiry = DateTime.parse(widget.item['expiry_date']);
    final diff = expiry.difference(DateTime.now()).inDays;
    if (diff <= 7) return Colors.red;
    if (diff <= 30) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(widget.item['name'],
            style: const TextStyle(color: Colors.white)),
        backgroundColor: primaryGreen,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit,
                color: Colors.white),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _isEditing
            ? Column(
                children: [
                  // Category
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Category",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryGreen)),
                        const SizedBox(height: 12),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          children: _categories.map((cat) {
                            final isSelected =
                                _selectedCategory == cat['value'];
                            return GestureDetector(
                              onTap: () => setState(
                                  () => _selectedCategory = cat['value']),
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
                                        style:
                                            const TextStyle(fontSize: 22)),
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
                  const SizedBox(height: 12),

                  // Details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration:
                              _buildDecoration("Item Name", Icons.label),
                        ),
                        const SizedBox(height: 12),
                        Row(children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: _quantityController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration: _buildDecoration(
                                    "Quantity", Icons.numbers),
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
                                decoration:
                                    _buildDecoration("Unit", Icons.scale),
                              ),
                            ),
                          ],
                        ),
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
                        if (!_noExpiry)
                          TextField(
                            controller: _expiryController,
                            readOnly: true,
                            onTap: _selectDate,
                            decoration: _buildDecoration(
                                "Expiry Date", Icons.calendar_today),
                          ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration:
                              _buildDecoration("Notes", Icons.note),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  // Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Text(
                          widget.item['category_icon'] ?? '📦',
                          style: const TextStyle(fontSize: 40),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.item['name'],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),Text(
                                widget.item['category_display'] ?? '',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Details Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Details",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryGreen,
                                fontSize: 16)),
                        const Divider(),
                        _buildInfoRow("Quantity",
                            "${widget.item['quantity']} ${widget.item['unit']}"),
                        _buildInfoRow("Category",
                            widget.item['category_display'] ?? ''),
                        _buildInfoRow(
                          "Expiry",
                          _getExpiryText(),
                          valueColor: _getExpiryColor(),
                        ),
                        if (widget.item['expiry_date'] != null &&
                            !_noExpiry)
                          _buildInfoRow(
                              "Expiry Date", widget.item['expiry_date']),
                        if (widget.item['notes'] != null &&
                            widget.item['notes'].toString().isNotEmpty)
                          _buildInfoRow("Notes", widget.item['notes']),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: _isEditing
            ? MaterialButton(
                color: primaryGreen,
                textColor: Colors.white,
                minWidth: double.infinity,
                height: 55,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onPressed: _isLoading ? null : _updateItem,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("SAVE CHANGES",
                        style: TextStyle(fontSize: 16)),
              )
            : MaterialButton(
                color: Colors.red,
                textColor: Colors.white,
                minWidth: double.infinity,
                height: 55,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onPressed: _deleteItem,
                child: const Text("DELETE ITEM",
                    style: TextStyle(fontSize: 16)),
              ),
      ),
    );
  }
}