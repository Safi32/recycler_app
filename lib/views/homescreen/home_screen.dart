import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:recycler/utils/colors.dart';
import 'package:recycler/views/admin/waste_categories.dart';
import 'package:recycler/views/driver/driver.dart';
import 'package:recycler/views/household/bottom_bar.dart';
import 'package:recycler/widgets/test_action_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final args = Get.arguments as Map<String, dynamic>?;
    final String role = (args?['role'] ?? '').toString();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: width > 420 ? 420 : width),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.recycling,
                      size: 86,
                      color: AppColors.recycleIcon,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Recycler App',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Connect your wallet to continue',
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.connectButtonBg,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.account_balance_wallet, size: 18),
                      label: const Text('Connect Wallet'),
                    ),
                  ),

                  const SizedBox(height: 26),
                  const Text(
                    'Test Login Options',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (role == 'household' || role.isEmpty)
                    TestActionButton(
                      label: 'Household',
                      backgroundColor: AppColors.householdButton,
                      foregroundColor: Colors.white,
                      onPressed: () {
                        Get.to(() => const BottomBar());
                      },
                    ),
                  const SizedBox(height: 12),
                  if (role == 'driver')
                    TestActionButton(
                      label: 'Driver',
                      backgroundColor: AppColors.driverButton,
                      foregroundColor: Colors.black87,
                      onPressed: () {
                        Get.to(() => Driver());
                      },
                    ),
                  const SizedBox(height: 12),
                  if (role == 'admin')
                    TestActionButton(
                      label: 'Admin',
                      backgroundColor: AppColors.adminButton,
                      foregroundColor: Colors.white,
                      onPressed: () {
                        Get.to(() => WasteCategories());
                      },
                    ),

                  const SizedBox(height: 28),
                  TestActionButton(
                    label: 'Run Penalty Test Scenario',
                    backgroundColor: AppColors.yellowButton.withOpacity(0.9),
                    foregroundColor: Colors.black87,
                    onPressed: null,
                    disabledBackgroundColor: AppColors.yellowButton.withOpacity(
                      0.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
