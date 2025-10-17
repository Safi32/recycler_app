import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recycler/controllers/bottom_bar_controller.dart';
import 'package:recycler/views/household/recycling_request.dart';
import 'package:recycler/views/household/credits.dart';
import 'package:recycler/utils/colors.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final BottomBarController ctrl = Get.put(BottomBarController());

    final pages = [RecyclingRequest(), Credits()];

    return Scaffold(
      body: Obx(
        () => IndexedStack(index: ctrl.selectedIndex.value, children: pages),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: ctrl.selectedIndex.value,
          backgroundColor: AppColors.scaffoldBackground,
          selectedItemColor: AppColors.recycleIcon,
          unselectedItemColor: Colors.white70,
          onTap: ctrl.setIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.recycling),
              label: 'Recycling',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: 'Balance',
            ),
          ],
        ),
      ),
    );
  }
}
