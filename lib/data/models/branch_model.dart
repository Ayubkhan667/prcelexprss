class BranchModel {
  final String id;
  final String branchName;
  final double latitude;
  final double longitude;
  final double allowedRadius;
  final String status;
  final String? address;
  final int? staffCount;
  final String? wifiSsid;

  const BranchModel({
    required this.id,
    required this.branchName,
    required this.latitude,
    required this.longitude,
    required this.allowedRadius,
    required this.status,
    this.address,
    this.staffCount,
    this.wifiSsid,
  });

  factory BranchModel.fromMap(Map<String, dynamic> map) {
    return BranchModel(
      id: map['id'] ?? '',
      branchName: map['branch_name'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      allowedRadius: (map['allowed_radius'] ?? 100).toDouble(),
      status: map['status'] ?? 'Active',
      address: map['address'],
      staffCount: map['staff_count'],
      wifiSsid: map['wifi_ssid'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'branch_name': branchName,
        'latitude': latitude,
        'longitude': longitude,
        'allowed_radius': allowedRadius,
        'status': status,
        'address': address,
        'staff_count': staffCount,
        'wifi_ssid': wifiSsid,
      };

  BranchModel copyWith({
    String? branchName,
    double? latitude,
    double? longitude,
    double? allowedRadius,
    String? status,
    String? address,
    int? staffCount,
    String? wifiSsid,
  }) {
    return BranchModel(
      id: id,
      branchName: branchName ?? this.branchName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      allowedRadius: allowedRadius ?? this.allowedRadius,
      status: status ?? this.status,
      address: address ?? this.address,
      staffCount: staffCount ?? this.staffCount,
      wifiSsid: wifiSsid ?? this.wifiSsid,
    );
  }
}
