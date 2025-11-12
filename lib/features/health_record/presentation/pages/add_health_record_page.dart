import 'package:flutter/material.dart';

class AddHealthRecordPage extends StatelessWidget {
  const AddHealthRecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Catatan'),
      ),
      body: const Center(
        child: Text('Form tambah catatan kesehatan'),
      ),
    );
  }
}
