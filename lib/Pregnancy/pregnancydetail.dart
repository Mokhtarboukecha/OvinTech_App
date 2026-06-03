
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_new_app/auth_service.dart';

class Pregnancydetail extends StatefulWidget {
  final dynamic breeding;
  final int daysRemaining;
  final String dueDate;

  const Pregnancydetail({
    super.key,
    required this.breeding,
    required this.daysRemaining,
    required this.dueDate,
  });

  @override
  State<Pregnancydetail> createState() => _PregnancydetailState();
}

class _PregnancydetailState extends State<Pregnancydetail> {
  final Color primaryGreen = const Color.fromARGB(255, 120, 173, 80);
  bool _isLoading = false;
  bool _isEditing = false;

  late TextEditingController _breedingIdController;
  late TextEditingController _dateController;
  String? _selectedType;
  late TextEditingController _remarkController;
  final List<String> _breedingTypes = ['Natural', 'Artificial'];

  @override
  void initState() {
    super.initState();
    _breedingIdController = TextEditingController(
        text: widget.breeding['breeding_id']);
    _dateController =
        TextEditingController(text: widget.breeding['date']);
    _selectedType = widget.breeding['breeding_type'];
    _remarkController =
        TextEditingController(text: widget.breeding['remark'] ?? '');
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_dateController.text),
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

  Future<void> _updateBreeding() async {
    setState(() => _isLoading = true);

    final response = await http.patch(
      Uri.parse(
          'http://192.168.1.3:8000/api/breedings/${widget.breeding['id']}/'),
      headers: {'Content-Type': 'application/json','Authorization': 'Bearer ${AuthService.token}',},
      body: jsonEncode({
        'breeding_id': _breedingIdController.text,
        'date': _dateController.text,
        'breeding_type': _selectedType,
        'remark': _remarkController.text,
        'father_tag_id': widget.breeding['father_tag'],
        'mother_tag_id': widget.breeding['mother_tag'],
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
        SnackBar(
          content: Text(jsonDecode(response.body).toString()),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteBreeding() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pregnancy'),
        content: const Text(
            'Are you sure you want to delete this pregnancy record?'),
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
            'http://192.168.1.3:8000/api/breedings/${widget.breeding['id']}/'),
            headers: {
    'Authorization': 'Bearer ${AuthService.token}',
  },
      );
      Navigator.pop(context, true);
    }
  }Widget _buildInfoRow(String label, dynamic value) {
    if (value == null || value.toString().isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          Expanded(
              child: Text(value.toString(),
                  style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> rows,
      {Color? color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: (color ?? primaryGreen).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: color ?? primaryGreen),
                const SizedBox(width: 10),
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color ?? primaryGreen)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(children: rows),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.breeding;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        title: Text("Pregnancy - ${b['mother_tag']}",
            style: const TextStyle(color: Colors.white)),
        centerTitle: true,
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
        child: Column(
          children: [
            // عداد الأيام
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.daysRemaining <= 0
                    ? Colors.red.shade100
                    : widget.daysRemaining <= 14
                        ? Colors.orange.shade100
                        : Colors.green.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: widget.daysRemaining <= 0
                      ? Colors.red
                      : widget.daysRemaining <= 14
                          ? Colors.orange
                          : primaryGreen,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [Text(
                        widget.daysRemaining <= 0
                            ? "Due!"
                            : "${widget.daysRemaining}",
                        style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: widget.daysRemaining <= 0
                                ? Colors.red
                                : widget.daysRemaining <= 14
                                    ? Colors.orange
                                    : primaryGreen),
                      ),
                      const Text("Days Remaining",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Colors.grey),
                      const SizedBox(height: 4),
                      const Text("Due Date",
                          style: TextStyle(color: Colors.grey)),
                      Text(widget.dueDate,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),

            // معلومات التزاوج
            if (!_isEditing) ...[
              _buildSection(
                "Breeding Info",
                Icons.assignment,
                [
                  _buildInfoRow("Breeding ID", b['breeding_id']),
                  _buildInfoRow("Date", b['date']),
                  _buildInfoRow("Type", b['breeding_type']),
                ],
              ),
              _buildSection(
                "Sire Info (Father)",
                Icons.male,
                [
                  _buildInfoRow("Father Tag", b['father_tag']),
                  _buildInfoRow("Father Breed", b['father_breed']),
                  _buildInfoRow("Father Gender", b['father_gender']),
                  _buildInfoRow("Father Age",
                      b['father_age'] != null ? "${b['father_age']} months" : null),
                ],
                color: Colors.blue.shade700,
              ),
              _buildSection(
                "Dam Info (Mother)",
                Icons.female,
                [
                  _buildInfoRow("Mother Tag", b['mother_tag']),
                  _buildInfoRow("Mother Breed", b['mother_breed']),
                  _buildInfoRow("Mother Gender", b['mother_gender']),
                  _buildInfoRow("Mother Age",
                      b['mother_age'] != null ? "${b['mother_age']} months" : null),
                ],
                color: Colors.pink.shade700,
              ),
              if (b['remark'] != null && b['remark'].toString().isNotEmpty)
                _buildSection(
                  "Additional Notes",
                  Icons.note_alt_outlined,
                  [_buildInfoRow("Remark", b['remark'])],
                ),
            ] else ...[
              // وضع التعديل
              _buildSection(
                "Edit Breeding Info",
                Icons.edit,
                [
                  TextField(
                    controller: _breedingIdController,
                    decoration:
                        const InputDecoration(labelText: "Breeding ID"),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: const InputDecoration(
                      labelText: "Date",
                      suffixIcon: Icon(Icons.calendar_today),),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    items: _breedingTypes
                        .map((t) => DropdownMenuItem(
                            value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedType = val),
                    decoration:
                        const InputDecoration(labelText: "Breeding Type"),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _remarkController,
                    maxLines: 3,
                    decoration:
                        const InputDecoration(labelText: "Remark"),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isEditing
            ? MaterialButton(
                color: primaryGreen,
                textColor: Colors.white,
                height: 55,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                onPressed: _isLoading ? null : _updateBreeding,
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white)
                    : const Text("SAVE CHANGES",
                        style: TextStyle(fontSize: 16)),
              )
            : MaterialButton(
                color: Colors.red,
                textColor: Colors.white,
                height: 55,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                onPressed: _deleteBreeding,
                child: const Text("DELETE PREGNANCY",
                    style: TextStyle(fontSize: 16)),
              ),
      ),
    );
  }
}