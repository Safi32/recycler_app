import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recycler/controllers/auth_controller.dart';
import 'package:recycler/controllers/record_weight_controller.dart';
import 'package:recycler/widgets/build_detail_row.dart';
import 'package:recycler/modals/recycler_request.dart';

class RecordWeight extends StatelessWidget {
  final RecyclerRequest request;

  RecordWeight({super.key, required this.request});
  final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RecordWeightController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            onPressed: () {
              authController.logout();
            },
            icon: Icon(Icons.logout),
          ),
        ],
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
            // --- Section: Request Details ---
            Text(
              'Request Details',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            Card(
              color: Colors.black.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    buildDetailRow('Status', request.status),
                    const SizedBox(height: 12),
                    buildDetailRow('Waste Type', request.wasteType),
                    const SizedBox(height: 12),
                    buildDetailRow('Pickup Date', request.pickupDate),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- Section: Record Weight ---
            Text(
              'Record Weight',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // --- Weight input field ---
            TextField(
              controller: controller.weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                hintText: 'Enter weight in kilograms',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),

            // --- Notes input field ---
            TextField(
              controller: controller.notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
              ),
            ),
            const SizedBox(height: 24),

            // --- Submit Button ---
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (request.id.isEmpty) {
                    Get.snackbar(
                      'Error',
                      'Request ID is missing. Cannot update record.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.withOpacity(0.7),
                      colorText: Colors.white,
                    );
                    return;
                  }
                  controller.submitWeight(request.id);
                },
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
