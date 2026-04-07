/*import 'package:flutter/material.dart';
import 'package:my_new_app/vac/addvac.dart'; 

class Listvac extends StatefulWidget {
  const Listvac({super.key});

  @override
  State<Listvac> createState() => _ListvacState();
}

class _ListvacState extends State<Listvac> {
  // متغير للتحكم في حالة البحث (هل هو مفتوح أم مغلق)
  bool _isSearching = false;
  // متحكم للنص المدخل في البحث
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 120, 173, 80),
        // التبديل بين النص وحقل البحث
        title: _isSearching 
          ? TextField(
              controller: _searchController,
              autofocus: true, // يفتح لوحة المفاتيح تلقائياً
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Search...",
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                // هنا تضع منطق الفلترة لاحقاً
              },
            )
          : const Text("Vaccine", style: TextStyle(color: Colors.white)),
        
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                // عكس حالة البحث عند الضغط
                _isSearching = !_isSearching;
                if (!_isSearching) _searchController.clear();
              });
            },
            icon: Icon(
              _isSearching ? Icons.close : Icons.search, 
              color: Colors.white,
            ),
          )
        ],
        // أيقونة العودة (تظهر تلقائياً أو نضيفها يدوياً لتناسب التصميم)
        leading: _isSearching ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchController.clear();
            });
          },
        ) : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const Addvac()),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                  label: const Text(
                    "Add New Vaccine",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 120, 174, 80),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ),
            // هنا ستظهر قائمة السلالات (Goat, Srandi...)
          ],
        ),
      ),
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:my_new_app/vac/addvac.dart';
import 'package:my_new_app/vac/vac_detail.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Listvac extends StatefulWidget {
  const Listvac({super.key});

  @override
  State<Listvac> createState() => _ListvacState();
}

class _ListvacState extends State<Listvac> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _vaccines = [];

  @override
  void initState() {
    super.initState();
    _fetchVaccines();
  }

  Future<void> _fetchVaccines() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.3:8000/api/vaccines/'),
    );
    if (response.statusCode == 200) {
      setState(() {
        _vaccines = jsonDecode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 120, 173, 80),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Search...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() {}),
              )
            : const Text("Vaccine", style: TextStyle(color: Colors.white)),
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                  });
                },
              )
            : null,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchController.clear();
              });
            },
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const Addvac()),
                  );
                  if (result == true) _fetchVaccines();
                },
                icon: const Icon(Icons.add_circle_outline,
                    color: Colors.white, size: 20),
                label: const Text("Add New Vaccine",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color.fromARGB(255, 120, 174, 80),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _vaccines.length,
              itemBuilder: (context, index) {
                final vaccine = _vaccines[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor:
                          Color.fromARGB(255, 120, 173, 80),
                      child: Icon(Icons.vaccines, color: Colors.white),
                    ),
                    title: Text(vaccine['name'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        "Every ${vaccine['given_every_days']} days"),
                    trailing:
                        const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              VacDetail(vaccine: vaccine),
                        ),
                      );
                      if (result == true) _fetchVaccines();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}