import 'package:flutter/material.dart';
import 'package:ski/src/models/item.dart';
import 'package:ski/src/services/db_service.dart';

class ReturnForm extends StatefulWidget {
  const ReturnForm({super.key, required this.items});

  final List<Item?> items;

  @override
  _ReturnFormState createState() => _ReturnFormState();
}

class _ReturnFormState extends State<ReturnForm> {
  late Map<Item, String> conditionMap;
  Map<Item, TextEditingController> additionalInfoControllers = {};

  final Map<String, String> conditions = {
    'god': 'God',
    'litt slitt': 'Litt Slitt',
    'veldig slitt': 'Veldig Slitt',
    'skadet': 'Skadet',
  };

  @override
  void initState() {
    super.initState();
    conditionMap = {for (var item in widget.items) item!: item.tilstand};
    // Initialize text editing controllers for each item's additional info
    for (var item in widget.items) {
      additionalInfoControllers[item!] = TextEditingController();
    }
  }

  @override
  void dispose() {
    // Dispose the controllers when the state is disposed
    for (var controller in additionalInfoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  DropdownButton<String> getConditionDropdownButton(Item item) {
    return DropdownButton<String>(
      value: conditionMap[item],
      onChanged: (newValue) {
        setState(() {
          conditionMap[item] = newValue!;
        });
      },
      items: conditions.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        body: Container(
          height: MediaQuery.sizeOf(context).height,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  opacity: 0.4,
                  image: AssetImage("assets/images/skis.png"),
                  fit: BoxFit.cover),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Innlevering av',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.items.length,
                    itemBuilder: (ctx, i) {
                      final Item item = widget.items[i]!;
                      return Column(
                        children: [
                          ListTile(
                            title: Text('${item.type} tilstand'),
                            trailing: getConditionDropdownButton(item),
                          ),
                          TextFormField(
                            controller: additionalInfoControllers[item],
                            decoration: const InputDecoration(
                              labelText: 'Tilleggsinformasjon',
                              border: OutlineInputBorder(),
                              isDense: true, // Reduces the field's height
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: _handleSubmit,
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  void _handleSubmit() async {
    for (var item in widget.items) {
      String id =
          item!.barcode; // Assuming barcode is the ID used in deliverItem
      String tilstand =
          conditionMap[item] ?? 'god'; // Fallback to 'god' if not found
      String moreInfo = additionalInfoControllers[item]?.text ??
          ''; // Fallback to an empty string if controller is not found

      // Call the deliverItem function for each item
      await deliverItem(context, id, tilstand, moreInfo);
    }

    // After all deliverItem calls, pop back to the main page
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
