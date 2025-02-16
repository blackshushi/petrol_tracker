class VehicleRecord {
  final int mileage;
  final double moneyToFill;
  final DateTime timestamp;

  VehicleRecord({
    required this.mileage,
    required this.moneyToFill,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory VehicleRecord.fromJson(Map<String, dynamic> json) {
    return VehicleRecord(
      mileage: _parseIntSafely(json['mileage']),
      moneyToFill: _parseDoubleSafely(json['moneyToFill']),
      timestamp: _parseTimestamp(json['timestamp']),
    );
  }

  static int _parseIntSafely(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.parse(value);
    throw const FormatException('Invalid mileage format');
  }

  static double _parseDoubleSafely(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.parse(value);
    throw const FormatException('Invalid moneyToFill format');
  }

  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is DateTime) return timestamp;
    if (timestamp is String) return DateTime.parse(timestamp);
    throw const FormatException('Invalid timestamp format');
  }

  Map<String, dynamic> toJson() => {
    'mileage': mileage,
    'moneyToFill': moneyToFill,
    'timestamp': timestamp.toIso8601String(),
  };

  int distanceSinceLast(VehicleRecord? lastRecord) {
    if (lastRecord == null) return 0;
    return mileage - lastRecord.mileage;
  }
}
