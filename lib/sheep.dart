


import 'package:flutter/material.dart';
import 'package:my_new_app/addsheep.dart';
import 'package:my_new_app/sheep_detail.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_new_app/auth_service.dart';

class Sheep extends StatefulWidget {
  const Sheep({super.key});

  @override
  State<Sheep> createState() => _SheepState();
}

class _SheepState extends State<Sheep> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _sheep = [];

  List<dynamic> get _filteredSheep {
    if (!_isSearching || _searchController.text.isEmpty) return _sheep;
    return _sheep
        .where((s) => s['tag_id']
            .toString()
            .toLowerCase()
            .contains(_searchController.text.toLowerCase()))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchSheep();
  }

  Future<void> _fetchSheep() async {
    try {
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
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 120, 173, 80),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Search by tag ID...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() {}),
              )
            : const Text("Sheeps", style: TextStyle(color: Colors.white)),
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
                        builder: (context) => const Addsheep()),
                  );
                  if (result == true) _fetchSheep();
                },
                icon: const Icon(Icons.add_circle_outline,
                    color: Colors.white, size: 20),
                label: const Text("Add New Sheep",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color.fromARGB(255, 120, 174, 80),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),),
            ),
          ),
          Expanded(
            child: _filteredSheep.isEmpty
                ? Center(
                    child: Text(
                      _isSearching
                          ? "No sheep found with this tag ID"
                          : "No sheep added yet",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredSheep.length,
                    itemBuilder: (context, index) {
                      final sheep = _filteredSheep[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
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
                          title: Text(
                            "Tag: ${sheep['tag_id']}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                              "${sheep['gender']} • ${sheep['purchase_type']}"),
                          trailing: const Icon(Icons.arrow_forward_ios,
                              size: 16),
                          onTap: () async {
                            final result =
                                await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    SheepDetail(sheep: sheep),
                              ),
                            );
                            if (result == true) _fetchSheep();
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