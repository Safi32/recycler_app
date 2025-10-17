import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recycler/modals/waste_category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recycler/controllers/admin_waste_category_controller.dart';

class WasteCategoriesController extends GetxController {
  final categories = <WasteCategory>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    streamCategories();
  }

  void streamCategories() {
    isLoading.value = true;
    FirebaseFirestore.instance
        .collection('wasteCategories')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      categories.value = snapshot.docs
          .map((d) => WasteCategory.fromMap(d.data(), id: d.id))
          .toList();
      isLoading.value = false;
    }, onError: (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to load categories: $e', snackPosition: SnackPosition.BOTTOM);
    });
  }

  void editCategory(int index) {
    Get.snackbar(
      'Edit Category',
      'Editing ${categories[index].name}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade700,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  void addCategory() {
    final admin = Get.put(AdminWasteCategoryController());

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Waste Category', style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                TextField(
                  controller: admin.nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: admin.descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: admin.rewardRateController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Reward Rate',
                          suffixText: 'per kg',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: admin.penaltyRateController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Penalty Rate',
                          suffixText: 'per kg',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Obx(() => SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Active'),
                      value: admin.isActive.value,
                      onChanged: admin.setActive,
                    )),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    Obx(() => ElevatedButton(
                          onPressed: admin.isSubmitting.value ? null : admin.addCategory,
                          child: admin.isSubmitting.value
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Add'),
                        )),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}