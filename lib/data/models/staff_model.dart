class StaffModel {
  final String id;
  final String userId;
  final String staffCode;
  final String name;
  final String email;
  final String mobile;
  final String? idCardNumber;
  final String jobTitle;
  final String category;
  final String department;
  final String branchId;
  final String branchName;
  final String shiftId;
  final String shiftName;
  final DateTime joiningDate;
  final double basicSalary;
  final double overtimeRate;
  final String weeklyOffDay;
  final String status;
  final String? profileImageUrl;
  final double? kpiScore;
  final String? kpiRating;
  final double? loanBalance;
  final double? overtimeHours;
  final String? todayCheckIn;
  final String? todayCheckOut;
  final String? todayStatus;

  // Personal extended
  final String? preferredName;
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? nationality;
  final String? gender;
  final String? maritalStatus;
  final String? personalEmail;
  final String? workPhone;
  final String? personalAddress;
  final String? aboutMe;
  final String? whatIDo;
  final List<String>? skills;
  final Map<String, String>? socialMedia;
  final List<String>? hobbies;

  // Documents
  final String? sponsorName;
  final String? civilId;
  final DateTime? civilIdExpireDate;
  final String? passportNumber;
  final DateTime? passportExpireDate;
  final String? passportStatus;

  // Contract
  final String? contractType;
  final String? contractTerms;
  final DateTime? contractStartDate;
  final DateTime? contractExpireDate;
  final String? salaryType;

  // Bank
  final String? nameAsPerBank;
  final String? bankName;
  final String? swiftCode;
  final String? accountNumber;

  // Emergency contact
  final String? emergencyContactName;
  final String? emergencyContactRelation;
  final String? emergencyContactPhone;

  // HR document status
  final String? passportSubmissionStatus;
  final String? passportCollectionStatus;

  const StaffModel({
    required this.id,
    required this.userId,
    required this.staffCode,
    required this.name,
    required this.email,
    required this.mobile,
    this.idCardNumber,
    required this.jobTitle,
    required this.category,
    required this.department,
    required this.branchId,
    required this.branchName,
    required this.shiftId,
    required this.shiftName,
    required this.joiningDate,
    required this.basicSalary,
    required this.overtimeRate,
    required this.weeklyOffDay,
    required this.status,
    this.profileImageUrl,
    this.kpiScore,
    this.kpiRating,
    this.loanBalance,
    this.overtimeHours,
    this.todayCheckIn,
    this.todayCheckOut,
    this.todayStatus,
    this.preferredName,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.nationality,
    this.gender,
    this.maritalStatus,
    this.personalEmail,
    this.workPhone,
    this.personalAddress,
    this.aboutMe,
    this.whatIDo,
    this.skills,
    this.socialMedia,
    this.hobbies,
    this.sponsorName,
    this.civilId,
    this.civilIdExpireDate,
    this.passportNumber,
    this.passportExpireDate,
    this.passportStatus,
    this.contractType,
    this.contractTerms,
    this.contractStartDate,
    this.contractExpireDate,
    this.salaryType,
    this.nameAsPerBank,
    this.bankName,
    this.swiftCode,
    this.accountNumber,
    this.emergencyContactName,
    this.emergencyContactRelation,
    this.emergencyContactPhone,
    this.passportSubmissionStatus,
    this.passportCollectionStatus,
  });

  factory StaffModel.fromMap(Map<String, dynamic> map) {
    return StaffModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      staffCode: map['staff_code'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      mobile: map['mobile'] ?? '',
      idCardNumber: map['id_card_number'],
      jobTitle: map['job_title'] ?? '',
      category: map['category'] ?? '',
      department: map['department'] ?? '',
      branchId: map['branch_id'] ?? '',
      branchName: map['branch_name'] ?? '',
      shiftId: map['shift_id'] ?? '',
      shiftName: map['shift_name'] ?? '',
      joiningDate: DateTime.tryParse(map['joining_date'] ?? '') ?? DateTime.now(),
      basicSalary: (map['basic_salary'] ?? 0).toDouble(),
      overtimeRate: (map['overtime_rate'] ?? 0).toDouble(),
      weeklyOffDay: map['weekly_off_day'] ?? 'Friday',
      status: map['status'] ?? 'Active',
      profileImageUrl: map['profile_image_url'],
      kpiScore: (map['kpi_score'] as num?)?.toDouble(),
      kpiRating: map['kpi_rating'],
      loanBalance: (map['loan_balance'] as num?)?.toDouble(),
      overtimeHours: (map['overtime_hours'] as num?)?.toDouble(),
      todayCheckIn: map['today_check_in'],
      todayCheckOut: map['today_check_out'],
      todayStatus: map['today_status'],
      preferredName: map['preferred_name'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      dateOfBirth: map['date_of_birth'] != null
          ? DateTime.tryParse(map['date_of_birth'])
          : null,
      nationality: map['nationality'],
      gender: map['gender'],
      maritalStatus: map['marital_status'],
      personalEmail: map['personal_email'],
      workPhone: map['work_phone'],
      personalAddress: map['personal_address'],
      aboutMe: map['about_me'],
      whatIDo: map['what_i_do'],
      skills: (map['skills'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList(),
      socialMedia: (map['social_media'] as Map<dynamic, dynamic>?)?.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      ),
      hobbies: (map['hobbies'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList(),
      sponsorName: map['sponsor_name'],
      civilId: map['civil_id'],
      civilIdExpireDate: map['civil_id_expire_date'] != null
          ? DateTime.tryParse(map['civil_id_expire_date'])
          : null,
      passportNumber: map['passport_number'],
      passportExpireDate: map['passport_expire_date'] != null
          ? DateTime.tryParse(map['passport_expire_date'])
          : null,
      passportStatus: map['passport_status'],
      contractType: map['contract_type'],
      contractTerms: map['contract_terms'],
      contractStartDate: map['contract_start_date'] != null
          ? DateTime.tryParse(map['contract_start_date'])
          : null,
      contractExpireDate: map['contract_expire_date'] != null
          ? DateTime.tryParse(map['contract_expire_date'])
          : null,
      salaryType: map['salary_type'],
      nameAsPerBank: map['name_as_per_bank'],
      bankName: map['bank_name'],
      swiftCode: map['swift_code'],
      accountNumber: map['account_number'],
      emergencyContactName: map['emergency_contact_name'],
      emergencyContactRelation: map['emergency_contact_relation'],
      emergencyContactPhone: map['emergency_contact_phone'],
      passportSubmissionStatus: map['passport_submission_status'],
      passportCollectionStatus: map['passport_collection_status'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'staff_code': staffCode,
        'name': name,
        'email': email,
        'mobile': mobile,
        'id_card_number': idCardNumber,
        'job_title': jobTitle,
        'category': category,
        'department': department,
        'branch_id': branchId,
        'branch_name': branchName,
        'shift_id': shiftId,
        'shift_name': shiftName,
        'joining_date': joiningDate.toIso8601String(),
        'basic_salary': basicSalary,
        'overtime_rate': overtimeRate,
        'weekly_off_day': weeklyOffDay,
        'status': status,
        'profile_image_url': profileImageUrl,
        'kpi_score': kpiScore,
        'kpi_rating': kpiRating,
        'loan_balance': loanBalance,
        'overtime_hours': overtimeHours,
        'today_check_in': todayCheckIn,
        'today_check_out': todayCheckOut,
        'today_status': todayStatus,
        'preferred_name': preferredName,
        'first_name': firstName,
        'last_name': lastName,
        'date_of_birth': dateOfBirth?.toIso8601String(),
        'nationality': nationality,
        'gender': gender,
        'marital_status': maritalStatus,
        'personal_email': personalEmail,
        'work_phone': workPhone,
        'personal_address': personalAddress,
        'about_me': aboutMe,
        'what_i_do': whatIDo,
        'skills': skills,
        'social_media': socialMedia,
        'hobbies': hobbies,
        'sponsor_name': sponsorName,
        'civil_id': civilId,
        'civil_id_expire_date': civilIdExpireDate?.toIso8601String(),
        'passport_number': passportNumber,
        'passport_expire_date': passportExpireDate?.toIso8601String(),
        'passport_status': passportStatus,
        'contract_type': contractType,
        'contract_terms': contractTerms,
        'contract_start_date': contractStartDate?.toIso8601String(),
        'contract_expire_date': contractExpireDate?.toIso8601String(),
        'salary_type': salaryType,
        'name_as_per_bank': nameAsPerBank,
        'bank_name': bankName,
        'swift_code': swiftCode,
        'account_number': accountNumber,
        'emergency_contact_name': emergencyContactName,
        'emergency_contact_relation': emergencyContactRelation,
        'emergency_contact_phone': emergencyContactPhone,
        'passport_submission_status': passportSubmissionStatus,
        'passport_collection_status': passportCollectionStatus,
      };

  StaffModel copyWith({
    String? name,
    String? email,
    String? mobile,
    String? jobTitle,
    String? category,
    String? department,
    String? branchId,
    String? branchName,
    String? status,
    double? basicSalary,
    double? kpiScore,
    String? kpiRating,
    double? loanBalance,
    String? todayCheckIn,
    String? todayCheckOut,
    String? todayStatus,
  }) {
    return StaffModel(
      id: id,
      userId: userId,
      staffCode: staffCode,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      idCardNumber: idCardNumber,
      jobTitle: jobTitle ?? this.jobTitle,
      category: category ?? this.category,
      department: department ?? this.department,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      shiftId: shiftId,
      shiftName: shiftName,
      joiningDate: joiningDate,
      basicSalary: basicSalary ?? this.basicSalary,
      overtimeRate: overtimeRate,
      weeklyOffDay: weeklyOffDay,
      status: status ?? this.status,
      profileImageUrl: profileImageUrl,
      kpiScore: kpiScore ?? this.kpiScore,
      kpiRating: kpiRating ?? this.kpiRating,
      loanBalance: loanBalance ?? this.loanBalance,
      overtimeHours: overtimeHours,
      todayCheckIn: todayCheckIn ?? this.todayCheckIn,
      todayCheckOut: todayCheckOut ?? this.todayCheckOut,
      todayStatus: todayStatus ?? this.todayStatus,
      preferredName: preferredName,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      nationality: nationality,
      gender: gender,
      maritalStatus: maritalStatus,
      personalEmail: personalEmail,
      workPhone: workPhone,
      personalAddress: personalAddress,
      aboutMe: aboutMe,
      whatIDo: whatIDo,
      skills: skills,
      socialMedia: socialMedia,
      hobbies: hobbies,
      sponsorName: sponsorName,
      civilId: civilId,
      civilIdExpireDate: civilIdExpireDate,
      passportNumber: passportNumber,
      passportExpireDate: passportExpireDate,
      passportStatus: passportStatus,
      contractType: contractType,
      contractTerms: contractTerms,
      contractStartDate: contractStartDate,
      contractExpireDate: contractExpireDate,
      salaryType: salaryType,
      nameAsPerBank: nameAsPerBank,
      bankName: bankName,
      swiftCode: swiftCode,
      accountNumber: accountNumber,
      emergencyContactName: emergencyContactName,
      emergencyContactRelation: emergencyContactRelation,
      emergencyContactPhone: emergencyContactPhone,
      passportSubmissionStatus: passportSubmissionStatus,
      passportCollectionStatus: passportCollectionStatus,
    );
  }
}
