import 'package:flutter/material.dart';
import 'package:ski/src/sample_feature/qr_scan_view.dart';

class RentalForm extends StatefulWidget {
  const RentalForm({super.key});

  @override
  _RentalFormState createState() => _RentalFormState();
}

class _RentalFormState extends State<RentalForm> {
  bool ski = false;
  bool poles = false;
  bool boots = false;
  bool helmet = false;
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 100,
            ),
            CheckboxListTile(
              title: const Text('Ski'),
              value: ski,
              onChanged: (bool? value) {
                setState(() {
                  ski = value!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Staver'),
              value: poles,
              onChanged: (bool? value) {
                setState(() {
                  poles = value!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Sko'),
              value: boots,
              onChanged: (bool? value) {
                setState(() {
                  boots = value!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Hjelm'),
              value: helmet,
              onChanged: (bool? value) {
                setState(() {
                  helmet = value!;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Navn'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Telefon'),
                keyboardType: TextInputType.phone,
              ),
            ),
            // Add additional buttons or form fields if needed
            const SizedBox(
              height: 40,
            ),
            Center(
              child: FilledButton(
                onPressed: _handleScanEquipment,
                child: const Text('Scan utstyr'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleScanEquipment() {
    final String name = nameController.text.trim();
    final String phone = phoneController.text.trim();
    final hasEquipmentSelected = ski || poles || boots || helmet;

    if (name.isEmpty || phone.isEmpty || !hasEquipmentSelected) {
      // Show an error message if validation fails
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content: const Text(
              'Please enter both name and phone number, and select at least one equipment.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      );
    } else {
      // If validation passes, create the list of items to be scanned
      final List<String> itemsToScan = [
        if (ski) 'Ski',
        if (poles) 'Staver',
        if (boots) 'Sko',
        if (helmet) 'Hjelm',
      ];

      // Navigate to QRScanPage and pass the itemsToScan list
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => QRScanPage(items: itemsToScan, name, phone, null),
      ));
    }
  }
}
