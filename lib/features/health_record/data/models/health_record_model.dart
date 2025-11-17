class HealthRecord {
  final String id;
  final String userId;
  final DateTime date;
  final int? bloodPressureSystolic;
  final int? bloodPressureDiastolic;
  final double? bloodSugar;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  HealthRecord({
    required this.id,
    required this.userId,
    required this.date,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.bloodSugar,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  // Helper untuk format blood pressure
  String? get bloodPressureFormatted {
    if (bloodPressureSystolic == null || bloodPressureDiastolic == null) {
      return null;
    }
    return '$bloodPressureSystolic/$bloodPressureDiastolic mmHg';
  }

  // Helper untuk blood pressure status
  String get bloodPressureStatus {
    if (bloodPressureSystolic == null || bloodPressureDiastolic == null) {
      return 'Tidak ada data';
    }

    // Klasifikasi berdasarkan AHA guidelines
    if (bloodPressureSystolic! < 120 && bloodPressureDiastolic! < 80) {
      return 'Normal';
    } else if (bloodPressureSystolic! < 130 && bloodPressureDiastolic! < 80) {
      return 'Elevated';
    } else if (bloodPressureSystolic! < 140 || bloodPressureDiastolic! < 90) {
      return 'Hipertensi Tahap 1';
    } else if (bloodPressureSystolic! < 180 || bloodPressureDiastolic! < 120) {
      return 'Hipertensi Tahap 2';
    } else {
      return 'Krisis Hipertensi';
    }
  }

  // Helper untuk blood sugar status
  String get bloodSugarStatus {
    if (bloodSugar == null) return 'Tidak ada data';

    // Klasifikasi gula darah (mg/dL)
    if (bloodSugar! < 70) {
      return 'Rendah';
    } else if (bloodSugar! <= 140) {
      return 'Normal';
    } else if (bloodSugar! <= 200) {
      return 'Prediabetes';
    } else {
      return 'Tinggi';
    }
  }

  // Convert to Map untuk SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD
      'blood_pressure_systolic': bloodPressureSystolic,
      'blood_pressure_diastolic': bloodPressureDiastolic,
      'blood_sugar': bloodSugar,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  // Convert to Map untuk Supabase
  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'blood_pressure_systolic': bloodPressureSystolic,
      'blood_pressure_diastolic': bloodPressureDiastolic,
      'blood_sugar': bloodSugar,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create dari Map SQLite
  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'],
      userId: map['user_id'],
      date: DateTime.parse(map['date']),
      bloodPressureSystolic: map['blood_pressure_systolic'],
      bloodPressureDiastolic: map['blood_pressure_diastolic'],
      bloodSugar: map['blood_sugar']?.toDouble(),
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      isSynced: map['is_synced'] == 1,
    );
  }

  // Create dari Map Supabase
  factory HealthRecord.fromSupabase(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'],
      userId: map['user_id'],
      date: DateTime.parse(map['date']),
      bloodPressureSystolic: map['blood_pressure_systolic'],
      bloodPressureDiastolic: map['blood_pressure_diastolic'],
      bloodSugar: map['blood_sugar']?.toDouble(),
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      isSynced: true,
    );
  }

  // Copy with
  HealthRecord copyWith({
    String? id,
    String? userId,
    DateTime? date,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    double? bloodSugar,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      bloodPressureSystolic:
          bloodPressureSystolic ?? this.bloodPressureSystolic,
      bloodPressureDiastolic:
          bloodPressureDiastolic ?? this.bloodPressureDiastolic,
      bloodSugar: bloodSugar ?? this.bloodSugar,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
