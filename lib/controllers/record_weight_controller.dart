import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/route_manager.dart';

class RecordWeightController extends GetxController {
  final weightController = TextEditingController();
  final notesController = TextEditingController();

  @override
  void onClose() {
    weightController.dispose();
    notesController.dispose();
    super.onClose();
  }

  void submitWeight(String requestId) {
    if (weightController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter weight',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    // Handle submit logic here
    Get.back(result: {
      'weight': weightController.text,
      'notes': notesController.text,
    });

    Get.snackbar(
      'Success',
      'Weight recorded for $requestId',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade700,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }
}
