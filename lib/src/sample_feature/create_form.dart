import 'package:flutter/material.dart';
import 'package:ski/src/models/item.dart';
import 'package:ski/src/sample_feature/qr_scan_view.dart';

class CreateForm extends StatefulWidget {
  const CreateForm({super.key});

  @override
  _CreateFormState createState() => _CreateFormState();
}

class _CreateFormState extends State<CreateForm> {
  String? selectedEquipment;
  final merkeController = TextEditingController();
  final modellController = TextEditingController();
  final aarController = TextEditingController();
  String? selectedCondition;

  final Map<String, String> conditions = {
    'god': 'God',
    'litt slitt': 'Litt Slitt',
    'veldig slitt': 'Veldig Slitt',
    'skadet': 'Skadet',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          forceMaterialTransparency: true,
          title: const Text('Legg til utstyr'),
        ),
        body: Container(
          height: MediaQuery.sizeOf(context).height,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  opacity: 0.4,
                  image: AssetImage("assets/images/skis.png"),
                  fit: BoxFit.cover),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(
                      height: 100,
                    ),
                    ...['Ski', 'Staver', 'Sko', 'Hjelm'].map((equipment) {
                      return RadioListTile<String>(
                        title: Text(equipment),
                        value: equipment,
                        groupValue: selectedEquipment,
                        onChanged: (value) {
                          setState(() {
                            selectedEquipment = value;
                          });
                        },
                      );
                    }).toList(),
                    TextFormField(
                      controller: merkeController,
                      decoration: const InputDecoration(labelText: 'Merke'),
                    ),
                    // Add additional buttons or form fields if needed
                    TextFormField(
                      controller: modellController,
                      decoration: const InputDecoration(labelText: 'Modell'),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: aarController,
                      decoration: const InputDecoration(labelText: 'År'),
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedCondition,
                      hint: const Text('Velg tilstand'),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCondition = newValue;
                        });
                      },
                      items: conditions.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: _handleScanEquipment,
                        child: const Text('Scan utstyr'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  void _handleScanEquipment() {
    // Attempt to convert aarController's text to an integer
    final String merke = merkeController.text.trim();
    final String modell = modellController.text.trim();
    final int? aar;
    final hasEquipmentSelected = selectedEquipment != null;
    final hasConditionSelected = selectedCondition != null;

    try {
      if (aarController.text.isNotEmpty) {
        aar = int.parse(aarController.text.trim());
      } else {
        aar = 0;
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content:
              const Text('Under År, skriv et årstall eller la det stå blankt.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      );
      return;
    }
    if (merke.isEmpty || !hasEquipmentSelected || !hasConditionSelected) {
      // Show an error message if validation fails
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content:
              const Text('Skriv inn merke, velg tilstand og velg utstyrstype.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => QRScanPage(
              items: [selectedEquipment!],
              "",
              "",
              Item(
                  merke: merke,
                  modell: modell,
                  aar: aar!,
                  type: selectedEquipment!,
                  tilstand: selectedCondition!,
                  barcode: "",
                  rentalStatus: 0))));

      // Implement your submission logic here
    }
  }
}
