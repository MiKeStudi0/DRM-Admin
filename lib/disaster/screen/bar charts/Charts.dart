import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class Charts extends StatefulWidget {
  @override
  _ChartsState createState() => _ChartsState();
}

class _ChartsState extends State<Charts> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _requiredQuantityController = TextEditingController();
  final _availableQuantityController = TextEditingController();

  String? _selectedName;

  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      try {
        String name = _nameController.text.trim();
        int requiredQuantity = int.parse(_requiredQuantityController.text.trim());
        int availableQuantity = int.parse(_availableQuantityController.text.trim());
        int totalQuantity = requiredQuantity + availableQuantity;

        await FirebaseFirestore.instance.collection('units').doc(name).set({
          'name': name,
          'totalQuantity': totalQuantity,
          'requiredQuantity': requiredQuantity,
          'availableQuantity': availableQuantity,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data uploaded successfully')),
        );

        _clearForm();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error.toString()}')),
        );
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _requiredQuantityController.clear();
    _availableQuantityController.clear();
  }

  List<Map<String, dynamic>> _filterData(
      List<Map<String, dynamic>> data, String? selectedName) {
    if (selectedName == null || selectedName.isEmpty) {
      return data;
    }
    return data
        .where((item) => (item['name'] as String)
            .toLowerCase()
            .contains(selectedName.toLowerCase()))
        .toList();
  }

  Widget buildTextFormField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String validatorMessage,
    required ColorScheme colorScheme,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: hint,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
      ),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return validatorMessage;
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Real-Time Firebase Pie Charts'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  buildTextFormField(
                    controller: _nameController,
                    hint: 'Name',
                    icon: Icons.person,
                    validatorMessage: 'Please enter a name',
                    colorScheme: colorScheme,
                  ),
                  SizedBox(height: 10),
                  buildTextFormField(
                    controller: _requiredQuantityController,
                    hint: 'Required Quantity',
                    icon: Icons.assignment,
                    validatorMessage: 'Please enter required quantity',
                    colorScheme: colorScheme,
                  ),
                  SizedBox(height: 10),
                  buildTextFormField(
                    controller: _availableQuantityController,
                    hint: 'Available Quantity',
                    icon: Icons.check_circle,
                    validatorMessage: 'Please enter available quantity',
                    colorScheme: colorScheme,
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitData,
                      child: Text('Submit Data'),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Filter by Name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _selectedName = value;
                });
              },
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('units').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final allData = snapshot.data!.docs
                      .map((doc) => doc.data())
                      .toList();

                  final filteredData = _filterData(allData, _selectedName);

                  return ListView.builder(
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      final data = filteredData[index];
                      final required = data['requiredQuantity'] as int;
                      final available = data['availableQuantity'] as int;
                      final total = required + available;

                      final requiredPercentage =
                          (required / total * 100).toStringAsFixed(1);
                      final availablePercentage =
                          (available / total * 100).toStringAsFixed(1);
                      final remainingPercentage =
                          ((total - required - available) / total * 100)
                              .toStringAsFixed(1);

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Unit: ${data['name']}',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              SizedBox(
                                height: 200,
                                child: PieChart(
                                  PieChartData(
                                    sections: [
                                      PieChartSectionData(
                                        value: required.toDouble(),
                                        color: Colors.red,
                                        title: 'Required\n$requiredPercentage%',
                                      ),
                                      PieChartSectionData(
                                        value: available.toDouble(),
                                        color: Colors.green,
                                        title: 'Available\n$availablePercentage%',
                                      ),
                                      PieChartSectionData(
                                        value: (total - required - available)
                                            .toDouble(),
                                        color: Colors.blue,
                                        title: 'Remaining\n$remainingPercentage%',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
