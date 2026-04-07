import 'package:flutter/material.dart';
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
}