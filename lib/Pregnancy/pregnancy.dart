
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_new_app/Pregnancy/pregnancydetail.dart';
import 'package:my_new_app/auth_service.dart';

class Pregnancy extends StatefulWidget {
  const Pregnancy({super.key});

  @override
  State<Pregnancy> createState() => _PregnancyState();
}

class _PregnancyState extends State<Pregnancy> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _breedings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBreedings();
  }

  Future<void> _fetchBreedings() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.3:8000/api/breedings/'),
        headers: {
    'Authorization': 'Bearer ${AuthService.token}',
  },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;

        // ترتيب حسب أقرب ولادة
        data.sort((a, b) {
          final daysA = _getDaysRemaining(a['date']);
          final daysB = _getDaysRemaining(b['date']);
          return daysA.compareTo(daysB);
        });

        setState(() {
          _breedings = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  int _getDaysRemaining(String breedingDate) {
    final date = DateTime.parse(breedingDate);
    final dueDate = date.add(const Duration(days: 155));
    final today = DateTime.now();
    final diff = dueDate.difference(today).inDays;
    return diff;
  }

  String _getDueDate(String breedingDate) {
    final date = DateTime.parse(breedingDate);
    final dueDate = date.add(const Duration(days: 155));
    return "${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}";
  }

  Color _getCardColor(int daysRemaining) {
    if (daysRemaining <= 0) return Colors.red.shade100;
    if (daysRemaining <= 14) return Colors.orange.shade100;
    if (daysRemaining <= 30) return Colors.yellow.shade100;
    return Colors.green.shade50;
  }

  Color _getDaysColor(int daysRemaining) {
    if (daysRemaining <= 0) return Colors.red;
    if (daysRemaining <= 14) return Colors.orange;
    if (daysRemaining <= 30) return Colors.amber;
    return const Color.fromARGB(255, 120, 173, 80);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _isSearching && _searchController.text.isNotEmpty
        ? _breedings
            .where((b) => b['mother_tag']
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
                  hintText: "Search by mother tag...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() {}),
              )
            : const Text("Pregnancy", style: TextStyle(color: Colors.white)),
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
              setState(() {_isSearching = !_isSearching;
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : filtered.isEmpty
              ? const Center(
                  child: Text("No pregnancies found",
                      style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final breeding = filtered[index];
                    final daysRemaining =
                        _getDaysRemaining(breeding['date']);
                    final dueDate = _getDueDate(breeding['date']);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      color: _getCardColor(daysRemaining),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: _getDaysColor(daysRemaining),
                          radius: 28,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                daysRemaining <= 0
                                    ? "Due!"
                                    : "$daysRemaining",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                              if (daysRemaining > 0)
                                const Text("days",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10)),
                            ],
                          ),
                        ),
                        title: Text(
                          "Mother: ${breeding['mother_tag']}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Father: ${breeding['father_tag']}"),
                            Text("Due Date: $dueDate"),
                            Text(
                              daysRemaining <= 0
                                  ? "⚠️ Due date passed!"
                                  : "$daysRemaining days remaining",
                              style: TextStyle(
                                  color: _getDaysColor(daysRemaining),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            size: 16),
                        onTap: () async {
                          final result =
                              await Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Pregnancydetail(
                                breeding: breeding,
                                daysRemaining: daysRemaining,
                                dueDate: dueDate,
                              ),
                            ),
                          );
                          if (result == true) _fetchBreedings();
                        },
                      ),
                    );
                  },
                ),
    );
  }
}