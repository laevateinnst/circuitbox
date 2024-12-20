import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io'; //
import 'package:path_provider/path_provider.dart';
import 'package:circuitbox/models/item.dart';

class AddItemOverlay extends StatefulWidget {
  @override
  _AddItemOverlayState createState() => _AddItemOverlayState();
}

class _AddItemOverlayState extends State<AddItemOverlay> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  // Form key to validate inputs
  final _formKey = GlobalKey<FormState>();

  // Save the item to the JSON file
  Future<void> _saveItem() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Get the application's document directory
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/items.json';
        final file = File(filePath);

        // Read the existing items if the file exists
        List<Item> existingItems = [];
        if (file.existsSync()) {
          final String response = await file.readAsString();
          final data = json.decode(response);
          existingItems = (data as List).map((item) => Item.fromJson(item)).toList();
        }

        // Create the new item
        final newItem = Item(
          name: _nameController.text,
          category: _categoryController.text,
          quantity: int.tryParse(_quantityController.text) ?? 0,
          tags: _tagsController.text.split(','),
        );

        // Add the new item to the list
        existingItems.add(newItem);

        // Save the updated list to the file
        final updatedData = json.encode(existingItems.map((item) => item.toJson()).toList());
        await file.writeAsString(updatedData);

        // Return to the previous screen and notify that an item was added
        Navigator.pop(context, true);
      } catch (e) {
        print("Error saving item: $e");
        // Handle errors properly (e.g., show a snackbar or dialog)
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.white,  // Set background color to white
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,  // Add form key for validation
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Item',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B3B41),  // Dark text for title
                ),
              ),
              const SizedBox(height: 24),

              // Name input field with validation and line style
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  labelStyle: TextStyle(color: Color(0xFF3B3B41)),  // Dark label color
                  hintText: 'Enter item name',
                  hintStyle: TextStyle(color: Color(0xFF3B3B41).withOpacity(0.6)),  // Lighter hint text
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF3B3B41)),  // Dark underline
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: TextStyle(color: Color(0xFF3B3B41)),  // Dark text input
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category input field with validation and line style
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: Color(0xFF3B3B41)),  // Dark label color
                  hintText: 'Enter item category',
                  hintStyle: TextStyle(color: Color(0xFF3B3B41).withOpacity(0.6)),  // Lighter hint text
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF3B3B41)),  // Dark underline
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: TextStyle(color: Color(0xFF3B3B41)),  // Dark text input
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Quantity input field with validation and line style
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  labelStyle: TextStyle(color: Color(0xFF3B3B41)),  // Dark label color
                  hintText: 'Enter item quantity',
                  hintStyle: TextStyle(color: Color(0xFF3B3B41).withOpacity(0.6)),  // Lighter hint text
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF3B3B41)),  // Dark underline
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: TextStyle(color: Color(0xFF3B3B41)),  // Dark text input
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tags input field with line style
              TextFormField(
                controller: _tagsController,
                decoration: InputDecoration(
                  labelText: 'Tags (comma separated)',
                  labelStyle: TextStyle(color: Color(0xFF3B3B41)),  // Dark label color
                  hintText: 'Enter tags for the item',
                  hintStyle: TextStyle(color: Color(0xFF3B3B41).withOpacity(0.6)),  // Lighter hint text
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF3B3B41)),  // Dark underline
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: TextStyle(color: Color(0xFF3B3B41)),  // Dark text input
              ),
              const SizedBox(height: 24),

              // Save button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,  // Align buttons to the center
                children: [
                  // Cancel button
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 2),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);  // Close the dialog or perform other cancel logic
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.all(0),  // Remove default padding
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B3B41),  // Dark text for the cancel button
                        ),
                      ),
                    ),
                  ),

                  // Save button
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 2),
                    decoration: BoxDecoration(
                      color: Color(0xFF3B3B41),  // Dark background for the button
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton(
                      onPressed: _saveItem,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.all(0),  // Remove default padding
                      ),
                      child: Text(
                        'Save Item',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,  // White text for the button
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}
