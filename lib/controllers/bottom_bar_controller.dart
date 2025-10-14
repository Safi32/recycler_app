import 'package:get/get.dart';

class BottomBarController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  void setIndex(int i) => selectedIndex.value = i;
}
