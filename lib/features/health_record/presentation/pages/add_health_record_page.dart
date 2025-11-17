import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/health_record_model.dart';
import '../../providers/health_record_provider.dart';

class AddHealthRecordPage extends ConsumerStatefulWidget {
  final HealthRecord? record;

  const AddHealthRecordPage({super.key, this.record});

  @override
  ConsumerState<AddHealthRecordPage> createState() =>
      _AddHealthRecordPageState();
}

class _AddHealthRecordPageState extends ConsumerState<AddHealthRecordPage> {
  final _formKey = GlobalKey<FormState>();
  final _bpSystolicController = TextEditingController();
  final _bpDiastolicController = TextEditingController();
  final _bloodSugarController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _selectedDate = widget.record!.date;
      _bpSystolicController.text =
          widget.record!.bloodPressureSystolic?.toString() ?? '';
      _bpDiastolicController.text =
          widget.record!.bloodPressureDiastolic?.toString() ?? '';
      _bloodSugarController.text = widget.record!.bloodSugar?.toString() ?? '';
      _notesController.text = widget.record!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _bpSystolicController.dispose();
    _bpDiastolicController.dispose();
    _bloodSugarController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate at least one metric is filled
    if (_bpSystolicController.text.isEmpty &&
        _bpDiastolicController.text.isEmpty &&
        _bloodSugarController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Isi minimal satu data kesehatan'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final controller = ref.read(healthRecordControllerProvider);
    bool success;

    if (widget.record != null) {
      // Update existing record
      success = await controller.updateRecord(
        record: widget.record!.copyWith(
          date: _selectedDate,
          bloodPressureSystolic: _bpSystolicController.text.isEmpty
              ? null
              : int.tryParse(_bpSystolicController.text),
          bloodPressureDiastolic: _bpDiastolicController.text.isEmpty
              ? null
              : int.tryParse(_bpDiastolicController.text),
          bloodSugar: _bloodSugarController.text.isEmpty
              ? null
              : double.tryParse(_bloodSugarController.text),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        ),
      );
    } else {
      // Create new record
      success = await controller.createRecord(
        date: _selectedDate,
        bloodPressureSystolic: _bpSystolicController.text.isEmpty
            ? null
            : int.tryParse(_bpSystolicController.text),
        bloodPressureDiastolic: _bpDiastolicController.text.isEmpty
            ? null
            : int.tryParse(_bpDiastolicController.text),
        bloodSugar: _bloodSugarController.text.isEmpty
            ? null
            : double.tryParse(_bloodSugarController.text),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.record != null
                ? 'Catatan berhasil diperbarui'
                : 'Catatan berhasil ditambahkan',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.record != null
                ? 'Gagal memperbarui catatan'
                : 'Gagal menambahkan catatan',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.record != null;
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Catatan' : 'Tambah Catatan'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite,
                  size: 60,
                  color: Theme.of(context).primaryColor,
                ),
              ),

              const SizedBox(height: 32),

              // Date Picker
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Tanggal *',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    dateFormat.format(_selectedDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Section: Tekanan Darah
              Text(
                'Tekanan Darah (mmHg)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  // Systolic
                  Expanded(
                    child: TextFormField(
                      controller: _bpSystolicController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Sistolik',
                        hintText: 'Contoh: 120',
                        prefixIcon: const Icon(Icons.arrow_upward),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final val = int.tryParse(value);
                          if (val == null || val < 40 || val > 300) {
                            return 'Tidak valid';
                          }
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Diastolic
                  Expanded(
                    child: TextFormField(
                      controller: _bpDiastolicController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Diastolik',
                        hintText: 'Contoh: 80',
                        prefixIcon: const Icon(Icons.arrow_downward),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final val = int.tryParse(value);
                          if (val == null || val < 20 || val > 200) {
                            return 'Tidak valid';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Section: Gula Darah
              Text(
                'Gula Darah (mg/dL)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _bloodSugarController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                ],
                decoration: InputDecoration(
                  labelText: 'Kadar Gula Darah',
                  hintText: 'Contoh: 110',
                  prefixIcon: const Icon(Icons.water_drop),
                  suffixText: 'mg/dL',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final val = double.tryParse(value);
                    if (val == null || val < 20 || val > 600) {
                      return 'Nilai tidak valid';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Notes
              Text(
                'Catatan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _notesController,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Catatan Tambahan',
                  hintText: 'Kondisi, gejala, atau informasi lainnya',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.notes),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Info text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '* Isi minimal satu data kesehatan (tekanan darah atau gula darah)',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          isEdit ? 'Perbarui Catatan' : 'Simpan Catatan',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
