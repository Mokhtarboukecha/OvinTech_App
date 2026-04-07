
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SheepDetail extends StatefulWidget {
  final dynamic sheep;
  const SheepDetail({super.key, required this.sheep});

  @override
  State<SheepDetail> createState() => _SheepDetailState();
}

class _SheepDetailState extends State<SheepDetail> {
  bool _isLoading = false;

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
            child:
                const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await http.delete(
        Uri.parse(
            'http://192.168.1.3:8000/api/sheep/${widget.sheep['id']}/'),
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

  @override
  Widget build(BuildContext context) {
    final sheep = widget.sheep;
    return Scaffold(
      backgroundColor: const Color(0xffeaeef1),
      appBar: AppBar(
        title: Text("Sheep ${sheep['tag_id']}",
            style: const TextStyle(color: Colors.white)),
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
                _buildInfoRow("Tag ID", sheep['tag_id']),
                _buildInfoRow("Gender", sheep['gender']),
                _buildInfoRow("Color", sheep['color']),
                _buildInfoRow("Purchase Type", sheep['purchase_type']),
                _buildInfoRow("Age (Months)",
                    sheep['age_months_calculated']),
                const SizedBox(height: 10),
                if (sheep['purchase_type'] == "Born At Farm") ...[
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
                      style: TextStyle(fontWeight: FontWeight.bold,
                          color: Colors.green)),
                  const Divider(),
                  _buildInfoRow(
                      "Purchase Date", sheep['purchase_date']),
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
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: MaterialButton(
          color: Colors.red,
          textColor: Colors.white,
          height: 55,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          onPressed: _isLoading ? null : _deleteSheep,
          child: const Text("DELETE SHEEP",
              style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}