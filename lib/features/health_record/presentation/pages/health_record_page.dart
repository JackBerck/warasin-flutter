import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HealthRecordPage extends StatelessWidget {
  const HealthRecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Kesehatan'),
      ),
      body: const Center(
        child: Text('Catatan kesehatan akan ditampilkan di sini'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.goNamed('add-health-record');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
