

import 'package:flutter/material.dart';
import 'package:my_new_app/addbreed.dart';
import 'package:my_new_app/breed_detail.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_new_app/auth_service.dart';
class Breed extends StatefulWidget {
  const Breed({super.key});

  @override
  State<Breed> createState() => _BreedState();
}

class _BreedState extends State<Breed> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _breeds = [];

  @override
  void initState() {
    super.initState();
    _fetchBreeds();
  }

  Future<void> _fetchBreeds() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.3:8000/api/breeds/'),
      headers: {
    'Authorization': 'Bearer ${AuthService.token}',
  },
    );
    if (response.statusCode == 200) {
      setState(() {
        _breeds = jsonDecode(response.body);
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
                onChanged: (value) {
                  setState(() {});
                },
              )
            : const Text("Breed", style: TextStyle(color: Colors.white)),
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
                    MaterialPageRoute(builder: (context) => const Addbreed()),
                  );
                  if (result == true) _fetchBreeds();
                },
                icon: const Icon(Icons.add_circle_outline,
                    color: Colors.white, size: 20),
                label: const Text("Add New Breed",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 120, 174, 80),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _breeds.length,
              itemBuilder: (context, index) {
                final breed = _breeds[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),child: ListTile(
                    title: Text(breed['name'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    trailing:
                        const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              BreedDetail(breed: breed),
                        ),
                      );
                      if (result == true) _fetchBreeds();
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
