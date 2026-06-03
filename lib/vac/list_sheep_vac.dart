/*import 'package:flutter/material.dart';
import 'package:my_new_app/addbreed.dart'; 

class ListSheepVac extends StatefulWidget {
  const ListSheepVac({super.key});

  @override
  State<ListSheepVac> createState() => _ListSheepVacState();
}

class _ListSheepVacState extends State<ListSheepVac> {
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
          : const Text("Vaccine record", style: TextStyle(color: Colors.white)),
        
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
            
            // هنا ستظهر قائمة السلالات (Goat, Srandi...)
          ],
        ),
      ),
    );
  }
}*/

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_new_app/vac/list_sheep_vac_detail.dart';
import 'package:my_new_app/auth_service.dart';

class ListSheepVac extends StatefulWidget {
  const ListSheepVac({super.key});

  @override
  State<ListSheepVac> createState() => _ListSheepVacState();
}

class _ListSheepVacState extends State<ListSheepVac> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _sheep = [];

  @override
  void initState() {
    super.initState();
    _fetchSheep();
  }

  Future<void> _fetchSheep() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.3:8000/api/sheep/'),
      headers: {
    'Authorization': 'Bearer ${AuthService.token}',
  },
    );
    if (response.statusCode == 200) {
      setState(() {
        _sheep = jsonDecode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _isSearching && _searchController.text.isNotEmpty
        ? _sheep
            .where((s) => s['tag_id']
                .toString()
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList()
        : _sheep;

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
            : const Text("Vaccine record",
                style: TextStyle(color: Colors.white)),
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
      body: ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final sheep = filtered[index];
          return Card(
            margin:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    const Color.fromARGB(255, 120, 173, 80),
                child: Text(
                  sheep['tag_id'].toString(),
                  style: const TextStyle(
                      color: Colors.white, fontSize: 12),
                ),
              ),
              title: Text("Tag: ${sheep['tag_id']}",
                  style:
                      const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  "${sheep['gender']} • ${sheep['purchase_type']}"),
              trailing:
                  const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        ListSheepVacDetail(sheep: sheep),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}