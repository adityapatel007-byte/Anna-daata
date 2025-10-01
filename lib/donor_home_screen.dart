import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DonorHomeScreen extends StatelessWidget {
  const DonorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Donor Home'), backgroundColor: Color(0xFF43A047)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FoodPostForm(),
      ),
    );
  }
}

class FoodPostForm extends StatefulWidget {
  @override
  State<FoodPostForm> createState() => _FoodPostFormState();
}

class _FoodPostFormState extends State<FoodPostForm> {
  final TextEditingController descController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  String? timeError;
  String? postedFood;
  String selectedPeriod = 'AM';
  
  bool _isValidTimeFormat(String time) {
    // Check if time format is valid (HH:MM or H:MM)
    RegExp timeRegex = RegExp(r'^([0-9]|1[0-2]):([0-5][0-9])$');
    return timeRegex.hasMatch(time);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Post Leftover Food', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF388E3C))),
              const SizedBox(height: 20),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: 'Food Description',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: 'Pickup Location',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: timeController,
                      decoration: InputDecoration(
                        labelText: 'Pickup Time (HH:MM)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                        errorText: timeError,
                        hintText: '12:30',
                      ),
                      keyboardType: TextInputType.text,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                        LengthLimitingTextInputFormatter(5),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String>(
                        value: selectedPeriod,
                        isExpanded: true,
                        underline: SizedBox(),
                        items: ['AM', 'PM'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Center(child: Text(value, style: TextStyle(fontSize: 16))),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedPeriod = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('Post Food'),
                onPressed: () {
                  setState(() {
                    timeError = null;
                  });
                  
                  // Validate time format
                  if (timeController.text.isEmpty || !_isValidTimeFormat(timeController.text)) {
                    setState(() {
                      timeError = 'Please enter time in HH:MM format (e.g., 12:30)';
                    });
                    return;
                  }
                  
                  setState(() {
                    postedFood = '${descController.text} at ${timeController.text} ${selectedPeriod}';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Food posted! NGOs will be notified.'),
                      backgroundColor: Color(0xFF43A047),
                    ),
                  );
                  // Clear form after posting
                  descController.clear();
                  locationController.clear();
                  timeController.clear();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF43A047),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (postedFood != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFB2FF59),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Posted: $postedFood', style: const TextStyle(fontSize: 18, color: Color(0xFF388E3C))),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
