import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminWasteCategoryController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController rewardRateController = TextEditingController();
  final TextEditingController penaltyRateController = TextEditingController();
  final RxBool isActive = true.obs;
  final RxBool isSubmitting = false.obs;

  void setActive(bool value) {
    isActive.value = value;
  }

  Future<void> addCategory() async {
    final String name = nameController.text.trim();
    final String description = descriptionController.text.trim();
    final double? rewardRate = double.tryParse(rewardRateController.text.trim());
    final double? penaltyRate = double.tryParse(penaltyRateController.text.trim());

    if (name.isEmpty) {
      Get.snackbar(
        'Missing name',
        'Please enter a category name.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (rewardRate == null || rewardRate < 0) {
      Get.snackbar(
        'Invalid reward rate',
        'Enter a valid non-negative number.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (penaltyRate == null || penaltyRate < 0) {
      Get.snackbar(
        'Invalid penalty rate',
        'Enter a valid non-negative number.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isSubmitting.value = true;
      await FirebaseFirestore.instance.collection('wasteCategories').add({
        'name': name,
        'description': description,
        'rewardRatePerKg': rewardRate,
        'penaltyRatePerKg': penaltyRate,
        'active': isActive.value,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Success',
        'Waste category added.',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Close the dialog/screen if needed
      if (Get.isOverlaysOpen) Get.back();
      // Optionally clear fields for next entry
      nameController.clear();
      descriptionController.clear();
      rewardRateController.clear();
      penaltyRateController.clear();
      isActive.value = true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add category: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    rewardRateController.dispose();
    penaltyRateController.dispose();
    super.onClose();
  }
}


