import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MedicineListPage extends StatelessWidget {
  const MedicineListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Obat')),
      body: const Center(child: Text('List Obat akan ditampilkan di sini')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.goNamed('add-medicine');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
