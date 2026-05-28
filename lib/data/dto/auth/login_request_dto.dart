class LoginRequestDto {
  final String identifier;
  final String password;
  final String? deviceName;
  final String? deviceId;

  const LoginRequestDto({
    required this.identifier,
    required this.password,
    this.deviceName,
    this.deviceId,
  });

  LoginRequestDto copyWith({
    String? identifier,
    String? password,
    String? deviceName,
    String? deviceId,
  }) {
    return LoginRequestDto(
      identifier: identifier ?? this.identifier,
      password: password ?? this.password,
      deviceName: deviceName ?? this.deviceName,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  Map<String, dynamic> toMap() => {
        'identifier': identifier,
        'password': password,
        if (deviceName != null && deviceName!.isNotEmpty)
          'device_name': deviceName,
        if (deviceId != null && deviceId!.isNotEmpty) 'device_id': deviceId,
      };
}
