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
              );
            },
          );
        },
      ),
    );
  }
}