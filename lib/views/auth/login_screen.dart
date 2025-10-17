import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final RxString _role = 'Household'.obs;
  final RxBool _submitting = false.obs;
  final List<String> _roles = const ['Household', 'Driver', 'Admin'];
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    try {
      _submitting.value = true;
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Fetch role to direct the UI
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        final savedRole = (doc.data() ?? const {})['role']
            ?.toString()
            .toLowerCase();
        final roleToUse = savedRole ?? _role.value.toLowerCase();
        Get.offAllNamed('/home', arguments: {'role': roleToUse, 'uid': uid});
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Login failed',
        e.message ?? e.code,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
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
        Get.snackbar(
          'Sign In',
          'Google Sign-In canceled',
          snackPosition: SnackPosition.BOTTOM,
        );
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
      // Fetch or create user role in Firestore
      final uid = cred.user!.uid;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final savedRole = (doc.data() ?? const {})['role']
          ?.toString()
          .toLowerCase();
      final roleToUse = savedRole ?? _role.value.toLowerCase();
      if (!doc.exists) {
        // If user doesn't exist in Firestore, create a new entry
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'name': googleUser.displayName ?? '',
          'email': googleUser.email,
          'role': roleToUse,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      Get.offAllNamed('/home', arguments: {'role': roleToUse, 'uid': uid});
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Sign In failed',
        e.message ?? e.code,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', '$e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      _submitting.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Log in')),
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
                        labelText: 'Login as',
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
                        label: const Text('Sign in with Google'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _submitting.value ? null : _login,
                        child: _submitting.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Log in'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Get.toNamed('/signup'),
                    child: Text(
                      'Create an account',
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
