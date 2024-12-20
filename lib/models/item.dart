class Item {
  String name;
  String category;
  List<String> tags;
  int quantity; // Remove the 'final' modifier to allow mutation

  Item({
    required this.name,
    required this.category,
    required this.tags,
    required this.quantity,
  });

  // Convert JSON to Item
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name'],
      category: json['category'],
      tags: List<String>.from(json['tags']),
      quantity: json['quantity'],
    );
  }

  // Convert Item to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'tags': tags,
      'quantity': quantity,
    };
  }
}
