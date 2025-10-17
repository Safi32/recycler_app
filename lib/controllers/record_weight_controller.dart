import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/route_manager.dart';


class RecordWeightController extends GetxController {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  Future<void> submitWeight(String requestId) async {
    final weight = double.tryParse(weightController.text);
    final notes = notesController.text.trim();

    print('🧾 Submitting weight for request ID: $requestId'); // <-- debug print

    // Build payload with only provided fields
    final Map<String, dynamic> payload = {};
    if (weight != null && weight > 0) payload['weight'] = weight;
    if (notes.isNotEmpty) payload['notes'] = notes;
    payload['createdAt'] = FieldValue.serverTimestamp();

    if (payload.keys.where((k) => k == 'weight' || k == 'notes').isEmpty) {
      Get.snackbar(
        'Nothing to save',
        'Enter a weight or notes to save a record.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Save into a top-level collection with a random doc ID; only provided fields are stored
      await FirebaseFirestore.instance
          .collection('collectionRecords')
          .add(payload);

      // Navigate back first, then show the snackbar so it's visible on previous screen
      Get.back();
      Future.microtask(() => Get.snackbar(
        'Success',
        'Weight recorded successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
      ));
    } catch (e) {
      print('❌ Firestore update error: $e');
      Get.snackbar(
        'Error',
        'Error submitting weight: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
    );
  }
}

}
