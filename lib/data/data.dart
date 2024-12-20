import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:circuitbox/models/item.dart';

Future<String> getLocalFilePath() async {
  final directory = await getApplicationDocumentsDirectory();
  return '${directory.path}/items.json'; // Path to a writable directory
}

Future<List<Item>> loadItems() async {
  try {
    final filePath = await getLocalFilePath();
    final file = File(filePath);

    print("File path for loading: ${file.path}");

    if (!file.existsSync()) {
      print("File not found, returning empty list.");
      return [];
    }

    final String response = await file.readAsString();
    final List<dynamic> data = json.decode(response);

    // Inject data into Item objects
    return data.map((itemData) => Item.fromJson(itemData)).toList();
  } catch (e) {
    print("Error loading items: ${e.toString()}");
    return [];
  }
}

Future<void> saveItems(List<Item> items) async {
  try {
    final filePath = await getLocalFilePath();
    final file = File(filePath);
    final String jsonString = json.encode(items.map((e) => e.toJson()).toList());

    print("File path for saving: ${file.path}");
    print("Data being saved: $jsonString");

    await file.writeAsString(jsonString);

    print("Items saved successfully.");
  } catch (e) {
    print("Error saving items: ${e.toString()}");
  }
}
