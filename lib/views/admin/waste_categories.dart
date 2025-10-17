import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recycler/controllers/admin_dashboard_controller.dart';
import 'package:recycler/controllers/auth_controller.dart';
import 'package:recycler/controllers/waste_category_controller.dart';

import 'package:recycler/views/admin/settlement_screen.dart';
import 'package:recycler/views/admin/users_screen.dart';

class WasteCategoriesTab extends StatelessWidget {
  WasteCategoriesTab({super.key});
  final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WasteCategoriesController());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Header Section
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Waste Categories',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton.icon(
                onPressed: controller.addCategory,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        // Categories List
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.categories.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.categories.isEmpty) {
              return const Center(child: Text('No categories yet'));
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.categories.length,
              itemBuilder: (context, index) {
                final category = controller.categories[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                category.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                if (!category.isActive)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade800,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Inactive',
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () =>
                                      controller.editCategory(index),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Reward: ${category.reward.toStringAsFixed(1)} / Penalty: ${category.penalty.toStringAsFixed(1)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

class WasteCategories extends StatelessWidget {
    WasteCategories({super.key});
   final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminDashboardController());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final List<Widget> screens = [
      WasteCategoriesTab(),
      UsersScreen(),
      SettlementsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Admin Dashboard',
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
        () => controller.currentIndex.value == 0
            ?   WasteCategoriesTab()
            : screens[controller.currentIndex.value],
      ),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: controller.currentIndex.value,
          onDestinationSelected: controller.changeTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.category),
              label: 'Categories',
            ),

            NavigationDestination(icon: Icon(Icons.people), label: 'Users'),
            NavigationDestination(
              icon: Icon(Icons.receipt_long),
              label: 'Settlements',
            ),
          ],
        ),
      ),
    );
  }
}
