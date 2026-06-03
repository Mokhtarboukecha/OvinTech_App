import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_new_app/Granary/addgranary.dart';
import 'package:my_new_app/Granary/granarydetail.dart';
import 'package:my_new_app/auth_service.dart';

class Listgranary extends StatefulWidget {
  const Listgranary({super.key});

  @override
  State<Listgranary> createState() => _ListgranaryState();
}

class _ListgranaryState extends State<Listgranary> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _items = [];
  String? _selectedCategory;

  final List<Map<String, dynamic>> _categories = [
    {'value': null, 'label': 'All', 'icon': '📦'},
    {'value': 'feed', 'label': 'Feed', 'icon': '🌾'},
    {'value': 'health', 'label': 'Health', 'icon': '💊'},
    {'value': 'breeding', 'label': 'Breeding', 'icon': '🐑'},
    {'value': 'tools', 'label': 'Tools', 'icon': '🔧'},
    {'value': 'fuel', 'label': 'Fuel', 'icon': '⛽'},
  ];

  List<dynamic> get _filteredItems {
    var items = _items;
    if (_selectedCategory != null) {
      items = items.where((i) => i['category'] == _selectedCategory).toList();
    }
    if (_isSearching && _searchController.text.isNotEmpty) {
      items = items
          .where((i) => i['name']
              .toString()
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    }
    return items;
  }

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.3:8000/api/granary/'),
        headers: {'Authorization': 'Bearer ${AuthService.token}'},
      );
      if (response.statusCode == 200) {
        setState(() => _items = jsonDecode(response.body));
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Color _getExpiryColor(dynamic item) {
    if (item['no_expiry'] == true) return Colors.green;
    if (item['is_expired'] == true) return Colors.red;
    if (item['expiry_date'] == null) return Colors.grey;
    final expiry = DateTime.parse(item['expiry_date']);
    final diff = expiry.difference(DateTime.now()).inDays;
    if (diff <= 7) return Colors.red;
    if (diff <= 30) return Colors.orange;
    return Colors.green;
  }

  String _getExpiryText(dynamic item) {
    if (item['no_expiry'] == true) return "No Expiry";
    if (item['expiry_date'] == null) return "No date";
    if (item['is_expired'] == true) return "Expired!";
    final expiry = DateTime.parse(item['expiry_date']);
    final diff = expiry.difference(DateTime.now()).inDays;
    if (diff <= 0) return "Expired!";
    if (diff == 1) return "1 day left";
    return "$diff days left";
  }

  @override
  Widget build(BuildContext context) {
    final primaryGreen = const Color.fromARGB(255, 120, 173, 80);
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: primaryGreen,
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
            : const Text("Granary", style: TextStyle(color: Colors.white)),
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => setState(() {_isSearching = false;
                  _searchController.clear();
                }),
              )
            : null,
        actions: [
          IconButton(
            icon: Icon(
                _isSearching ? Icons.close : Icons.search,
                color: Colors.white),
            onPressed: () => setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) _searchController.clear();
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat['value'];
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedCategory = cat['value']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryGreen : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? primaryGreen : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(cat['icon'], style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          cat['label'],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Add Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const Addgranary()),
                  );
                  if (result == true) _fetchItems();
                },
                icon: const Icon(Icons.add_circle_outline,
                    color: Colors.white, size: 20),
                label: const Text("Add New Item",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // List
          Expanded(
            child: _filteredItems.isEmpty
                ? const Center(
                    child: Text("No items found",
                        style: TextStyle(color: Colors.grey)))
                : ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      final expiryColor = _getExpiryColor(item);
                      final expiryText = _getExpiryText(item);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: primaryGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                item['category_icon'] ?? '📦',
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                          title: Text(item['name'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "${item['quantity']} ${item['unit']} • ${item['category_display']}"),
                              Row(
                                children: [
                                  Icon(Icons.schedule,
                                      size: 12, color: expiryColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    expiryText,
                                    style: TextStyle(
                                        color: expiryColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    Granarydetail(item: item),
                              ),
                            );
                            if (result == true) _fetchItems();
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