class DocumentAlertModel {
  final String staffId;
  final String staffName;
  final String staffCode;
  final String documentType;
  final DateTime expiryDate;
  final int daysRemaining;

  const DocumentAlertModel({
    required this.staffId,
    required this.staffName,
    required this.staffCode,
    required this.documentType,
    required this.expiryDate,
    required this.daysRemaining,
  });

  bool get isExpired => daysRemaining < 0;
  bool get isUrgent => daysRemaining <= 7;
  bool get isWarning => daysRemaining <= 30;
}
