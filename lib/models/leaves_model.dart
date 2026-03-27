class Leave {
  final int id;
  final String reason;
  final DateTime startDate;
  final DateTime endDate;
  final String status;

  Leave({
    required this.id,
    required this.reason,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory Leave.fromJson(Map<String, dynamic> json) {
    return Leave(
      id: json['id'] as int,
      reason: json['reason'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      status: json['status'] as String? ?? 'pending',
    );
  }
}
