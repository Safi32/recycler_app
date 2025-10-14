  import 'package:flutter/material.dart';
import 'package:recycler/utils/colors.dart';

Widget settlementCard({required String title, required String totalWeight, required String reward, required String penalty, required String amount}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(amount, style: TextStyle(color: AppColors.recycleIcon, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Total Weight: $totalWeight'),
          const SizedBox(height: 4),
          Text('Reward: $reward'),
          const SizedBox(height: 4),
          Text('Penalty: $penalty'),
        ],
      ),
    );
  }
