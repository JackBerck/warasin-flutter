class Medicine {
  final String id;
  final String userId;
  final String name;
  final String? dosage;
  final String? description;
  final int stock;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced; // untuk tracking sync status (local only)

  Medicine({
    required this.id,
    required this.userId,
    required this.name,
    this.dosage,
    this.description,
    this.stock = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  // Convert to Map untuk SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'dosage': dosage,
      'description': description,
      'stock': stock,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  // Convert to Map untuk Supabase (tanpa is_synced)
  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'dosage': dosage,
      'description': description,
      'stock': stock,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create dari Map SQLite
  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      dosage: map['dosage'],
      description: map['description'],
      stock: map['stock'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      isSynced: map['is_synced'] == 1,
    );
  }

  // Create dari Map Supabase
  factory Medicine.fromSupabase(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      dosage: map['dosage'],
      description: map['description'],
      stock: map['stock'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      isSynced: true, // dari supabase berarti sudah sync
    );
  }

  // Copy with untuk update
  Medicine copyWith({
    String? id,
    String? userId,
    String? name,
    String? dosage,
    String? description,
    int? stock,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return Medicine(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      description: description ?? this.description,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
