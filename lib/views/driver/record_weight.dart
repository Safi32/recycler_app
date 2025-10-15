import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:recycler/controllers/record_weight_controller.dart';
import 'package:recycler/widgets/build_detail_row.dart';

class RecordWeight extends StatelessWidget {
  final dynamic request;

  const RecordWeight({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RecordWeightController());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Request ${request.id}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Request Details Section
            Text(
              'Request Details',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    buildDetailRow(
                      'Status',
                      request.status,
                      theme,
                      colorScheme,
                    ),
                    const SizedBox(height: 12),
                    buildDetailRow(
                      'Waste Type',
                      request.wasteType,
                      theme,
                      colorScheme,
                    ),
                    const SizedBox(height: 12),
                    buildDetailRow(
                      'Pickup Date',
                      request.pickupDate,
                      theme,
                      colorScheme,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Record Weight Section
            Text(
              'Record Weight',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Weight Input
            TextField(
              controller: controller.weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Weight (kg)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),

            // Notes Input
            TextField(
              controller: controller.notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Notes (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => controller.submitWeight(request.id),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Submit Weight',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
