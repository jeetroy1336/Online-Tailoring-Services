import 'package:flutter/material.dart';

class ShirtCustomizationScreen extends StatefulWidget {
  const ShirtCustomizationScreen({super.key});

  @override
  State<ShirtCustomizationScreen> createState() => _ShirtCustomizationScreenState();
}

class _ShirtCustomizationScreenState extends State<ShirtCustomizationScreen> {
  // State variables to hold selected options
  String _selectedCollar = 'Classic';
  String _selectedCuff = 'Single Button';
  String _selectedFabric = 'Cotton';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Your Shirt'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Visual Preview Area
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Icons.checkroom,
                  size: 100,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Option Sections
            _buildOptionSection(
              title: 'Collar Style',
              options: ['Classic', 'Cutaway', 'Button-Down'],
              selectedOption: _selectedCollar,
              onSelected: (value) => setState(() => _selectedCollar = value),
            ),
            _buildOptionSection(
              title: 'Cuff Style',
              options: ['Single Button', 'Double Button', 'French Cuffs'],
              selectedOption: _selectedCuff,
              onSelected: (value) => setState(() => _selectedCuff = value),
            ),
            _buildOptionSection(
              title: 'Fabric Type',
              options: ['Cotton', 'Linen', 'Silk', 'Denim'],
              selectedOption: _selectedFabric,
              onSelected: (value) => setState(() => _selectedFabric = value),
            ),

            // Measurements Section
            Text('Measurements (in inches)', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(child: TextField(decoration: InputDecoration(labelText: 'Chest', border: OutlineInputBorder()))),
                SizedBox(width: 16),
                Expanded(child: TextField(decoration: InputDecoration(labelText: 'Sleeve Length', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 40),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Shirt added to your quote request!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text('Send Inquiry'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build a section of choice chips
  Widget _buildOptionSection({
    required String title,
    required List<String> options,
    required String selectedOption,
    required ValueChanged<String> onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: options.map((option) {
              return ChoiceChip(
                label: Text(option),
                selected: selectedOption == option,
                onSelected: (_) => onSelected(option),
                selectedColor: Colors.purple.shade100,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}