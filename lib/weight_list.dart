import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_new_app/auth_service.dart';
import 'package:my_new_app/weight_analysis.dart';

class WeightList extends StatefulWidget {
  const WeightList({super.key});

  @override
  State<WeightList> createState() => _WeightListState();
}

class _WeightListState extends State<WeightList> {
  List<dynamic> _sheep = [];
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

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
        headers: {'Authorization': 'Bearer ${AuthService.token}'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _sheep = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
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
                  hintText: "Search by tag ID...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() {}),
              )
            : const Text("Weight Monitor",
                style: TextStyle(color: Colors.white)),
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => setState(() {
                  _isSearching = false;
                  _searchController.clear();
                }),
              )
            : null,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () => setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) _searchController.clear();
            }),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredSheep.isEmpty
              ? const Center(
                  child: Text("No sheep found",
                      style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _filteredSheep.length,
                  itemBuilder: (context, index) {
                    final sheep = _filteredSheep[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              const Color.fromARGB(255, 120, 173, 80),
                          child: Text(
                            sheep['tag_id'].toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ),
                        title: Text("Tag: ${sheep['tag_id']}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            "${sheep['gender']} • ${sheep['breed_name'] ?? ''}"),
                        trailing: const Icon(Icons.monitor_weight,
                            color: Color.fromARGB(255, 120, 173, 80)),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  WeightAnalysis(sheep: sheep),
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