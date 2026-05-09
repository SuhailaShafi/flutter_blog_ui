class Validators {
  // Emoji detection pattern
  static final _emojiRegex = RegExp(
    r'[\u{1F000}-\u{1FFFF}]|[\u{2600}-\u{27FF}]|[\u{2300}-\u{23FF}]|'
    r'[\u{FE00}-\u{FEFF}]|[\u{1F900}-\u{1F9FF}]',
    unicode: true,
  );

  static final _emailRegex = RegExp(r'^[\w.+\-]+@[\w\-]+\.[a-zA-Z]{2,}$');

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required.';
    if (v.trim().length > 254) return 'Email is too long.';
    if (!_emailRegex.hasMatch(v.trim())) return 'Enter a valid email address.';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required.';
    if (v.length < 8) return 'Password must be at least 8 characters.';
    if (v.length > 64) return 'Password must be at most 64 characters.';
    if (_emojiRegex.hasMatch(v)) return 'Password cannot contain emojis.';
    if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Include at least one uppercase letter.';
    if (!RegExp(r'[a-z]').hasMatch(v)) return 'Include at least one lowercase letter.';
    if (!RegExp(r'[0-9]').hasMatch(v)) return 'Include at least one number.';
    return null;
  }

  static String? username(String? v) {
    if (v == null || v.trim().isEmpty) return 'Username is required.';
    final s = v.trim();
    if (s.length < 3) return 'Username must be at least 3 characters.';
    if (s.length > 30) return 'Username must be at most 30 characters.';
    if (_emojiRegex.hasMatch(s)) return 'Username cannot contain emojis.';
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(s)) {
      return 'Only letters, numbers, and underscores allowed.';
    }
    return null;
  }
}
