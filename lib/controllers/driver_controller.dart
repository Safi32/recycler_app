import 'package:get/get.dart';

import 'package:recycler/modals/recycler_request.dart';
import 'package:recycler/views/driver/record_weight.dart';

class DriverController extends GetxController {
  var requests = <RecyclerRequest>[
    RecyclerRequest(
      id: '#request-1',
      wasteType: 'plastic',
      pickupDate: '2025-10-16 – 03:04',
      status: 'Pending',
    ),
    RecyclerRequest(
      id: '#request-2',
      wasteType: 'paper',
      pickupDate: '2025-10-17 – 03:04',
      status: 'Collected',
    ),
  ].obs;

  void markAsCollected(int index) {
    requests[index] = RecyclerRequest(
      id: requests[index].id,
      wasteType: requests[index].wasteType,
      pickupDate: requests[index].pickupDate,
      status: 'Collected',
    );
    requests.refresh();
  }

  void recordWeight(int index) {
    Get.to(() => RecordWeight(request: requests[index]));
  }
}
