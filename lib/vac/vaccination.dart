import 'package:flutter/material.dart';

class Vaccination extends StatefulWidget {
  const Vaccination({super.key});

  @override
  State<Vaccination> createState() => _VaccinationState();
}

class _VaccinationState extends State<Vaccination> {
  DateTime? selectedDate;
  DateTime? validTill;

  String? selectedVaccine;

  TextEditingController daysController = TextEditingController();
  TextEditingController remarkController = TextEditingController();
  TextEditingController tagController = TextEditingController();

  // قائمة اللقاحات (فارغة حاليا)
  List<String> vaccines = [];

  // قائمة الحيوانات (Tags)
  List<String> tags = [];

  @override
  Widget build(BuildContext context) {
    Color mainColor = const Color.fromARGB(255, 120, 173, 80);

    return Scaffold(
      appBar: AppBar(
        title: const Text(" Vaccination",style: TextStyle(color: Colors.white)),
        backgroundColor: mainColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Date
            TextField(
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Date *",
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                );

                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
            ),

            const SizedBox(height: 15),

            // Vaccine Name
            DropdownButtonFormField<String>(
              value: selectedVaccine,
              decoration: const InputDecoration(
                labelText: "Vaccine Name *",
              ),
              items: vaccines.map((vaccine) {
                return DropdownMenuItem(
                  value: vaccine,
                  child: Text(vaccine),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedVaccine = value;
                });
              },
            ),

            const SizedBox(height: 15),

            // Given Every Days
            Row(
              children: [
                const Text("Given Every "),
                Expanded(
                  child: TextField(
                    controller: daysController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                const Text("Days"),
                const SizedBox(width: 5),
                const Icon(Icons.help_outline),
              ],
            ),

            const SizedBox(height: 20),

            // Valid Till
            TextField(
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Vaccine valid till",
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                );

                if (picked != null) {
                  setState(() {
                    validTill = picked;
                  });
                }
              },
            ),

            const SizedBox(height: 15),

            // Remark
            TextField(
              controller: remarkController,
              decoration: const InputDecoration(
                labelText: "Remark",
              ),
            ),

            const SizedBox(height: 20),// Tag ID + ADD
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: tagController,
                    decoration: const InputDecoration(
                      labelText: "Enter Tag Id *",
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                  ),
                  onPressed: () {
                    if (tagController.text.isNotEmpty &&
                        !tags.contains(tagController.text)) {
                      setState(() {
                        tags.add(tagController.text);
                        tagController.clear();
                      });
                    }
                  },
                  child: const Text("ADD"),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // عرض Tags
            Wrap(
              children: tags.map((tag) {
                return Container(
                  margin: const EdgeInsets.all(5),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(tag),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            tags.remove(tag);
                          });
                        },
                        child: const Icon(Icons.close, size: 16),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 30),

            // SAVE
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: () {
                  // هنا تقدر تحفظ البيانات
                },
                child: const Text("SAVE",style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}