class UserProgress {
  int xp;
  int level;
  int stars;
  int streak;
  String avatar;
  String lastLogin;

  UserProgress({
    required this.xp,
    required this.level,
    required this.stars,
    required this.streak,
    required this.avatar,
    required this.lastLogin,
  });

  Map<String, dynamic> toMap() {
    return {
      'xp': xp,
      'level': level,
      'stars': stars,
      'streak': streak,
      'avatar': avatar,
      'lastLogin': lastLogin,
    };
  }

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      xp: map['xp'] ?? 0,
      level: map['level'] ?? 1,
      stars: map['stars'] ?? 0,
      streak: map['streak'] ?? 0,
      avatar: map['avatar'] ?? 'default',
      lastLogin: map['lastLogin'] ?? '',
    );
  }
}