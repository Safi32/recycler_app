import 'package:flutter/material.dart';
import 'package:recycler/utils/colors.dart';

class RecyclingRequest extends StatefulWidget {
  const RecyclingRequest({super.key});

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
      appBar: AppBar(title: const Text('Recycler App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Submit Recycling Request',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedWaste,
                decoration: InputDecoration(
                  labelText: 'Waste Type',
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: _wasteTypes
                    .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedWaste = v),
                validator: (v) => v == null || v.isEmpty ? 'Please select a waste type' : null,
              ),

              const SizedBox(height: 12),

              // Pickup Date
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Pickup Date',
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                controller: TextEditingController(text: _selectedDate != null ? _selectedDate!.toIso8601String().split('T').first : ''),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  suffixIcon: const Icon(Icons.access_time),
                ),
                controller: TextEditingController(text: _selectedTime?.format(context) ?? ''),
                onTap: _pickTime,
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request submitted')));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.connectButtonBg),
                  child: const Text('Submit Request'),
                ),
              ),

              const SizedBox(height: 20),
              const Text('Your Requests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
            
              Card(
                color: Colors.black.withOpacity(0.35),
                child: ListTile(
                  title: const Text('Plastic'),
                  subtitle: const Text('Date: 2025-10-16 – 03:04\nStatus: pending'),
                  trailing: const Icon(Icons.access_time, color: Colors.orange),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: Colors.black.withOpacity(0.35),
                child: ListTile(
                  title: const Text('Paper'),
                  subtitle: const Text('Date: 2025-10-17 – 03:04\nStatus: collected'),
                  trailing: const Icon(Icons.local_shipping, color: Colors.blue),
                ),
              ),
            ],
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
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _selectedTime ?? TimeOfDay.now());
    if (picked != null) setState(() => _selectedTime = picked);
  }
}
