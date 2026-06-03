import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_new_app/auth_service.dart';

class BirthAdd extends StatefulWidget {
  const BirthAdd({super.key});

  @override
  State<BirthAdd> createState() => _BirthAddState();
}

class _BirthAddState extends State<BirthAdd> {
  final Color primaryGreen = const Color.fromARGB(255, 120, 173, 80);
  bool _isLoading = false;

  final TextEditingController _motherTagController = TextEditingController();
  final TextEditingController _fatherTagController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _selectedBirthType;
  String? _selectedBirthStatus;
  Map<String, dynamic>? _motherData;
  Map<String, dynamic>? _fatherData;

  final List<String> _birthTypes = ['Single', 'Twin', 'Triplet', 'Quadruplet'];
  final List<String> _birthStatuses = ['Normal', 'Difficult'];

  final Map<String, int> _birthTypeCount = {
    'Single': 1, 'Twin': 2, 'Triplet': 3, 'Quadruplet': 4
  };

  List<Map<String, TextEditingController>> _newbornControllers = [];

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _dateController.text =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    _addNewbornFields(1);
  }

  void _addNewbornFields(int count) {
    _newbornControllers = List.generate(count, (_) => {
      'tag_id': TextEditingController(),
      'weight': TextEditingController(),
    });
  }

  Future<void> _fetchSheepData(String tagId, bool isMother) async {
    if (tagId.isEmpty) {
      setState(() {
        if (isMother) _motherData = null;
        else _fatherData = null;
      });
      return;
    }

    final response = await http.get(
      Uri.parse('http://192.168.1.3:8000/api/sheep/tag/$tagId/'),
      headers: {'Authorization': 'Bearer ${AuthService.token}'},
    );

    if (response.statusCode == 200) {
      setState(() {
        if (isMother) _motherData = jsonDecode(response.body);
        else _fatherData = jsonDecode(response.body);
      });
    } else {
      setState(() {
        if (isMother) _motherData = null;
        else _fatherData = null;
      });
    }
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
    if (_motherTagController.text.isEmpty ||
        _fatherTagController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _selectedBirthType == null ||
        _selectedBirthStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    for (var controllers in _newbornControllers) {
      if (controllers['tag_id']!.text.isEmpty ||
          controllers['weight']!.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please fill all newborn fields"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    final newborns = _newbornControllers.map((controllers) {
      return {
        'tag_id': controllers['tag_id']!.text,
        'gender': 'Male',
        'weight': double.parse(controllers['weight']!.text),
        'color': '',
      };
    }).toList();final response = await http.post(
      Uri.parse('http://192.168.1.3:8000/api/births/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AuthService.token}',
      },
      body: jsonEncode({
        'mother_tag': _motherTagController.text,
        'father_tag': _fatherTagController.text,
        'birth_date': _dateController.text,
        'birth_type': _selectedBirthType,
        'birth_status': _selectedBirthStatus,
        'notes': _notesController.text,
        'newborns': newborns,
      }),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Birth recorded successfully! 🎉"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
  }

  Widget _buildSectionContainer({
    required String title,
    required IconData icon,
    required Widget child,
    Color? headerColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: (headerColor ?? primaryGreen).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: headerColor ?? primaryGreen),
                const SizedBox(width: 10),
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: headerColor ?? primaryGreen)),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(15), child: child),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        title: const Text("Register Birth",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Birth Info
            _buildSectionContainer(title: "Birth Information",
              icon: Icons.child_care,
              child: Column(
                children: [
                  TextField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: _selectDate,
                    decoration: _buildInputDecoration(
                        "Birth Date *", Icons.calendar_today),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: _selectedBirthType,
                    decoration: _buildInputDecoration(
                        "Birth Type *", Icons.category),
                    items: _birthTypes
                        .map((t) =>
                            DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedBirthType = val;
                        _addNewbornFields(_birthTypeCount[val] ?? 1);
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: _selectedBirthStatus,
                    decoration: _buildInputDecoration(
                        "Birth Status *", Icons.medical_services),
                    items: _birthStatuses
                        .map((s) =>
                            DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedBirthStatus = val),
                  ),
                ],
              ),
            ),

            // Mother Info
            _buildSectionContainer(
              title: "Dam Info (Mother)",
              icon: Icons.female,
              headerColor: Colors.pink.shade700,
              child: Column(
                children: [
                  TextField(
                    controller: _motherTagController,
                    decoration: _buildInputDecoration(
                        "Mother Tag ID *", Icons.fingerprint),
                    onChanged: (val) => _fetchSheepData(val, true),
                  ),
                  if (_motherData != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.pink.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.pink.shade700, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            "Breed: ${_motherData!['breed_name'] ?? 'N/A'} • Age: ${_motherData!['age_months_calculated'] ?? 'N/A'} months",
                            style: TextStyle(color: Colors.pink.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Father Info
            _buildSectionContainer(
              title: "Sire Info (Father)",
              icon: Icons.male,
              headerColor: Colors.blue.shade700,
              child: Column(
                children: [
                  TextField(
                    controller: _fatherTagController,
                    decoration: _buildInputDecoration(
                        "Father Tag ID *", Icons.fingerprint),
                    onChanged: (val) => _fetchSheepData(val, false),),
                  if (_fatherData != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.blue.shade700, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            "Breed: ${_fatherData!['breed_name'] ?? 'N/A'} • Age: ${_fatherData!['age_months_calculated'] ?? 'N/A'} months",
                            style: TextStyle(color: Colors.blue.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Newborns
            _buildSectionContainer(
              title: "Newborns (${_newbornControllers.length})",
              icon: Icons.baby_changing_station,
              child: Column(
                children: [
                  ...List.generate(_newbornControllers.length, (index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryGreen.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: primaryGreen.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Newborn ${index + 1}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryGreen),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller:
                                _newbornControllers[index]['tag_id'],
                            decoration: _buildInputDecoration(
                                "Tag ID *", Icons.tag),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller:
                                _newbornControllers[index]['weight'],
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: _buildInputDecoration(
                                "Birth Weight (KG) *",
                                Icons.monitor_weight),
                          ),
                          const SizedBox(height: 10),
                          // Gender selector
                          Row(
                            children: [
                              Text("Gender: ",
                                  style: TextStyle(color: Colors.grey.shade600)),
                              const SizedBox(width: 10),
                              _GenderSelector(
                                onChanged: (gender) {
                                  _newbornControllers[index]['gender'] =
                                      TextEditingController(text: gender);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),// Notes
            _buildSectionContainer(
              title: "Notes",
              icon: Icons.note_alt_outlined,
              child: TextField(
                controller: _notesController,
                maxLines: 3,
                decoration:
                    _buildInputDecoration("Additional notes...", Icons.edit),
              ),
            ),
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
              : const Text("REGISTER BIRTH",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class _GenderSelector extends StatefulWidget {
  final Function(String) onChanged;
  const _GenderSelector({required this.onChanged});

  @override
  State<_GenderSelector> createState() => _GenderSelectorState();
}

class _GenderSelectorState extends State<_GenderSelector> {
  String _selected = 'Male';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ['Male', 'Female'].map((gender) {
        final isSelected = _selected == gender;
        return GestureDetector(
          onTap: () {
            setState(() => _selected = gender);
            widget.onChanged(gender);
          },
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color.fromARGB(255, 120, 173, 80)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              gender,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}