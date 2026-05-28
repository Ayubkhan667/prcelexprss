class ExpenseModel {
  final String id;
  final String staffId;
  final String staffName;
  final String staffCode;
  final String expenseType;
  final double amount;
  final DateTime expenseDate;
  final String description;
  final List<String> receiptImages; // local file paths
  final String status; // Pending | Approved | Rejected
  final String? approvedBy;
  final String? rejectionReason;
  final DateTime createdAt;

  const ExpenseModel({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.staffCode,
    required this.expenseType,
    required this.amount,
    required this.expenseDate,
    required this.description,
    this.receiptImages = const [],
    required this.status,
    this.approvedBy,
    this.rejectionReason,
    required this.createdAt,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] ?? '',
      staffId: map['staff_id'] ?? '',
      staffName: map['staff_name'] ?? '',
      staffCode: map['staff_code'] ?? '',
      expenseType: map['expense_type'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      expenseDate:
          DateTime.tryParse(map['expense_date'] ?? '') ?? DateTime.now(),
      description: map['description'] ?? '',
      receiptImages: (map['receipt_images'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      status: map['status'] ?? 'Pending',
      approvedBy: map['approved_by'],
      rejectionReason: map['rejection_reason'],
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'staff_id': staffId,
        'staff_name': staffName,
        'staff_code': staffCode,
        'expense_type': expenseType,
        'amount': amount,
        'expense_date': expenseDate.toIso8601String(),
        'description': description,
        'receipt_images': receiptImages,
        'status': status,
        'approved_by': approvedBy,
        'rejection_reason': rejectionReason,
        'created_at': createdAt.toIso8601String(),
      };

  ExpenseModel copyWith({
    String? status,
    String? approvedBy,
    String? rejectionReason,
  }) {
    return ExpenseModel(
      id: id,
      staffId: staffId,
      staffName: staffName,
      staffCode: staffCode,
      expenseType: expenseType,
      amount: amount,
      expenseDate: expenseDate,
      description: description,
      receiptImages: receiptImages,
      status: status ?? this.status,
      approvedBy: approvedBy ?? this.approvedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt,
    );
  }
}
