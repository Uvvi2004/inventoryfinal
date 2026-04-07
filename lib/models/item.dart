class Item {
  final String id;
  final String name;
  final int quantity;

  Item({
    required this.id,
    required this.name,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
    };
  }

  factory Item.fromMap(String id, Map<String, dynamic> map) {
    return Item(
      id: id,
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
    );
  }
}