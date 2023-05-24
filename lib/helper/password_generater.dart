import 'dart:math';

class PasswordGenerator {
  /// Generate a random password with the given length
  /// length must be in range of 20 to 128
  static String generatePassword({required double length}) {
    // length must be in range of 20 to 128
    if (length < 20 || length > 128) {
      throw Exception("Password length must be in range of 20 to 128");
    }

    final Random _random = Random.secure();
    const String _validChars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()-_=+[]{};:,.<>?';

    String password = '';
    bool hasUpperCase = false;
    bool hasLowerCase = false;
    bool hasDigit = false;
    bool hasSymbol = false;

    while (password.length < length ||
        !hasUpperCase ||
        !hasLowerCase ||
        !hasDigit ||
        !hasSymbol) {
      password = '';
      hasUpperCase = false;
      hasLowerCase = false;
      hasDigit = false;
      hasSymbol = false;

      for (int i = 0; i < length; i++) {
        int randomIndex = _random.nextInt(_validChars.length);
        password += _validChars[randomIndex];

        if (RegExp(r'[A-Z]').hasMatch(password[i])) {
          hasUpperCase = true;
        } else if (RegExp(r'[a-z]').hasMatch(password[i])) {
          hasLowerCase = true;
        } else if (RegExp(r'[0-9]').hasMatch(password[i])) {
          hasDigit = true;
        } else {
          hasSymbol = true;
        }
      }
    }

    return password;
  }
}
