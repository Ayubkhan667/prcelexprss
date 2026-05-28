class SalaryModel {
  final String id;
  final String staffId;
  final String staffName;
  final String staffCode;
  final String month;
  final double basicSalary;
  final double overtimeAmount;
  final double allowance;
  final double deduction;
  final double loanDeduction;
  final double absenceDeduction;
  final double penalty;
  final double netSalary;
  final String paymentStatus;
  final DateTime? paidDate;
  final String? notes;
  final DateTime createdAt;

  const SalaryModel({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.staffCode,
    required this.month,
    required this.basicSalary,
    required this.overtimeAmount,
    required this.allowance,
    required this.deduction,
    required this.loanDeduction,
    required this.absenceDeduction,
    required this.penalty,
    required this.netSalary,
    required this.paymentStatus,
    this.paidDate,
    this.notes,
    required this.createdAt,
  });

  factory SalaryModel.fromMap(Map<String, dynamic> map) {
    return SalaryModel(
      id: map['id'] ?? '',
      staffId: map['staff_id'] ?? '',
      staffName: map['staff_name'] ?? '',
      staffCode: map['staff_code'] ?? '',
      month: map['month'] ?? '',
      basicSalary: (map['basic_salary'] ?? 0).toDouble(),
      overtimeAmount: (map['overtime_amount'] ?? 0).toDouble(),
      allowance: (map['allowance'] ?? 0).toDouble(),
      deduction: (map['deduction'] ?? 0).toDouble(),
      loanDeduction: (map['loan_deduction'] ?? 0).toDouble(),
      absenceDeduction: (map['absence_deduction'] ?? 0).toDouble(),
      penalty: (map['penalty'] ?? 0).toDouble(),
      netSalary: (map['net_salary'] ?? 0).toDouble(),
      paymentStatus: map['payment_status'] ?? 'Pending',
      paidDate:
          map['paid_date'] != null ? DateTime.tryParse(map['paid_date']) : null,
      notes: map['notes'],
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'staff_id': staffId,
        'staff_name': staffName,
        'staff_code': staffCode,
        'month': month,
        'basic_salary': basicSalary,
        'overtime_amount': overtimeAmount,
        'allowance': allowance,
        'deduction': deduction,
        'loan_deduction': loanDeduction,
        'absence_deduction': absenceDeduction,
        'penalty': penalty,
        'net_salary': netSalary,
        'payment_status': paymentStatus,
        'paid_date': paidDate?.toIso8601String(),
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  double get totalEarnings => basicSalary + overtimeAmount + allowance;
  double get totalDeductions =>
      deduction + loanDeduction + absenceDeduction + penalty;

  SalaryModel copyWith({
    String? paymentStatus,
    DateTime? paidDate,
    String? notes,
  }) {
    return SalaryModel(
      id: id,
      staffId: staffId,
      staffName: staffName,
      staffCode: staffCode,
      month: month,
      basicSalary: basicSalary,
      overtimeAmount: overtimeAmount,
      allowance: allowance,
      deduction: deduction,
      loanDeduction: loanDeduction,
      absenceDeduction: absenceDeduction,
      penalty: penalty,
      netSalary: netSalary,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paidDate: paidDate ?? this.paidDate,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}
