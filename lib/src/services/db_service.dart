import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pocketbase/pocketbase.dart';
import 'package:ski/src/models/item.dart';
import 'package:toastification/toastification.dart';

const String apiBaseUrl = 'http://192.168.68.65:8090';
final pb = PocketBase(apiBaseUrl);

Future<Item?> getItem(BuildContext context, String id) async {
  try {
    final record = await pb
        .collection('inventory')
        .getFirstListItem(
          'barcode="$id"',
        )
        .timeout(const Duration(seconds: 2), onTimeout: () {
      toastification.show(
        applyBlurEffect: true,
        showProgressBar: true,
        autoCloseDuration: const Duration(seconds: 4),
        title: const Text('Tilkobling feilet.'),
        description: const Text(
            'Database responderte ikke. Sjekk om du har problemer med tilkoblingen.'),
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        context: context,
      );
      throw 'timeout';
    });
    return Item.fromJson(record.data);
  } catch (e, a) {
    // Show an error toast for exceptions
    if (e is ClientException && e.statusCode == 404) {
      toastification.show(
        title: const Text('Fant ikke barcode'),
        description: const Text(
            'Fant ikke utstyr med matchende barcode. Registrer utstyr først.'),
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        context: context,
      );
    } else if (e != 'timeout') {
      // Show an error toast for other exceptions
      toastification.show(
        title: Text('Error: $e'),
        description: Text(a.toString()),
        type: ToastificationType.error,
        context: context,
      );
    }
    return null;
  }
}

/* Future<bool> checkInventoryItem(String id) async {
  final record = await pb.collection('inventory').getFirstListItem(
        'barcode=$id',
      );
  if (record.data['status'] == 0) return true;
  return false;
} */

Future<bool> createInventoryItem(
    BuildContext context, Map<String, dynamic> data) async {
  final url = Uri.parse('$apiBaseUrl/create');
  try {
    final response = await http.post(url, body: json.encode(data), headers: {
      'Content-Type': 'application/json'
    }).timeout(const Duration(seconds: 2), onTimeout: () {
      toastification.show(
        applyBlurEffect: true,
        showProgressBar: true,
        autoCloseDuration: const Duration(seconds: 4),
        title: const Text('Opprettelse av nytt lagerobjekt feilet.'),
        description: const Text(
            'Database responderte ikke. Sjekk om du har problemer med tilkoblingen.'),
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        context: context,
      );
      return http.Response('timeout.', 500);
    });
    if (response.statusCode == 201) {
      toastification.show(
        applyBlurEffect: true,
        showProgressBar: true,
        autoCloseDuration: const Duration(seconds: 4),
        title: const Text('Lagerobjekt lagt til i lager.'),
        type: ToastificationType.success,
        style: ToastificationStyle.flatColored,
        context: context,
      );
      return true;
    } else if (response.statusCode == 500) {
      return false;
    } else {
      // Show an error toast
      Map resp = jsonDecode(response.body);
      toastification.show(
        title: const Text('Opprettelse av nytt lagerobjekt feilet.'),
        description: Text('Feilmelding: ${resp.entries.first.value}'),
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        context: context,
      );
      return false;
    }
  } catch (e, a) {
    // Show an error toast for exceptions
    toastification.show(
      title: Text('Error: $e'),
      description: Text(a.toString()),
      type: ToastificationType.error,
      context: context,
    );
    return false;
  }
}

// Function to reserve an item
Future<bool> reserveItem(
    BuildContext context, String id, String phoneNumber, String name) async {
  final url =
      Uri.parse('$apiBaseUrl/reserve/$id?phonenumber=$phoneNumber&name=$name');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return true;
    } else {
      // Show an error toast
      toastification.show(
        title: Text('Error: ${response.body}'),
        type: ToastificationType.error,
        context: context,
      );
      return false;
    }
  } catch (e) {
    // Show an error toast for exceptions
    toastification.show(
      title: Text('Error: $e'),
      type: ToastificationType.error,
      context: context,
    );
    return false;
  }
}

// Function to reserve an item
Future<bool> setInactive(BuildContext context, String id) async {
  final url = Uri.parse('$apiBaseUrl/inactive/$id');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return true;
      // Optionally, you could also show a success toast here
    } else {
      // Show an error toast
      toastification.show(
        title: Text('Error: ${response.body}'),
        type: ToastificationType.error,
        context: context,
      );
      return false;
    }
  } catch (e) {
    // Show an error toast for exceptions
    toastification.show(
      title: Text('Error: $e'),
      type: ToastificationType.error,
      context: context,
    );
    return false;
  }
}

// Function to check if an item is deliverable
Future<bool> deliverItem(
    BuildContext context, String id, String tilstand, String moreInfo) async {
  try {
    final url = Uri.parse(
        '$apiBaseUrl/deliver/$id?tilstand=$tilstand&moreInfo=$moreInfo');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      toastification.show(
        applyBlurEffect: true,
        showProgressBar: true,
        autoCloseDuration: const Duration(seconds: 4),
        title: const Text('Utstyr innlevert.'),
        type: ToastificationType.success,
        style: ToastificationStyle.flatColored,
        context: context,
      );

      return true;
    } else {
      // Show an error toast
      toastification.show(
        title: Text('Error: ${response.body}'),
        type: ToastificationType.error,
        context: context,
      );
      return false;
    }
  } catch (e) {
    // Show an error toast for exceptions
    toastification.show(
      title: Text('Error: $e'),
      type: ToastificationType.error,
      context: context,
    );
    return false;
  }
}
