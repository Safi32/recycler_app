import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:recycler/controllers/auth_controller.dart';
import 'package:recycler/utils/colors.dart'; // keep this if you already have AppColors

class RecyclingRequest extends StatefulWidget {
  RecyclingRequest({super.key});
  

  @override
  State<RecyclingRequest> createState() => _RecyclingRequestState();
}

class _RecyclingRequestState extends State<RecyclingRequest> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _wasteTypes = [
    'Plastic',
    'Paper',
    'Glass',
    'Metal',
    'Electronic waste',
  ];

  String? _selectedWaste;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _selectedWaste = _wasteTypes.first;
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycler App'),
        actions: [
          IconButton(
            onPressed: () {
              authController.logout();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Submit Recycling Request',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),

                // Waste Type Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedWaste,
                  decoration: InputDecoration(
                    labelText: 'Waste Type',
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: _wasteTypes
                      .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedWaste = v),
                  validator: (v) => v == null || v.isEmpty
                      ? 'Please select a waste type'
                      : null,
                ),

                const SizedBox(height: 12),

                // Pickup Date
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Pickup Date',
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  controller: TextEditingController(
                    text: _selectedDate != null
                        ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                        : '',
                  ),
                  onTap: _pickDate,
                ),

                const SizedBox(height: 12),

                // Pickup Time
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Pickup Time',
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: const Icon(Icons.access_time),
                  ),
                  controller: TextEditingController(
                    text: _selectedTime != null
                        ? _selectedTime!.format(context)
                        : '',
                  ),
                  onTap: _pickTime,
                ),

                const SizedBox(height: 16),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.connectButtonBg,
                    ),
                    child: const Text('Submit Request'),
                  ),
                ),

                const SizedBox(height: 24),
                const Text(
                  'Your Requests',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),

                // Live Requests from Firestore
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('recyclingRequests')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text('No requests yet.');
                    }

                    final docs = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: docs.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        return Card(
                          color: Colors.black.withOpacity(0.35),
                          child: ListTile(
                            title: Text(data['wasteType'] ?? ''),
                            subtitle: Text(
                              'Date: ${data['pickupDate']} – ${data['pickupTime']}\nStatus: ${data['status']}',
                            ),
                            trailing: Icon(
                              data['status'] == 'pending'
                                  ? Icons.access_time
                                  : Icons.local_shipping,
                              color: data['status'] == 'pending'
                                  ? Colors.orange
                                  : Colors.blue,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      final request = {
        'wasteType': _selectedWaste,
        'pickupDate': _selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
            : '',
        'pickupTime': _selectedTime?.format(context),
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      };

      try {
        await FirebaseFirestore.instance
            .collection('recyclingRequests')
            .add(request);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request submitted successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error submitting request: $e')));
      }
    }
  }
}
