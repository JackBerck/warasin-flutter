import 'package:flutter/material.dart';

class ScheduleListPage extends StatelessWidget {
  const ScheduleListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Obat'),
      ),
      body: const Center(
        child: Text('Jadwal obat akan ditampilkan di sini'),
      ),
    );
  }
}
