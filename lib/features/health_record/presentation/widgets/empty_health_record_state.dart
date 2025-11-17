import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmptyHealthRecordState extends StatelessWidget {
  const EmptyHealthRecordState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_outline,
                size: 80,
                color: Colors.grey.shade400,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Belum Ada Catatan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Mulai catat kesehatan Anda untuk\nmemantau kondisi tubuh',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: () {
                context.pushNamed('add-health-record');
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Catatan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              '💡 Tip: Catat kesehatan secara rutin\nsetiap hari untuk hasil yang akurat',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
