import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Thống kê yêu cầu")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          // Tính toán số lượng từng trạng thái
          final docs = snapshot.data!.docs;
          int choXuLy = 0, dangXuLy = 0, daDuyet = 0, tuChoi = 0;

          for (var doc in docs) {
            final status = doc['status'] ?? 0;
            if (status == 0) choXuLy++;
            else if (status == 1) dangXuLy++;
            else if (status == 2) daDuyet++;
            else if (status == 3) tuChoi++;
          }

          return Column(
            children: [
              const SizedBox(height: 40),
              SizedBox(
                height: 250,
                child: PieChart(
                  PieChartData(
                    sections: [
                      _buildSection(choXuLy, Colors.orange, "Chờ"),
                      _buildSection(dangXuLy, Colors.blue, "Đang xử lý"),
                      _buildSection(daDuyet, Colors.green, "Đã duyệt"),
                      _buildSection(tuChoi, Colors.red, "Từ chối"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _buildLegend(),
            ],
          );
        },
      ),
    );
  }

  PieChartSectionData _buildSection(int value, Color color, String title) {
    return PieChartSectionData(
      value: value.toDouble(),
      color: color,
      title: value > 0 ? '$value' : '',
      radius: 50,
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _buildLegend() {
    return Column(
      children: [
        _legendItem(Colors.orange, "Chờ xử lý"),
        _legendItem(Colors.blue, "Đang xử lý"),
        _legendItem(Colors.green, "Đã duyệt"),
        _legendItem(Colors.red, "Từ chối"),
      ],
    );
  }

  Widget _legendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
      child: Row(
        children: [
          Container(width: 16, height: 16, color: color),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }
}