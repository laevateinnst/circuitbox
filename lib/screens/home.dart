import 'package:flutter/material.dart';
import 'package:circuitbox/components/gridview.dart';
import 'package:circuitbox/components/listview.dart';
import 'package:circuitbox/components/search_bar.dart';
import 'package:circuitbox/models/item.dart';
import 'package:circuitbox/screens/add_item.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isGridViewSelected = true;
  final TextEditingController _searchController = TextEditingController();
  List<Item> filteredItems = [];
  List<Item> allItems = [];
  String? selectedCategory;

  Future<void> _loadItems() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/items.json';
      final file = File(filePath);

      if (!file.existsSync()) {
        print("File not found at $filePath. Returning an empty list.");
        setState(() {
          filteredItems = [];
          allItems = [];
        });
        return;
      }

      final String response = await file.readAsString();
      final data = json.decode(response);

      setState(() {
        allItems = (data as List).map((item) => Item.fromJson(item)).toList();
        filteredItems = allItems;
      });
    } catch (e) {
      print("Error loading items from file: $e");
    }
  }

  Future<void> _deleteItem(Item item) async {
    try {
      // Remove the item from the list
      allItems.remove(item);

      // Update the JSON file by saving the updated list
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/items.json';
      final file = File(filePath);
      final updatedData = json.encode(
          allItems.map((item) => item.toJson()).toList());

      // Save the updated list to the file
      await file.writeAsString(updatedData);

      // Reload the items after deletion
      _loadItems();
    } catch (e) {
      print("Error deleting item: $e");
    }
  }

  void _filterItems(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredItems = selectedCategory == null
            ? allItems
            : allItems.where((item) => item.category == selectedCategory)
            .toList();
      });
    } else {
      final filtered = allItems.where((item) {
        return (item.name.toLowerCase().contains(query.toLowerCase()) ||
            item.category.toLowerCase().contains(query.toLowerCase()) ||
            item.tags.any((tag) =>
                tag.toLowerCase().contains(query.toLowerCase()))) &&
            (selectedCategory == null || item.category == selectedCategory);
      }).toList();

      setState(() {
        filteredItems = filtered;
      });
    }
  }

  void _filterByCategory(String category) {
    setState(() {
      selectedCategory = category;
      filteredItems =
          allItems.where((item) => item.category == category).toList();
    });
  }

  List<String> _getCategories() {
    Set<String> categories = {};
    for (var item in allItems) {
      categories.add(item.category);
    }
    return categories.toList();
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(160),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF3B3B41),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
                top: 60.0, left: 30.0, right: 30.0, bottom: 8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Inventory",
                      style: TextStyle(color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        _buildSelectionIcon(Icons.grid_view, "Grid", true),
                        const SizedBox(width: 16),
                        _buildSelectionIcon(Icons.list, "List", false),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CustomSearchBar(
                  controller: _searchController,
                  onSearch: _filterItems,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Enables horizontal scrolling
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _getCategories().map((category) {
                  return _buildCategoryChip(category);
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: allItems.isEmpty
                ? Center(child: Text("Your box is empty",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
                : isGridViewSelected
                ? GridViewComponent(
                items: filteredItems, onDeleteItem: _deleteItem)
                : ListViewComponent(
                items: filteredItems, onDeleteItem: _deleteItem),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Color(0xFF3B3B41),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF3B3B41).withOpacity(0.5),  // Shadow color
              spreadRadius: 2,  // Spread the shadow
              blurRadius: 4,    // Blur effect for the shadow
              offset: Offset(0, 2),  // Position of the shadow
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),  // Rounded corners at top
            topRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () async {
                // Show the overlay (dialog) when the button is pressed
                bool? isAdded = await showDialog(
                  context: context,
                  barrierDismissible: false,
                  barrierColor: Colors.black.withOpacity(0.7), // Darken background
                  builder: (context) {
                    return AddItemOverlay();  // Your overlay widget
                  },
                );

                // If the item was added, reload the items
                if (isAdded == true) {
                  _loadItems();
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),  // Adjust padding as needed
                decoration: BoxDecoration(
                  color: Colors.transparent,  // Dark button color
                  borderRadius: BorderRadius.circular(12),  // Rounded corners

                ),
                child: Icon(
                Icons.add,  // "+" icon
                size: 24,
                color: Colors.white,  // Dark icon color
              ),
              ),
            ),
          ],
        ),
      ),

    );
  }


  Widget _buildSelectionIcon(IconData icon, String label, bool isGridIcon) {
    bool isSelected = isGridViewSelected == isGridIcon;

    return GestureDetector(
      onTap: () {
        setState(() {
          isGridViewSelected = isGridIcon;
        });
      },
      child: isSelected
          ? Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      )
          : Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: Color(0xFF3B3B41)),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return FilterChip(
      label: Text(category),
      selected: selectedCategory == category,
      onSelected: (isSelected) {
        if (isSelected) {
          _filterByCategory(category);
        } else {
          setState(() {
            selectedCategory = null;
            filteredItems = allItems;
          });
        }
      },
      selectedColor: Color(0xFF3B3B41),
      checkmarkColor: Colors.white,
      // Set checkmark color to white when selected
      labelStyle: TextStyle(
        color: selectedCategory == category ? Colors.white : Color(0xFF3B3B41),
        fontSize: 16,
        fontWeight: FontWeight.bold
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50), // Adjust the radius here
        side: BorderSide(
          color: Color(0xFF3B3B41), // Border color
          width: 1.5, // Border width
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    );
  }
}