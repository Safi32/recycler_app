
import 'package:flutter/material.dart';
import 'package:recycler/views/household/weekly_chart_painter.dart';

class WeeklyPerformanceChart extends StatelessWidget {
  const WeeklyPerformanceChart({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: WeeklyChartPainter(),
      size: const Size(double.infinity, 140),
    );
  }
}