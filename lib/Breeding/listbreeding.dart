
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_new_app/breeding/breeding.dart';
import 'package:my_new_app/breeding/breedingdetail.dart';
import 'package:my_new_app/auth_service.dart';

class Listbreeding extends StatefulWidget {
  const Listbreeding({super.key});

  @override
  State<Listbreeding> createState() => _ListbreedingState();
}

class _ListbreedingState extends State<Listbreeding> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _breedings = [];

  @override
  void initState() {
    super.initState();
    _fetchBreedings();
  }

 /* Future<void> _fetchBreedings() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.3:8000/api/breedings/'),
    );
    if (response.statusCode == 200) {
      setState(() {
        _breedings = jsonDecode(response.body);
      });
    }
  }*/
  Future<void> _fetchBreedings() async {
  try {
    final response = await http.get(
      Uri.parse('http://192.168.1.3:8000/api/breedings/'),
      headers: {
    'Authorization': 'Bearer ${AuthService.token}',
  },
    );
    if (response.statusCode == 200) {
      setState(() {
        _breedings = jsonDecode(response.body);
      });
    }
  } catch (e) {
    print("ERROR: $e");
    print("BODY: ");
  }
}

  @override
  Widget build(BuildContext context) {
    final filtered = _isSearching && _searchController.text.isNotEmpty
        ? _breedings
            .where((b) => b['breeding_id']
                .toString()
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList()
        : _breedings;

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
            : const Text("List Breeding",
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
                        builder: (context) => const Breeding()),
                  );
                  if (result == true) _fetchBreedings();
                },
                icon: const Icon(Icons.add_circle_outline,
                    color: Colors.white, size: 20),
                label: const Text("Add New Breeding",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color.fromARGB(255, 120, 174, 80),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final breeding = filtered[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          const Color.fromARGB(255, 120, 173, 80),
                      child: const Icon(Icons.pets, color: Colors.white),
                    ),
                    title: Text("ID: ${breeding['breeding_id']}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        "${breeding['breeding_type']} • ${breeding['date']}"),
                    trailing:
                        const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              Breedingdetail(breeding: breeding),
                        ),
                      );
                      if (result == true) _fetchBreedings();
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