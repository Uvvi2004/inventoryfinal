import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'models/item.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: InventoryPage(),
    );
  }
}

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),

      body: StreamBuilder<List<Item>>(
        stream: service.streamItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(child: Text('No items yet.'));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final item = items[i];

              return ListTile(
                title: Text(item.name),
                subtitle: Text('Qty: ${item.quantity}'),

                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await service.deleteItem(item.id);
                  },
                ),

                onTap: () {
                  final nameController =
                      TextEditingController(text: item.name);
                  final qtyController =
                      TextEditingController(text: item.quantity.toString());

                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Edit Item'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: nameController,
                            decoration:
                                const InputDecoration(labelText: 'Name'),
                          ),
                          TextField(
                            controller: qtyController,
                            decoration: const InputDecoration(
                                labelText: 'Quantity'),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            final updatedName =
                                nameController.text.trim();
                            final updatedQty =
                                int.tryParse(qtyController.text);

                            if (updatedName.isEmpty ||
                                updatedQty == null) {
                              return;
                            }

                            await service.updateItem(
                              Item(
                                id: item.id,
                                name: updatedName,
                                quantity: updatedQty,
                              ),
                            );

                            Navigator.pop(context);
                          },
                          child: const Text('Update'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final nameController = TextEditingController();
          final qtyController = TextEditingController();

          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Add Item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: qtyController,
                    decoration:
                        const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final qty = int.tryParse(qtyController.text);

                    if (name.isEmpty || qty == null) {
                      return;
                    }

                    await service.addItem(
                      Item(id: '', name: name, quantity: qty),
                    );

                    Navigator.pop(context);
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}