import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final RxString _role = 'Household'.obs;
  final RxBool _submitting = false.obs;
  final List<String> _roles = const ['Household', 'Driver', 'Admin'];
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    try {
      _submitting.value = true;
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'role': _role.value.toLowerCase(),
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      Get.snackbar(
        'Success',
        'Account created',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAllNamed(
        '/home',
        arguments: {'role': _role.value.toLowerCase(), 'uid': cred.user!.uid},
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.message}');
      debugPrint('FirebaseAuthException code: ${e.code}');
      Get.snackbar(
        'Sign up failed',
        e.message ?? e.code,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('Error during sign-up: $e');
      Get.snackbar('Error', '$e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      _submitting.value = false;
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      _submitting.value = true;
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('Google Sign-In: User canceled the sign-in');
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential cred = await FirebaseAuth.instance
          .signInWithCredential(credential);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
            'name': googleUser.displayName ?? '',
            'email': googleUser.email,
            'role': _role.value.toLowerCase(),
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      Get.snackbar(
        'Success',
        'Account created',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAllNamed(
        '/home',
        arguments: {'role': _role.value.toLowerCase(), 'uid': cred.user!.uid},
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException during Google Sign-In: ${e.message}');
      debugPrint('FirebaseAuthException code: ${e.code}');
      Get.snackbar(
        'Sign up failed',
        e.message ?? e.code,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('Error during Google Sign-In: $e');
      Get.snackbar('Error', '$e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      _submitting.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Enter your name'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Enter a valid email'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (v) =>
                        (v == null || v.length < 6) ? 'Min 6 characters' : null,
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => DropdownButtonFormField<String>(
                      value: _role.value,
                      items: _roles
                          .map(
                            (r) => DropdownMenuItem<String>(
                              value: r,
                              child: Text(r),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => _role.value = v ?? 'Household',
                      decoration: const InputDecoration(
                        labelText: 'Sign up as',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _submitting.value ? null : _signInWithGoogle,
                        icon: const Icon(Icons.g_mobiledata),
                        label: const Text('Sign up with Google'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _submitting.value ? null : _signup,
                        child: _submitting.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Create account'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Get.toNamed('/login'),
                    child: Text(
                      'Already have an account? Log in',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
