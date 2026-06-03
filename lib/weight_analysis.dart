import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:my_new_app/auth_service.dart';
import 'package:my_new_app/weight_add.dart';

class WeightAnalysis extends StatefulWidget {
  final dynamic sheep;
  const WeightAnalysis({super.key, required this.sheep});

  @override
  State<WeightAnalysis> createState() => _WeightAnalysisState();
}

class _WeightAnalysisState extends State<WeightAnalysis> {
  Map<String, dynamic>? _analysis;
  bool _isLoading = true;
  bool _showWeekly = true;
  final Color primaryGreen = const Color.fromARGB(255, 120, 173, 80);

  @override
  void initState() {
    super.initState();
    _fetchAnalysis();
  }

/* Future<void> _fetchAnalysis() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.1.3:8000/api/weights/analysis/${widget.sheep['id']}/'),
        headers: {'Authorization': 'Bearer ${AuthService.token}'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _analysis = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }*/
  Future<void> _fetchAnalysis() async {
  try {
    final response = await http.get(
      Uri.parse(
          'http://192.168.1.3:8000/api/weights/analysis/${widget.sheep['id']}/'),
      headers: {'Authorization': 'Bearer ${AuthService.token}'},
    );
    print("Analysis Status: ${response.statusCode}");
    print("Analysis Body: ${response.body}");
    if (response.statusCode == 200) {
      setState(() {
        _analysis = jsonDecode(response.body);
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  } catch (e) {
    print("Error: $e");
    setState(() => _isLoading = false);
  }
}

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'danger':
      case 'emergency':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'good':
      case 'excellent':
        return primaryGreen;
      case 'pregnancy':
        return Colors.pink;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'danger':
      case 'emergency':
        return Icons.emergency;
      case 'warning':
        return Icons.warning_amber;
      case 'good':
      case 'excellent':
        return Icons.check_circle;
      case 'pregnancy':
        return Icons.child_care;
      default:
        return Icons.analytics;
    }
  }

  Widget _buildAnalysisCard(Map<String, dynamic>? data, String title) {
    if (data == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text("No data available for this period",
            style: TextStyle(color: Colors.grey)),
      );
    }

    final status = data['status'] as String?;
    final color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getStatusIcon(status), color: color, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  data['message'] ?? '',
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem("Previous",
                  "${data['previous_weight']} kg", Colors.grey),
              _buildStatItem(
                "Change",
                "${data['difference'] > 0 ? '+' : ''}${data['difference']} kg",data['difference'] >= 0 ? primaryGreen : Colors.red,
              ),
              _buildStatItem("Current",
                  "${data['current_weight']} kg", primaryGreen),
            ],
          ),
          if (data['pregnancy_indicator'] == true) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.pink.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.child_care, color: Colors.pink, size: 20),
                  SizedBox(width: 8),
                  Text("Pregnancy Indicator Detected!",
                      style: TextStyle(
                          color: Colors.pink, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildChart() {
    final history = _analysis?['history'] as List?;
    if (history == null || history.isEmpty) return const SizedBox();

    final spots = history.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), (e.value['weight'] as num).toDouble());
    }).toList();

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Weight History",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                  fontSize: 16)),
          const SizedBox(height: 12),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        "${value.toInt()}kg",
                        style: const TextStyle(
                            fontSize: 10, color: Colors.grey),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < history.length) {
                          final date = history[idx]['date'] as String;
                          final parts = date.split('-');
                          return Text(
                            "${parts[2]}/${parts[1]}",style: const TextStyle(
                                fontSize: 9, color: Colors.grey),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: primaryGreen,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: primaryGreen.withValues(alpha: 0.1),
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: primaryGreen,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        title: Text("Weight - ${widget.sheep['tag_id']}",
            style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => WeightAdd(sheep: widget.sheep),
                ),
              );
              if (result == true) _fetchAnalysis();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _analysis == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.monitor_weight,
                          size: 64,
                          color: primaryGreen.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      const Text("No weight records yet",
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen),
                        onPressed: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  WeightAdd(sheep: widget.sheep),
                            ),
                          );
                          if (result == true) _fetchAnalysis();
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text("Add First Weight",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current Weight Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: primaryGreen,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Current Weight",
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 14)),
                                Text(
                                  "${_analysis!['current_weight']} kg",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _analysis!['current_date'] ?? '',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                            const Icon(Icons.monitor_weight,
                                color: Colors.white70, size: 48),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Toggle Weekly/Monthly
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _showWeekly = true),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _showWeekly
                                        ? primaryGreen
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "Weekly View",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _showWeekly
                                          ? Colors.white
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(onTap: () =>
                                    setState(() => _showWeekly = false),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !_showWeekly
                                        ? primaryGreen
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "Monthly View",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: !_showWeekly
                                          ? Colors.white
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Analysis Card
                      _showWeekly
                          ? _buildAnalysisCard(
                              _analysis!['weekly_analysis'] as Map<String, dynamic>?,
                              "Weekly Analysis")
                          : _buildAnalysisCard(
                              _analysis!['monthly_analysis'] as Map<String, dynamic>?,
                              "Monthly Analysis"),
                      const SizedBox(height: 16),

                      // Chart
                      _buildChart(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }
}