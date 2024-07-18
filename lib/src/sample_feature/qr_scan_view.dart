import 'dart:io';
import 'package:ski/src/sample_feature/return_form.dart';
import 'package:ski/src/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:ski/src/models/item.dart';
import 'package:toastification/toastification.dart';

class QRScanPage extends StatefulWidget {
  static const routeName = "qr";

  const QRScanPage(this.name, this.phone, this.createItem,
      {super.key, required this.items});

  final List<String> items;
  final String name;
  final String phone;
  final Item? createItem;
  @override
  State<StatefulWidget> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  createScannedItemsMap(List<String> items) {
    if (items.isEmpty) {
      return {
        'ski': false,
        'staver': false,
        'sko': false,
        'hjelm': false,
      };
    } else {
      return {for (var item in items) item.toLowerCase(): false};
    }
  }

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  Map<String, bool>? scannedItems;
  List<Item?> itemObjects = [];
  Item? newItem;
  bool processingQR = false;
  double opacity = 0.0;
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  void initState() {
    scannedItems = createScannedItemsMap(widget.items);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Camera Scanner'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Stack(children: [
              QRView(
                overlay: QrScannerOverlayShape(
                    borderRadius: 8,
                    borderWidth: 2,
                    borderLength: 30,
                    borderColor: Colors.lightGreen),
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
              ),
              /* if (processingQR) */
              Opacity(
                opacity: opacity,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ]),
          ),
          if (widget.createItem == null)
            Expanded(
              flex: 2,
              child: ListView(
                children: scannedItems!.keys.map((String key) {
                  String k = key.capitalize();
                  return CheckboxListTile(
                    enableFeedback: false,
                    dense: true,
                    title: Text('$k skannet'),
                    value: scannedItems![key],
                    onChanged: (bool? value) {
                      /* setState(() {
                        scannedItems![key] = value!;
                      }); */
                    },
                  );
                }).toList(),
              ),
            ),
          if (widget.createItem != null && newItem != null)
            ItemCard(item: newItem!),
          if (widget.createItem != null && newItem == null)
            ItemCard(item: widget.createItem!),
          if (widget.createItem != null)
            ElevatedButton(
              child: const Text('Legg til'),
              onPressed: newItem == null
                  ? null // This disables the button if newItem is null
                  : () async {
                      try {
                        setState(() {
                          opacity = 0.8;
                        });
                        //ewItem is not null here, as the button would be disabled otherwise
                        bool created = await createInventoryItem(
                            context, newItem!.toJson());
                        setState(() {
                          opacity = 0;
                        });
                        // Then update the corresponding item's scanned status to true
                        // Assuming scannedItems is a Map<String, bool> as in the previous example
                      } catch (e) {
                        // Handle errors, for example, showing an error message
                        print("Error checking inventory type: $e");
                      }
                    },
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: widget.items.isEmpty && itemObjects.isEmpty
                  ? null
                  : () async {
                      if (widget.items.isNotEmpty) {
                        if (widget.createItem != null) {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        } else if (scannedItems!.length == itemObjects.length) {
                          List<bool> dones = [];
                          for (Item? i in itemObjects) {
                            bool done = await reserveItem(
                                context, i!.barcode, widget.phone, widget.name);
                            dones.add(done);
                          }
                          if (dones.length == itemObjects.length &&
                              !dones.contains(false)) {
                            toastification.show(
                                applyBlurEffect: true,
                                showProgressBar: false,
                                autoCloseDuration: const Duration(seconds: 3),
                                context: context,
                                title: const Text('Utleie registrert.'),
                                type: ToastificationType.success);
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          } else {
                            toastification.show(
                                style: ToastificationStyle.simple,
                                applyBlurEffect: true,
                                showProgressBar: false,
                                autoCloseDuration: const Duration(seconds: 3),
                                context: context,
                                title: const Text('Utleie feilet.'),
                                type: ToastificationType.info);
                          }
                        } else {
                          int scanned = 0;
                          for (bool i in scannedItems!.values) {
                            if (i) scanned += 1;
                          }
                          int? finishValue = await showWarningDialog(
                              context, scanned, scannedItems!.length);
                          print(finishValue);
                          if (finishValue == 2) {
                            toastification.show(
                                style: ToastificationStyle.simple,
                                applyBlurEffect: true,
                                showProgressBar: false,
                                autoCloseDuration: const Duration(seconds: 3),
                                context: context,
                                title: const Text(
                                    'Registrering avsluttet uten utleie.'),
                                type: ToastificationType.info);
                          }
                          if (finishValue == 1) {
                            toastification.show(
                                applyBlurEffect: true,
                                showProgressBar: false,
                                autoCloseDuration: const Duration(seconds: 3),
                                context: context,
                                title: const Text('Utleie registrert.'),
                                type: ToastificationType.success);
                          }
                          if (finishValue == 1 || finishValue == 2) {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          }
                        }
                      } else if (itemObjects.isNotEmpty) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                ReturnForm(items: itemObjects)));
                      }
                    },
              child: const Text('Ferdig'),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (processingQR) return;
      // Make sure to use 'async' here
      setState(() {
        result = scanData;
        processingQR = true;
        opacity = 0.8;
      });

      // Decode the QR code result if needed or extract the ID directly
      String barcode = result!.code
          .toString(); // Assuming result.code contains the ID directly

      if (widget.createItem == null) {
        try {
          // Call the function from your db_services and wait for the response
          Item? item = await getItem(context, barcode);

          // Then update the corresponding item's scanned status to true
          // Assuming scannedItems is a Map<String, bool> as in the previous example
          if (item != null) {
            if (scannedItems!.containsKey(item.type) &&
                itemObjects.singleWhere((tr) => tr!.barcode == item.barcode,
                        orElse: () => null) ==
                    null &&
                ((widget.items.isNotEmpty && item.rentalStatus == 0) ||
                    widget.items.isEmpty && item.rentalStatus == 1)) {
              toastification.show(
                  applyBlurEffect: true,
                  showProgressBar: false,
                  autoCloseDuration: const Duration(seconds: 3),
                  context: context,
                  title: Text('${item.type} skannet.'),
                  type: ToastificationType.success);
              setState(() {
                itemObjects.add(item);

                scannedItems![item.type] =
                    true; // Set the scanned status to true
              });
            } else if (item.rentalStatus == 0 &&
                widget.items.isEmpty &&
                widget.createItem == null) {
              toastification.show(
                  applyBlurEffect: true,
                  showProgressBar: true,
                  autoCloseDuration: const Duration(seconds: 4),
                  context: context,
                  title: const Text('Skannet utstyr er ikke utleid.'),
                  description: const Text(
                      'Utstyret er ikke registrert som utleid. Vennligst skann et annet utstyr.'),
                  type: ToastificationType.info);
            } else if (item.rentalStatus != 0 &&
                widget.items.isNotEmpty &&
                widget.createItem == null) {
              toastification.show(
                  applyBlurEffect: true,
                  showProgressBar: true,
                  autoCloseDuration: const Duration(seconds: 4),
                  context: context,
                  title: const Text('Skannet utstyr er ikke tilgjengelig.'),
                  description: const Text(
                      'Utstyret er registrert som utleid eller utgått. Vennligst skann et annet utstyr.'),
                  type: ToastificationType.info);
            } else if (scannedItems!.containsKey(item.type) &&
                itemObjects.singleWhere((tr) => tr!.barcode == item.barcode,
                        orElse: () => null) !=
                    null) {
              toastification.show(
                  applyBlurEffect: true,
                  showProgressBar: true,
                  autoCloseDuration: const Duration(seconds: 4),
                  context: context,
                  title: const Text('Du har allerede scannet dette utstyret.'),
                  description: const Text(
                      'Scan et annet utstyr eller trykk ferdig om alt utstyr er scannet.'),
                  type: ToastificationType.info);
            } else if (!scannedItems!.containsKey(item.type)) {
              toastification.show(
                  applyBlurEffect: true,
                  showProgressBar: true,
                  autoCloseDuration: const Duration(seconds: 4),
                  context: context,
                  title: Text('Du scannet utstyrstype ${item.type}'),
                  description: const Text(
                      'Dette er ikke en del av utstyret valgt for utleie.'),
                  type: ToastificationType.info);
            }
          }
        } catch (e) {
          // Handle errors, for example, showing an error message
          print("Error checking inventory type: $e");
        } finally {
          // Use a delay before allowing another scan to be processed
          setState(() {});
          Future.delayed(const Duration(seconds: 2), () {
            setState(() {
              opacity = 0;
              processingQR = false;
            }); // Ready to process a new scan
          });
          // to prevent too frequent processing
        }
      } else {
        try {
          setState(() {
            newItem = widget.createItem!
                .putBarcode(barcode); // Set the scanned status to true
          });
        } catch (e) {
          // Handle errors, for example, showing an error message
          print("Error checking inventory type: $e");
        } finally {
          // Use a delay before allowing another scan to be processed
          // to prevent too frequent processing
          setState(() {
            opacity = 0;
          });
          Future.delayed(const Duration(seconds: 2), () {
            setState(() {
              processingQR = false;
            }); // Ready to process a new scan
          });
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

class ItemCard extends StatelessWidget {
  final Item item;

  const ItemCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Merke: ${item.merke.capitalize()}',
                    style: const TextStyle(
                        fontSize: 16, overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'År: ${item.aar}',
                    style: const TextStyle(
                        fontSize: 16, overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tilstand: ${item.tilstand}',
                    style: const TextStyle(
                        fontSize: 16, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Modell: ${item.modell}',
                    style: const TextStyle(
                        fontSize: 16, overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Type: ${item.type}',
                    style: const TextStyle(
                        fontSize: 16, overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Barcode ID: ${item.barcode}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}

Future showWarningDialog(BuildContext context, int scanned, int chosen) {
  // Controllers to capture input

  // Show dialog
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Er du sikker?'),
      content: scanned == 0
          ? const Text(
              'Du har ikke skannet noe enda, vil du avbryte registreringen?')
          : Text(
              'Du har bare skannet ${scanned} av ${chosen} objekter til utleie. Vil du fortsatt registrere utleie?'),
      actions: <Widget>[
        TextButton(
          child: const Text('Avbryt'),
          onPressed: () => Navigator.of(context).pop(0),
        ),
        TextButton(
          child: const Text('Fortsett'),
          onPressed: () {
            if (scanned != 0) {
              Navigator.of(context).pop(1); // Close the dialog
            } else {
              // Show error message or handle invalid login
              Navigator.of(context).pop(2); // Close the dialog
              // Optionally show an error message
            }
          },
        ),
      ],
    ),
  );
}
