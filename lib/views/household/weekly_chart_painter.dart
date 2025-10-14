import 'package:flutter/material.dart';
import 'package:recycler/utils/colors.dart';

class WeeklyChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

 
    const rows = 6;
    const cols = 6;
    for (int i = 0; i <= rows; i++) {
      final dy = i * size.height / rows;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paintGrid);
    }
    for (int j = 0; j <= cols; j++) {
      final dx = j * size.width / cols;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paintGrid);
    }

   
    final barPaint = Paint()..color = AppColors.recycleIcon;
    final barWidth = size.width / 12;
  
    final x1 = size.width * 0.25;
    final x2 = size.width * 0.75;
    final h1 = size.height * 0.45;
    final h2 = size.height * 0.6;
    canvas.drawRect(Rect.fromLTWH(x1 - barWidth / 2, size.height - h1, barWidth, h1), barPaint);
    canvas.drawRect(Rect.fromLTWH(x2 - barWidth / 2, size.height - h2, barWidth, h2), barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}