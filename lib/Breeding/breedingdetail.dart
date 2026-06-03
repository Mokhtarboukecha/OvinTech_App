import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_new_app/auth_service.dart';

class Breedingdetail extends StatefulWidget {
  final dynamic breeding;
  const Breedingdetail({super.key, required this.breeding});

  @override
  State<Breedingdetail> createState() => _BreedingdetailState();
}

class _BreedingdetailState extends State<Breedingdetail> {
  final Color primaryGreen = const Color.fromARGB(255, 120, 173, 80);
  bool _isLoading = false;

  Future<void> _deleteBreeding() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Breeding'),
        content: const Text(
            'Are you sure you want to delete this breeding record?'),
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
  }

  Widget _buildInfoRow(String label, dynamic value) {
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
        title: Text("Breeding ${b['breeding_id']}",
            style: const TextStyle(color: Colors.white)),
        centerTitle: true,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSection(
              "Breeding General Info",
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
            if (b['different_breed_warning'] != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(b['different_breed_warning'],
                          style: const TextStyle(color: Colors.orange)),
                    ),
                  ],
                ),
              ),
            if (b['remark'] != null && b['remark'].toString().isNotEmpty)
              _buildSection(
                "Additional Notes",
                Icons.note_alt_outlined,
                [_buildInfoRow("Remark", b['remark'])],
              ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: MaterialButton(
          color: Colors.red,
          textColor: Colors.white,
          height: 55,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
          onPressed: _isLoading ? null : _deleteBreeding,
          child: const Text("DELETE BREEDING",
              style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}