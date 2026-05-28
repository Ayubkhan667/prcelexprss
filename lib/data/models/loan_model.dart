class LoanModel {
  final String id;
  final String staffId;
  final String staffName;
  final String staffCode;
  final double loanAmount;
  final double paidAmount;
  final double balanceAmount;
  final double monthlyDeduction;
  final DateTime loanDate;
  final String status;
  final String? purpose;
  final String? notes;
  final DateTime createdAt;

  const LoanModel({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.staffCode,
    required this.loanAmount,
    required this.paidAmount,
    required this.balanceAmount,
    required this.monthlyDeduction,
    required this.loanDate,
    required this.status,
    this.purpose,
    this.notes,
    required this.createdAt,
  });

  factory LoanModel.fromMap(Map<String, dynamic> map) {
    return LoanModel(
      id: map['id'] ?? '',
      staffId: map['staff_id'] ?? '',
      staffName: map['staff_name'] ?? '',
      staffCode: map['staff_code'] ?? '',
      loanAmount: (map['loan_amount'] ?? 0).toDouble(),
      paidAmount: (map['paid_amount'] ?? 0).toDouble(),
      balanceAmount: (map['balance_amount'] ?? 0).toDouble(),
      monthlyDeduction: (map['monthly_deduction'] ?? 0).toDouble(),
      loanDate: DateTime.tryParse(map['loan_date'] ?? '') ?? DateTime.now(),
      status: map['status'] ?? 'Active',
      purpose: map['purpose'],
      notes: map['notes'],
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'staff_id': staffId,
        'staff_name': staffName,
        'staff_code': staffCode,
        'loan_amount': loanAmount,
        'paid_amount': paidAmount,
        'balance_amount': balanceAmount,
        'monthly_deduction': monthlyDeduction,
        'loan_date': loanDate.toIso8601String(),
        'status': status,
        'purpose': purpose,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  double get repaymentProgress =>
      loanAmount > 0 ? (paidAmount / loanAmount) : 0;

  LoanModel copyWith({
    double? paidAmount,
    double? balanceAmount,
    String? status,
    String? purpose,
    String? notes,
  }) {
    return LoanModel(
      id: id,
      staffId: staffId,
      staffName: staffName,
      staffCode: staffCode,
      loanAmount: loanAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      balanceAmount: balanceAmount ?? this.balanceAmount,
      monthlyDeduction: monthlyDeduction,
      loanDate: loanDate,
      status: status ?? this.status,
      purpose: purpose ?? this.purpose,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}
