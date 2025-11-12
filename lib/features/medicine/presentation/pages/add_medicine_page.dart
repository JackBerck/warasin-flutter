import 'package:flutter/material.dart';

class AddMedicinePage extends StatelessWidget {
  final String? medicineId;

  const AddMedicinePage({super.key, this.medicineId});

  @override
  Widget build(BuildContext context) {
    final isEdit = medicineId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Obat' : 'Tambah Obat')),
      body: const Center(child: Text('Form tambah/edit obat')),
    );
  }
}
