import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:recycler/controllers/auth_controller.dart';
import 'package:recycler/utils/colors.dart';
import 'package:recycler/widgets/settlement_card.dart';

class Credits extends StatelessWidget {
  Credits({super.key});

  final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycler App'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              authController.logout();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Balance',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '25.75 Credits',
                          style: TextStyle(
                            color: AppColors.recycleIcon,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Weekly Performance',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            // Weekly performance chart using fl_chart
            Container(
              height: 160,
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 10,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final labels = [
                            '10/06',
                            '10/13',
                            '10/20',
                            '10/27',
                            '09/29',
                          ];
                          final idx = value.toInt();
                          if (idx >= 0 && idx < labels.length) {
                            return Text(
                              labels[idx],
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 30,
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    getDrawingHorizontalLine: (y) =>
                        FlLine(color: Colors.white12, strokeWidth: 0.5),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: 3.5,
                          color: AppColors.recycleIcon,
                          width: 16,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: 0,
                          color: AppColors.recycleIcon,
                          width: 16,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: 0,
                          color: AppColors.recycleIcon,
                          width: 16,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(
                          toY: 4.5,
                          color: AppColors.recycleIcon,
                          width: 16,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 4,
                      barRods: [
                        BarChartRodData(
                          toY: 0,
                          color: AppColors.recycleIcon,
                          width: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Settlement History',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),

            settlementCard(
              title: 'Week of 2025-10-06',
              totalWeight: '12.50 kg',
              reward: '6.25 Credits',
              penalty: '2.00 Credits',
              amount: '+4.25 Credits',
            ),

            const SizedBox(height: 10),

            settlementCard(
              title: 'Week of 2025-09-29',
              totalWeight: '8.20 kg',
              reward: '4.10 Credits',
              penalty: '1.50 Credits',
              amount: '+2.60 Credits',
            ),
          ],
        ),
      ),
    );
  }
}
