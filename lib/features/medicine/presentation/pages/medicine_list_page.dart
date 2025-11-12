import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/medicine_provider.dart';
import '../widgets/medicine_card.dart';
import '../widgets/empty_medicine_state.dart';

class MedicineListPage extends ConsumerStatefulWidget {
  const MedicineListPage({super.key});

  @override
  ConsumerState<MedicineListPage> createState() => _MedicineListPageState();
}

class _MedicineListPageState extends ConsumerState<MedicineListPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final medicinesAsync = ref.watch(medicineListProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Cari obat...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              )
            : const Text('Daftar Obat'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: medicinesAsync.when(
        data: (medicines) {
          // Filter berdasarkan search
          final filteredMedicines = _searchController.text.isEmpty
              ? medicines
              : medicines
                  .where((medicine) =>
                      medicine.name
                          .toLowerCase()
                          .contains(_searchController.text.toLowerCase()) ||
                      (medicine.description?.toLowerCase().contains(
                              _searchController.text.toLowerCase()) ??
                          false))
                  .toList();

          if (filteredMedicines.isEmpty) {
            return _searchController.text.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada hasil untuk "${_searchController.text}"',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : const EmptyMedicineState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(medicineListProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredMedicines.length,
              itemBuilder: (context, index) {
                return MedicineCard(
                  medicine: filteredMedicines[index],
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                'Terjadi kesalahan',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(medicineListProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed('add-medicine');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
