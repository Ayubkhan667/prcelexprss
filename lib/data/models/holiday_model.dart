class HolidayModel {
  final String id;
  final String name;
  final DateTime date;
  final String type; // 'Eid' | 'Public' | 'Weekly'
  final double otMultiplier; // 2.0 for Eid/Public, 1.5 for Friday

  const HolidayModel({
    required this.id,
    required this.name,
    required this.date,
    required this.type,
    required this.otMultiplier,
  });

  factory HolidayModel.fromMap(Map<String, dynamic> map) {
    return HolidayModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      type: map['type'] ?? 'Public',
      otMultiplier: (map['ot_multiplier'] ?? 1).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'date': date.toIso8601String(),
        'type': type,
        'ot_multiplier': otMultiplier,
      };

  HolidayModel copyWith({
    String? name,
    DateTime? date,
    String? type,
    double? otMultiplier,
  }) {
    return HolidayModel(
      id: id,
      name: name ?? this.name,
      date: date ?? this.date,
      type: type ?? this.type,
      otMultiplier: otMultiplier ?? this.otMultiplier,
    );
  }
}
