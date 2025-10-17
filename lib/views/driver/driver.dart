import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:recycler/controllers/auth_controller.dart';
import 'package:recycler/controllers/driver_controller.dart';

class Driver extends StatelessWidget {
  Driver({super.key});
  final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final DriverController controller = Get.put(DriverController());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),

        title: const Text(
          'Recycler App - Driver',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authController.logout();
            },
          ),
        ],
      ),
      body: Obx(
        () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.requests.length,
          itemBuilder: (context, index) {
            final request = controller.requests[index];
            final isPending = request.status == 'Pending';
            final isCollected = request.status == 'Collected';

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Request ${request.id}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isPending
                                ? Colors.amber.shade900.withOpacity(0.3)
                                : colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isPending
                                  ? Colors.amber.shade700
                                  : colorScheme.primary,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            request.status,
                            style: TextStyle(
                              color: isPending
                                  ? Colors.amber.shade400
                                  : colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Waste Type: ${request.wasteType}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pickup Date: ${request.pickupDate}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                        onPressed: () {
                          if (isPending) {
                            controller.markAsCollected(index);
                          } else if (isCollected) {
                            controller.recordWeight(index);
                          }
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isPending ? 'Mark as Collected' : 'Record Weight',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
