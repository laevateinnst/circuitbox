import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;

  const CustomSearchBar({Key? key, required this.controller, required this.onSearch}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: 400, // Makes the search bar take up the full width
        child: TextField(
          controller: controller,
          style: TextStyle(color: Color(0xFF3B3B41)), // Text color
          decoration: InputDecoration(
            hintText: 'Search your item',
            hintStyle: TextStyle(color: Color(0xFF3B3B41)), // Hint text color
            prefixIcon: Icon(
              Icons.search,
              color: Color(0xFF3B3B41), // Icon color
            ),
            filled: true,
            fillColor: Colors.white, // Fill the background with white color
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none, // Remove the border
            ),
          ),
          onChanged: onSearch, // Call the onSearch function when text changes
        ),
      ),
    );
  }
}
