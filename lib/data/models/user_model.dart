const _unset = Object();

class UserModel {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String role;
  final String? scopeBranchId;
  final String? scopeDepartment;
  final String status;
  final String? deviceId;
  final String? profileImageUrl;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.role,
    this.scopeBranchId,
    this.scopeDepartment,
    required this.status,
    this.deviceId,
    this.profileImageUrl,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      mobile: map['mobile'] ?? '',
      role: map['role'] ?? 'staff',
      scopeBranchId: map['scope_branch_id'],
      scopeDepartment: map['scope_department'],
      status: map['status'] ?? 'Active',
      deviceId: map['device_id'],
      profileImageUrl: map['profile_image_url'],
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'mobile': mobile,
    'role': role,
    'scope_branch_id': scopeBranchId,
    'scope_department': scopeDepartment,
    'status': status,
    'device_id': deviceId,
    'profile_image_url': profileImageUrl,
    'created_at': createdAt.toIso8601String(),
  };

  UserModel copyWith({
    String? name,
    String? email,
    String? mobile,
    String? role,
    Object? scopeBranchId = _unset,
    Object? scopeDepartment = _unset,
    String? status,
    Object? deviceId = _unset,
    Object? profileImageUrl = _unset,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      role: role ?? this.role,
      scopeBranchId: identical(scopeBranchId, _unset)
          ? this.scopeBranchId
          : scopeBranchId as String?,
      scopeDepartment: identical(scopeDepartment, _unset)
          ? this.scopeDepartment
          : scopeDepartment as String?,
      status: status ?? this.status,
      deviceId:
          identical(deviceId, _unset) ? this.deviceId : deviceId as String?,
      profileImageUrl: identical(profileImageUrl, _unset)
          ? this.profileImageUrl
          : profileImageUrl as String?,
      createdAt: createdAt,
    );
  }
}
