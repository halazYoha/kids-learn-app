class UserProfile {
  final String name;
  final int avatarIndex;

  UserProfile({
    required this.name,
    required this.avatarIndex,
  });

  UserProfile copyWith({
    String? name,
    int? avatarIndex,
  }) {
    return UserProfile(
      name: name ?? this.name,
      avatarIndex: avatarIndex ?? this.avatarIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'avatarIndex': avatarIndex,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      avatarIndex: json['avatarIndex'] as int,
    );
  }
}
