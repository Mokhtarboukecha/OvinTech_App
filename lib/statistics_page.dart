import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:my_new_app/auth_service.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  int _currentChart = 0;
  final Color primaryGreen = const Color.fromARGB(255, 120, 173, 80);

  final List<Color> _chartColors = [
    const Color(0xFF78AD50),
    const Color(0xFF2196F3),
    const Color(0xFFFF9800),
    const Color(0xFFE91E63),
    const Color(0xFF9C27B0),
    const Color(0xFF00BCD4),
    const Color(0xFFFF5722),
  ];

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  Future<void> _fetchStatistics() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.3:8000/api/sheep/statistics/'),
        headers: {'Authorization': 'Bearer ${AuthService.token}'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _stats = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // --- Breed Pie Chart ---
  Widget _buildBreedChart() {
    final breeds = _stats!['breeds'] as List;
    if (breeds.isEmpty) {
      return _buildEmptyState("No breed data available");
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 50,
              sections: breeds.asMap().entries.map((e) {
                final color = _chartColors[e.key % _chartColors.length];
                return PieChartSectionData(
                  color: color,
                  value: (e.value['count'] as int).toDouble(),
                  title: "${e.value['percentage']}%",
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: breeds.asMap().entries.map((e) {
            final color = _chartColors[e.key % _chartColors.length];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "${e.value['name']} (${e.value['count']})",
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- Gender Pie Chart ---
  Widget _buildGenderChart() {
    final male = (_stats!['genders']['male'] as int).toDouble();
    final female = (_stats!['genders']['female'] as int).toDouble();
    final total = male + female;

    if (total == 0) return _buildEmptyState("No gender data available");

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,centerSpaceRadius: 50,
              sections: [
                PieChartSectionData(
                  color: Colors.blue.shade400,
                  value: male,
                  title: "${(male / total * 100).toStringAsFixed(1)}%",
                  radius: 65,
                  titleStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.pink.shade300,
                  value: female,
                  title: "${(female / total * 100).toStringAsFixed(1)}%",
                  radius: 65,
                  titleStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(Colors.blue.shade400, "Male (${male.toInt()})"),
            const SizedBox(width: 24),
            _buildLegendItem(
                Colors.pink.shade300, "Female (${female.toInt()})"),
          ],
        ),
      ],
    );
  }

  // --- Vaccination Bar Chart ---
  Widget _buildVaccinationChart() {
    final vaccinated =
        (_stats!['vaccination']['vaccinated'] as int).toDouble();
    final notVaccinated =
        (_stats!['vaccination']['not_vaccinated'] as int).toDouble();

    if (vaccinated + notVaccinated == 0) {
      return _buildEmptyState("No vaccination data available");
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (vaccinated > notVaccinated ? vaccinated : notVaccinated) +
                  2,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      rod.toY.toInt().toString(),
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style:
                          const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      switch (value.toInt()) {
                        case 0:
                          return const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text("Vaccinated",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          );
                        case 1:
                          return const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text("Not\nVaccinated",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          );
                        default:
                          return const Text('');
                      }
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.shade200,
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: vaccinated,
                      color: primaryGreen,
                      width: 50,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: notVaccinated,
                      color: Colors.red.shade300,
                      width: 50,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(
                primaryGreen, "Vaccinated (${vaccinated.toInt()})"),
            const SizedBox(width: 24),
            _buildLegendItem(Colors.red.shade300,
                "Not Vaccinated (${notVaccinated.toInt()})"),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Text(message, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }

  final List<Map<String, dynamic>> _charts = [
    {"title": "Breed Distribution", "icon": Icons.pets},
    {"title": "Gender Distribution", "icon": Icons.people},
    {"title": "Vaccination Status", "icon": Icons.vaccines},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        title: const Text("Statistics",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stats == null
              ? const Center(child: Text("Failed to load statistics"))
              : _stats!['total'] == 0
                  ? Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bar_chart,
                              size: 64,
                              color: primaryGreen.withValues(alpha: 0.4)),
                          const SizedBox(height: 16),
                          const Text("No data yet",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 16)),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Summary Cards
                          Row(
                            children: [
                              _buildSummaryCard(
                                "Total Sheep",
                                _stats!['total'].toString(),
                                Icons.pets,
                                primaryGreen,
                              ),
                              const SizedBox(width: 12),
                              _buildSummaryCard(
                                "Vaccinated",
                                _stats!['vaccination']['vaccinated']
                                    .toString(),
                                Icons.vaccines,
                                Colors.blue,
                              ),
                              const SizedBox(width: 12),
                              _buildSummaryCard(
                                "Breeds",
                                (_stats!['breeds'] as List).length.toString(),
                                Icons.category,
                                Colors.orange,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Chart Toggle Buttons
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: _charts.asMap().entries.map((e) {
                                final isSelected = _currentChart == e.key;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(
                                        () => _currentChart = e.key),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? primaryGreen
                                            : Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),child: Column(
                                        children: [
                                          Icon(
                                            e.value['icon'] as IconData,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.grey,
                                            size: 20,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            e.value['title'] as String,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.grey,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Chart Card
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              key: ValueKey(_currentChart),
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    _charts[_currentChart]['title'] as String,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: primaryGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  if (_currentChart == 0) _buildBreedChart(),
                                  if (_currentChart == 1) _buildGenderChart(),
                                  if (_currentChart == 2)
                                    _buildVaccinationChart(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildSummaryCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}