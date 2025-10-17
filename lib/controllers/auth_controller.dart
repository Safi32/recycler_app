import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Reactive user
  Rxn<User> firebaseUser = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    // Bind Firebase user stream
    firebaseUser.bindStream(_auth.authStateChanges());
  }

  /// Get current user
  User? get user => firebaseUser.value;

  /// Logout (Reusable!)
  Future<void> logout() async {
    try {
      await _auth.signOut();
      Get.snackbar(
        'Logged Out',
        'You have been signed out successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Navigate to login screen (update with your route)
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Logout Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
