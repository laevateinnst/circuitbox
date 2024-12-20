import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:circuitbox/models/item.dart'; // Import the Item model

class ListViewComponent extends StatefulWidget {
  final List<Item> items;
  final Function(Item) onDeleteItem;

  const ListViewComponent({super.key, required this.items, required this.onDeleteItem});

  @override
  _ListViewComponentState createState() => _ListViewComponentState();
}

class _ListViewComponentState extends State<ListViewComponent> {
  // Helper function to get file path
  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/items.json';
  }

  // Save data to the file
  Future<void> _saveItemsToFile(List<Item> items) async {
    final file = File(await _getFilePath());
    List<Map<String, dynamic>> jsonList = items.map((item) => item.toJson()).toList();
    String jsonString = jsonEncode(jsonList);
    await file.writeAsString(jsonString);
  }

  // Load data from the file
  Future<List<Item>> _loadItemsFromFile() async {
    final file = File(await _getFilePath());
    if (await file.exists()) {
      String jsonString = await file.readAsString();
      List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Item.fromJson(json)).toList();
    }
    return []; // Return empty list if file doesn't exist
  }

  // Function to show the take overlay with editable quantity
  void _showTakeOverlay(BuildContext context, Item item) {
    final TextEditingController takeController = TextEditingController(
      text: '0', // Default value to start from 0
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Take Item', style: TextStyle(color: Color(0xFF3B3B41), fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.black),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the take overlay
                  _showEditOverlay(context, item); // Open the edit overlay
                },
              ),
            ],
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              int quantityToTake = int.tryParse(takeController.text) ?? 0;
              int remainingStock = item.quantity - quantityToTake;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Stock: ${item.quantity}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Minus button
                      IconButton(
                        icon: Icon(Icons.remove, color: Colors.black),
                        onPressed: () {
                          if (quantityToTake > 0) {
                            takeController.text = (quantityToTake - 1).toString();
                            setState(() {}); // Rebuild to update the remaining stock
                          }
                        },
                      ),
                      // TextField for easy number input
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: takeController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              // Ensure the text field contains only numbers
                              int parsedValue = int.tryParse(value) ?? 0;
                              takeController.text = parsedValue.toString();
                            });
                          },
                        ),
                      ),
                      // Plus button
                      IconButton(
                        icon: Icon(Icons.add, color: Colors.black),
                        onPressed: () {
                          if (quantityToTake < item.quantity) {
                            takeController.text = (quantityToTake + 1).toString();
                            setState(() {}); // Rebuild to update the remaining stock
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // Display remaining stock
                  Text(
                    'Remaining: $remainingStock',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.red),
                  ),
                ],
              );
            },
          ),
          actions: [
            // Cancel button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel', style: TextStyle(color: Color(0xFF3B3B41), fontWeight: FontWeight.w500)),
            ),
            // Confirm button
            TextButton(
              onPressed: () {
                // Get the quantity from the controller and update the item
                int quantityToTake = int.tryParse(takeController.text) ?? 0;
                if (quantityToTake > 0 && quantityToTake <= item.quantity) {
                  setState(() {
                    item.quantity -= quantityToTake; // Update the item's quantity
                  });
                  _saveItemsToFile(widget.items); // Save the updated list
                  Navigator.of(context).pop(); // Close the dialog
                } else {
                  // Show an error if the quantity to take is invalid
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invalid quantity!')),
                  );
                }
              },
              child: Text('Confirm', style: TextStyle(color: Color(0xFF3B3B41), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // Function to show the edit overlay with quantity editing
  void _showEditOverlay(BuildContext context, Item item) {
    final TextEditingController nameController = TextEditingController(text: item.name);
    final TextEditingController categoryController = TextEditingController(text: item.category);
    final TextEditingController tagsController = TextEditingController(text: item.tags.join(', '));
    final TextEditingController quantityController = TextEditingController(text: item.quantity.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          title: Text('Edit Item', style: TextStyle(color: Color(0xFF3B3B41), fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: Color(0xFF3B3B41), fontWeight: FontWeight.w500)),
                ),
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(labelText: 'Category', labelStyle: TextStyle(color: Color(0xFF3B3B41), fontWeight: FontWeight.w500)),
                ),
                TextField(
                  controller: quantityController,
                  decoration: InputDecoration(labelText: 'Quantity', labelStyle: TextStyle(color: Color(0xFF3B3B41), fontWeight: FontWeight.w500)),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: tagsController,
                  decoration: InputDecoration(labelText: 'Tags (comma separated)', labelStyle: TextStyle(color: Color(0xFF3B3B41), fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel', style: TextStyle(color: Color(0xFF3B3B41), fontWeight: FontWeight.w500)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  item.name = nameController.text;
                  item.category = categoryController.text;
                  item.quantity = int.tryParse(quantityController.text) ?? item.quantity;
                  item.tags = tagsController.text.split(',').map((tag) => tag.trim()).toList();
                });
                _saveItemsToFile(widget.items); // Save the updated list
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Save', style: TextStyle(color: Color(0xFF3B3B41), fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _showDeleteConfirmationDialog(context, item); // Show delete confirmation
              },
              child: Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // Function to show confirmation dialog for deletion
  void _showDeleteConfirmationDialog(BuildContext context, Item item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          title: Text('Delete Item', style: TextStyle(color: Color(0xFF3B3B41), fontWeight: FontWeight.bold)),
          content: Text('Are you sure you want to delete this item?', style: TextStyle(color: Color(0xFF3B3B41))),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without deleting
              },
              child: Text('Cancel', style: TextStyle(color: Color(0xFF3B3B41), fontWeight: FontWeight.w500)),
            ),
            TextButton(
              onPressed: () {
                widget.onDeleteItem(item); // Delete the item
                _saveItemsToFile(widget.items); // Save the updated list after deletion
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          return _buildItem(item, index);
        },
      ),
    );
  }

  Widget _buildItem(Item item, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: Container(
        height: 80, // Adjust height to fit smaller content
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // Adequate internal padding
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), // Rounded corners for a modern look
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFF3B3B41).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.category,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF3B3B41)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tags: ${item.tags.join(', ')}',
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Stock: ${item.quantity}',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.shopping_bag, color: Colors.green),
              onPressed: () => _showTakeOverlay(context, item),
            ),
          ],
        ),
      ),
    );
  }
}
