import 'dart:io';
import 'package:ski/src/sample_feature/qr_scan_view.dart';
import 'package:ski/src/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:ski/src/models/item.dart';
import 'package:toastification/toastification.dart';

class QRDelPage extends StatefulWidget {
  static const routeName = "qr";

  const QRDelPage({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _QRDelPageState();
}

class _QRDelPageState extends State<QRDelPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool processingQR = false;
  double opacity = 0.0;
  Item? item;
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
          if (item != null) ItemCard(item: item!),
          if (item != null)
            ElevatedButton(
              child: const Text('Slett utstyr'),
              onPressed: /* newItem == null
                  ? null // This disables the button if newItem is null
                  :  */
                  () => _showConfirmationDialog(context),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
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

      try {
        // Call the function from your db_services and wait for the response
        item = await getItem(context, barcode);
        if (item == 2) {
          toastification.show(
              context: context,
              title: const Text('Utstyret valgt er allerede tatt ut av lager.'),
              description: const Text(
                  'Scan et annet utstyr eller trykk ferdig om alt utstyr er scannet.'),
              type: ToastificationType.info);
        }
      } catch (e) {
        // Handle errors, for example, showing an error message
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
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _showConfirmationDialog(BuildContext context) {
    // Viser dialogen
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bekreftelse'),
          content: const Text('Er du sikker på at du ønsker å gjøre dette?'),
          actions: <Widget>[
            // Nei-knappen
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Lukker dialogen
              child: const Text('Nei'),
            ),
            // Ja-knappen
            ElevatedButton(
              onPressed: () async {
                try {
                  Navigator.of(context).pop();
                  setState(() {
                    opacity = 0.8;
                  });
                  //ewItem is not null here, as the button would be disabled otherwise
                  bool inactive = await setInactive(context, item!.barcode);
                  if (inactive) {
                    toastification.show(
                        applyBlurEffect: true,
                        showProgressBar: true,
                        autoCloseDuration: const Duration(seconds: 4),
                        context: context,
                        title: const Text('Utstyr er tatt ut av portefølje.'),
                        type: ToastificationType.success);
                    setState(() {
                      opacity = 0;
                      item = null;
                    });
                  } else {
                    toastification.show(
                        applyBlurEffect: true,
                        showProgressBar: true,
                        autoCloseDuration: const Duration(seconds: 4),
                        context: context,
                        title: const Text('Noe gikk galt.'),
                        description: const Text(
                            'Prøv igjen, eller endre status manuelt i databasen.'),
                        type: ToastificationType.info);
                  }
                  // Then update the corresponding item's scanned status to true
                  // Assuming scannedItems is a Map<String, bool> as in the previous example
                } catch (e) {
                  // Handle errors, for example, showing an error message
                  print("Error checking inventory type: $e");
                }
              },
              child: const Text('Ja'),
            ),
          ],
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
