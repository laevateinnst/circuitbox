import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:circuitbox/models/item.dart';

class GridViewComponent extends StatefulWidget {
  final List<Item> items;
  final Function(Item) onDeleteItem;

  const GridViewComponent({super.key, required this.items, required this.onDeleteItem});

  @override
  _GridViewComponentState createState() => _GridViewComponentState();
}

class _GridViewComponentState extends State<GridViewComponent> {
  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/items.json';
  }

  Future<void> _saveItemsToFile(List<Item> items) async {
    final file = File(await _getFilePath());
    List<Map<String, dynamic>> jsonList = items.map((item) => item.toJson()).toList();
    String jsonString = jsonEncode(jsonList);
    await file.writeAsString(jsonString);
  }



  void _showTakeOverlay(BuildContext context, Item item) {
    final TextEditingController takeController = TextEditingController(
      text: '0',
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
                  Navigator.of(context).pop();
                  _showEditOverlay(context, item);
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

                      IconButton(
                        icon: Icon(Icons.remove, color: Colors.black),
                        onPressed: () {
                          if (quantityToTake > 0) {
                            takeController.text = (quantityToTake - 1).toString();
                            setState(() {}); // Rebuild to update the remaining stock
                          }
                        },
                      ),

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
                            setState(() {});
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
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
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Color(0xFF3B3B41), fontWeight: FontWeight.w500)),
            ),
            // Confirm button
            TextButton(
              onPressed: () {

                int quantityToTake = int.tryParse(takeController.text) ?? 0;
                if (quantityToTake > 0 && quantityToTake <= item.quantity) {
                  setState(() {
                    item.quantity -= quantityToTake;
                  });
                  _saveItemsToFile(widget.items);
                  Navigator.of(context).pop();
                } else {

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
                Navigator.of(context).pop();
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
                _saveItemsToFile(widget.items);
                Navigator.of(context).pop();
              },
              child: Text('Save', style: TextStyle(color: Color(0xFF3B3B41), fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showDeleteConfirmationDialog(context, item);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }


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
      padding: const EdgeInsets.all(10.0), // Margin around the entire grid
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10, // This sets the gap between cards
          mainAxisSpacing: 10, // This sets the gap between cards
        ),
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          return _buildItem(item, index);
        },
      ),
    );
  }

  Widget _buildItem(Item item, int index) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10.0), // Internal padding for the card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3B3B41)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFF3B3B41).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.category,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B3B41),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              '${item.tags.join(', ')}',
              style: TextStyle(color: Colors.blueGrey, fontSize: 12),
            ),
            SizedBox(height: 8),
            Text(
              'Stock: ${item.quantity}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: Icon(Icons.shopping_bag, color: Colors.green),
                onPressed: () => _showTakeOverlay(context, item),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
