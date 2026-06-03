
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_new_app/auth_service.dart';

class ListSheepVacDetail extends StatefulWidget {
  final dynamic sheep;
  const ListSheepVacDetail({super.key, required this.sheep});

  @override
  State<ListSheepVacDetail> createState() => _ListSheepVacDetailState();
}

class _ListSheepVacDetailState extends State<ListSheepVacDetail> {
  List<dynamic> _allVaccines = [];
  List<dynamic> _sheepVaccinations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final vaccinesRes = await http.get(
      Uri.parse('http://192.168.1.3:8000/api/vaccines/'),
      headers: {
    'Authorization': 'Bearer ${AuthService.token}',
  },
    );
    final vaccinationsRes = await http.get(
      Uri.parse('http://192.168.1.3:8000/api/vaccinations/'),
      headers: {
    'Authorization': 'Bearer ${AuthService.token}',
  },
    );

    if (vaccinesRes.statusCode == 200 &&
        vaccinationsRes.statusCode == 200) {
      final allVaccinations =
          jsonDecode(vaccinationsRes.body) as List;
      setState(() {
        _allVaccines = jsonDecode(vaccinesRes.body);
        _sheepVaccinations = allVaccinations
            .where((v) =>
                v['sheep'].toString() ==
                widget.sheep['id'].toString())
            .toList();
        _isLoading = false;
      });
    }
  }

  int _getDaysRemaining(dynamic vaccination) {
    if (vaccination == null) return 0;
    return vaccination['days_remaining'] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Sheep ${widget.sheep['tag_id']} Vaccines",
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 120, 173, 80),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _allVaccines.length,
              itemBuilder: (context, index) {
                final vaccine = _allVaccines[index];

                // ابحث عن آخر تلقيح لهذا اللقاح لهذا الخروف
                final vaccinations = _sheepVaccinations
                    .where((v) =>
                        v['vaccine'].toString() ==
                        vaccine['id'].toString())
                    .toList();

                vaccinations.sort((a, b) =>
                    b['valid_till'].compareTo(a['valid_till']));

                final latest =
                    vaccinations.isNotEmpty ? vaccinations.first : null;
                final daysRemaining = _getDaysRemaining(latest);
                final isVaccinated =
                    latest != null && daysRemaining > 0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isVaccinated
                          ? const Color.fromARGB(255, 120, 173, 80)
                          : Colors.red,
                      child: Text(
                        daysRemaining.toString(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(vaccine['name'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    subtitle: isVaccinated
                        ? Text(
                            "$daysRemaining days remaining • Valid till ${latest['valid_till']}")
                        : const Text(
                            "Not vaccinated",
                            style: TextStyle(color: Colors.red),),
                    trailing: isVaccinated
                        ? const Icon(Icons.check_circle,
                            color: Color.fromARGB(255, 120, 173, 80))
                        : const Icon(Icons.cancel, color: Colors.red),
                  ),
                );
              },
            ),
    );
  }
}