import 'package:flutter/material.dart';

Widget buildDetailRow(String title, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      Text(value),
    ],
  );
}
