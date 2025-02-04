class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String? profilePicture;
  final String? address;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.profilePicture,
    this.address,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      profilePicture: json['profilePicture'] as String?,
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'address': address,
    };
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    String? profilePicture,
    String? address,
  }) {
    return UserProfile(
      id: this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      address: address ?? this.address,
    );
  }
}
