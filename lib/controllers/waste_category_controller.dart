import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recycler/modals/waste_category.dart';

class WasteCategoriesController extends GetxController {
  var categories = <WasteCategory>[
    WasteCategory(
      name: 'Plastic',
      description: 'Plastic bottles, containers, and packaging',
      reward: 0.5,
      penalty: 1.0,
    ),
    WasteCategory(
      name: 'Paper',
      description: 'Newspapers, magazines, and cardboard',
      reward: 0.3,
      penalty: 0.8,
    ),
    WasteCategory(
      name: 'Glass',
      description: 'Glass bottles and jars',
      reward: 0.6,
      penalty: 1.2,
    ),
    WasteCategory(
      name: 'Metal',
      description: 'Aluminum cans and metal containers',
      reward: 0.8,
      penalty: 1.5,
    ),
    WasteCategory(
      name: 'Electronic Waste',
      description: 'Old electronics and batteries',
      reward: 0.0,
      penalty: 0.0,
      isActive: false,
    ),
  ].obs;

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
    Get.snackbar(
      'Add Category',
      'Adding new waste category',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade700,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }
}